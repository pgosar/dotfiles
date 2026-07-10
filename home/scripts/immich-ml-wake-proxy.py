#!/usr/bin/env python3
import http.client
import os
import subprocess
import sys
import threading
from datetime import datetime
from time import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


LISTEN_HOST = os.environ.get("LISTEN_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "3004"))
PC_ML_URL = os.environ.get("PC_ML_URL", "http://pc:3003")
LOCAL_ML_URL = os.environ.get("LOCAL_ML_URL", "http://127.0.0.1:3003")
ENSURE_SCRIPT = os.environ.get(
    "ENSURE_SCRIPT", "/data/docker/compose/nightly-orchestrator/pc-worker-ensure.sh"
)
ENSURE_TIMEOUT = int(os.environ.get("ENSURE_TIMEOUT", "240"))
PC_CONNECT_TIMEOUT = int(os.environ.get("PC_CONNECT_TIMEOUT", "5"))
FALLBACK_TO_LOCAL = os.environ.get("FALLBACK_TO_LOCAL", "true").lower() == "true"
NIGHT_ONLY = os.environ.get("NIGHT_ONLY", "true").lower() == "true"
NIGHT_START = os.environ.get("NIGHT_START", "04:00")
NIGHT_END = os.environ.get("NIGHT_END", "10:00")
BULK_REQUEST_THRESHOLD = int(os.environ.get("BULK_REQUEST_THRESHOLD", "50"))
BULK_WINDOW_SECONDS = int(os.environ.get("BULK_WINDOW_SECONDS", "900"))
LAST_REQUEST_FILE = os.environ.get(
    "LAST_REQUEST_FILE",
    "/data/docker/appdata/nightly-orchestrator/immich-ml-last-request",
)
ACTIVE_REQUESTS_FILE = os.environ.get(
    "ACTIVE_REQUESTS_FILE",
    "/data/docker/appdata/nightly-orchestrator/immich-ml-active-requests",
)

_ensure_lock = threading.Lock()
_request_lock = threading.Lock()
_active_lock = threading.Lock()
_request_times = []
_active_requests = 0


def log(message: str) -> None:
    print(message, file=sys.stderr, flush=True)


def split_target(url: str):
    parsed = urlsplit(url)
    port = parsed.port or (443 if parsed.scheme == "https" else 80)
    return parsed.scheme, parsed.hostname, port


def healthcheck(url: str) -> bool:
    scheme, host, port = split_target(url)
    conn_cls = http.client.HTTPSConnection if scheme == "https" else http.client.HTTPConnection
    try:
        conn = conn_cls(host, port, timeout=PC_CONNECT_TIMEOUT)
        conn.request("GET", "/ping")
        resp = conn.getresponse()
        resp.read()
        return resp.status < 500
    except Exception:
        return False
    finally:
        try:
            conn.close()
        except Exception:
            pass


def minutes_since_midnight(value: str) -> int:
    hour, minute = value.split(":", 1)
    return int(hour) * 60 + int(minute)


def in_night_window() -> bool:
    if not NIGHT_ONLY:
        return True

    now_dt = datetime.now()
    now = now_dt.hour * 60 + now_dt.minute
    start = minutes_since_midnight(NIGHT_START)
    end = minutes_since_midnight(NIGHT_END)

    if start == end:
        return True
    if start < end:
        return start <= now < end
    return now >= start or now < end


def ensure_pc_ml() -> bool:
    if not in_night_window():
        return False
    if healthcheck(PC_ML_URL):
        return True
    with _ensure_lock:
        if healthcheck(PC_ML_URL):
            return True
        log("PC Immich ML endpoint unavailable; running pc-worker-ensure")
        try:
            subprocess.run(
                [ENSURE_SCRIPT],
                env={**os.environ, "CHECK_IMMICH_ML": "true", "IMMICH_ML_URL": PC_ML_URL},
                timeout=ENSURE_TIMEOUT,
                check=False,
            )
        except Exception as exc:
            log(f"pc-worker-ensure failed: {exc}")
        return healthcheck(PC_ML_URL)


def touch_last_request() -> None:
    try:
        os.makedirs(os.path.dirname(LAST_REQUEST_FILE), exist_ok=True)
        with open(LAST_REQUEST_FILE, "a", encoding="utf-8"):
            os.utime(LAST_REQUEST_FILE, None)
    except Exception as exc:
        log(f"failed to update last request marker: {exc}")


def write_active_requests() -> None:
    try:
        os.makedirs(os.path.dirname(ACTIVE_REQUESTS_FILE), exist_ok=True)
        with open(ACTIVE_REQUESTS_FILE, "w", encoding="utf-8") as handle:
            handle.write(f"{_active_requests}\n")
    except Exception as exc:
        log(f"failed to update active request marker: {exc}")


def begin_active_request() -> None:
    global _active_requests
    with _active_lock:
        _active_requests += 1
        write_active_requests()


def end_active_request() -> None:
    global _active_requests
    with _active_lock:
        _active_requests = max(0, _active_requests - 1)
        write_active_requests()


def record_non_health_request() -> int:
    now = time()
    cutoff = now - BULK_WINDOW_SECONDS
    touch_last_request()
    with _request_lock:
        _request_times.append(now)
        while _request_times and _request_times[0] < cutoff:
            _request_times.pop(0)
        return len(_request_times)


def should_use_pc_ml() -> bool:
    request_count = record_non_health_request()
    if request_count < BULK_REQUEST_THRESHOLD:
        if healthcheck(LOCAL_ML_URL):
            log(
                f"Using local Immich ML for request {request_count}/"
                f"{BULK_REQUEST_THRESHOLD} in {BULK_WINDOW_SECONDS}s bulk window"
            )
            return False
        log("Local Immich ML unavailable for real request; ensuring PC ML")
        return ensure_pc_ml()
    return ensure_pc_ml()


def is_healthcheck_path(path: str) -> bool:
    return path.split("?", 1)[0] in {"/ping", "/health", "/healthcheck"}


def choose_target(path: str) -> str | None:
    if is_healthcheck_path(path):
        if healthcheck(LOCAL_ML_URL):
            return LOCAL_ML_URL
        if healthcheck(PC_ML_URL):
            return PC_ML_URL
        return None

    if should_use_pc_ml():
        return PC_ML_URL
    return LOCAL_ML_URL


class ProxyHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self):
        self.proxy()

    def do_POST(self):
        self.proxy()

    def do_PUT(self):
        self.proxy()

    def do_PATCH(self):
        self.proxy()

    def do_DELETE(self):
        self.proxy()

    def send_proxy_error(self, code: int, message: str) -> None:
        try:
            self.send_error(code, message)
        except (BrokenPipeError, ConnectionResetError):
            log(f"client disconnected while sending {code} {message}")

    def proxy(self):
        tracked_request = not is_healthcheck_path(self.path)
        if tracked_request:
            begin_active_request()
        try:
            target = choose_target(self.path)
            if target is None or (target == LOCAL_ML_URL and not FALLBACK_TO_LOCAL):
                self.send_proxy_error(503, "PC Immich ML endpoint unavailable")
                return

            scheme, host, port = split_target(target)
            conn_cls = http.client.HTTPSConnection if scheme == "https" else http.client.HTTPConnection
            length = int(self.headers.get("Content-Length", "0") or "0")
            body = self.rfile.read(length) if length else None
            headers = {k: v for k, v in self.headers.items() if k.lower() not in {"host", "connection"}}

            conn = conn_cls(host, port, timeout=300)
            try:
                conn.request(self.command, self.path, body=body, headers=headers)
                resp = conn.getresponse()
                data = resp.read()
                self.send_response(resp.status, resp.reason)
                for key, value in resp.getheaders():
                    if key.lower() not in {"transfer-encoding", "connection", "content-length"}:
                        self.send_header(key, value)
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)
            except Exception as exc:
                log(f"proxy request failed against {target}: {exc}")
                if target != LOCAL_ML_URL and FALLBACK_TO_LOCAL:
                    self.proxy_to_local(body, headers)
                else:
                    self.send_proxy_error(502, "ML proxy request failed")
            finally:
                conn.close()
        finally:
            if tracked_request:
                end_active_request()

    def proxy_to_local(self, body, headers):
        scheme, host, port = split_target(LOCAL_ML_URL)
        conn_cls = http.client.HTTPSConnection if scheme == "https" else http.client.HTTPConnection
        conn = conn_cls(host, port, timeout=300)
        try:
            conn.request(self.command, self.path, body=body, headers=headers)
            resp = conn.getresponse()
            data = resp.read()
            self.send_response(resp.status, resp.reason)
            for key, value in resp.getheaders():
                if key.lower() not in {"transfer-encoding", "connection", "content-length"}:
                    self.send_header(key, value)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        except Exception as exc:
            log(f"local ML fallback failed: {exc}")
            self.send_proxy_error(502, "Local ML fallback failed")
        finally:
            conn.close()

    def log_message(self, fmt, *args):
        log("%s - %s" % (self.address_string(), fmt % args))


if __name__ == "__main__":
    server = ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), ProxyHandler)
    log(f"Immich ML wake proxy listening on {LISTEN_HOST}:{LISTEN_PORT}")
    server.serve_forever()

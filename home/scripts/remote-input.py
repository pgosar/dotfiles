#!/usr/bin/env python3
"""Send named Linux input events through /dev/uinput.

The key map is read from linux/input-event-codes.h at runtime.  This keeps the
tool aligned with the installed kernel and supports every KEY_* and BTN_* code,
including media keys, function keys, mouse buttons, and gamepad buttons.

Examples:
  remote-input.py KEY_A
  printf 'tap KEY_ENTER\ndown KEY_LEFT\nup KEY_LEFT\n' | remote-input.py
  remote-input.py --move -500 120
  remote-input.py --list | rg '^KEY_F'
"""

from __future__ import annotations

import argparse
import fcntl
import os
import re
import signal
import struct
import sys
import time
from pathlib import Path


EV_SYN = 0x00
EV_KEY = 0x01
EV_REL = 0x02
SYN_REPORT = 0
BUS_USB = 0x03
KEY_MAX = 0x2FF
UINPUT_MAX_NAME_SIZE = 80
REL_X = 0x00
REL_Y = 0x01


def _ioc(direction: int, type_: int, number: int, size: int) -> int:
    return (direction << 30) | (size << 16) | (type_ << 8) | number


def _io(type_: int, number: int) -> int:
    return _ioc(0, type_, number, 0)


def _iow(type_: int, number: int, size: int = 4) -> int:
    return _ioc(1, type_, number, size)


UI_DEV_CREATE = _io(ord("U"), 1)
UI_DEV_DESTROY = _io(ord("U"), 2)
UI_DEV_SETUP = _iow(ord("U"), 3, 92)
UI_SET_EVBIT = _iow(ord("U"), 100)
UI_SET_KEYBIT = _iow(ord("U"), 101)
UI_SET_RELBIT = _iow(ord("U"), 102)

HEADER_PATHS = (
    Path("/usr/include/linux/input-event-codes.h"),
    Path("/usr/include/linux/input.h"),
)


def read_keymap() -> dict[str, int]:
    """Return all integer KEY_* and BTN_* definitions from kernel headers."""
    definitions: dict[str, str] = {}
    for path in HEADER_PATHS:
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            match = re.match(r"\s*#define\s+([A-Z][A-Z0-9_]*)\s+(.+?)\s*(?:/\*.*)?$", line)
            if not match:
                continue
            name, value = match.groups()
            if name.startswith(("KEY_", "BTN_")):
                definitions[name] = value.strip()

    resolved: dict[str, int] = {}

    def resolve(name: str, seen: set[str] | None = None) -> int | None:
        if name in resolved:
            return resolved[name]
        if name not in definitions:
            return None
        seen = seen or set()
        if name in seen:
            return None
        seen.add(name)
        value = definitions[name].strip("()")
        value = re.sub(r"[uUlL]+$", "", value)
        try:
            result = int(value, 0)
        except ValueError:
            result = resolve(value, seen)
        if result is not None:
            resolved[name] = result
        return result

    for name in definitions:
        resolve(name)
    return dict(sorted(resolved.items()))


def aliases(keymap: dict[str, int]) -> dict[str, int]:
    result = dict(keymap)
    for name, code in keymap.items():
        if name.startswith("KEY_"):
            short = name[4:]
            result.setdefault(short, code)
            result.setdefault(short.lower(), code)
    result.update({"MOUSE1": keymap.get("BTN_LEFT", -1), "MOUSE2": keymap.get("BTN_RIGHT", -1), "MOUSE3": keymap.get("BTN_MIDDLE", -1)})
    return {name: code for name, code in result.items() if code >= 0}


def parse_key(token: str, keymap: dict[str, int]) -> int:
    try:
        code = int(token, 0)
    except ValueError:
        code = keymap.get(token, keymap.get(token.upper(), -1))
        if code < 0 and not token.upper().startswith(("KEY_", "BTN_")):
            code = keymap.get(f"KEY_{token.upper()}", -1)
    if not 0 <= code <= KEY_MAX:
        raise ValueError(f"unknown key {token!r}; use --list to see available names")
    return code


class UInputKeyboard:
    def __init__(self, device: str, name: str) -> None:
        self.fd = os.open(device, os.O_WRONLY | os.O_NONBLOCK)
        try:
            fcntl.ioctl(self.fd, UI_SET_EVBIT, EV_KEY)
            fcntl.ioctl(self.fd, UI_SET_EVBIT, EV_REL)
            for code in range(KEY_MAX + 1):
                fcntl.ioctl(self.fd, UI_SET_KEYBIT, code)
            fcntl.ioctl(self.fd, UI_SET_RELBIT, REL_X)
            fcntl.ioctl(self.fd, UI_SET_RELBIT, REL_Y)
            setup = struct.pack(
                "80sHHHHI",
                name.encode("utf-8")[: UINPUT_MAX_NAME_SIZE - 1],
                BUS_USB,
                0x1234,
                0xC0DE,
                1,
                0,
            )
            fcntl.ioctl(self.fd, UI_DEV_SETUP, setup)
            fcntl.ioctl(self.fd, UI_DEV_CREATE)
            time.sleep(0.15)
        except BaseException:
            os.close(self.fd)
            raise

    def event(self, code: int, value: int) -> None:
        event = struct.pack("llHHi", 0, 0, EV_KEY, code, value)
        sync = struct.pack("llHHi", 0, 0, EV_SYN, SYN_REPORT, 0)
        os.write(self.fd, event + sync)

    def tap(self, code: int, hold_ms: float) -> None:
        self.event(code, 1)
        time.sleep(hold_ms / 1000)
        self.event(code, 0)

    def move(self, x: int, y: int) -> None:
        event_x = struct.pack("llHHi", 0, 0, EV_REL, REL_X, x)
        event_y = struct.pack("llHHi", 0, 0, EV_REL, REL_Y, y)
        sync = struct.pack("llHHi", 0, 0, EV_SYN, SYN_REPORT, 0)
        os.write(self.fd, event_x + event_y + sync)

    def close(self) -> None:
        if self.fd >= 0:
            try:
                fcntl.ioctl(self.fd, UI_DEV_DESTROY)
            finally:
                os.close(self.fd)
                self.fd = -1


def parse_command(line: str, default_hold_ms: float, keymap: dict[str, int]) -> tuple[str, int, float]:
    fields = line.split()
    if not fields or fields[0].startswith("#"):
        raise EOFError
    if fields[0] == "move":
        if len(fields) != 3:
            raise ValueError("move requires horizontal and vertical pixel offsets")
        try:
            return "move", int(fields[1]), float(int(fields[2]))
        except ValueError as error:
            raise ValueError("move offsets must be integers") from error
    if fields[0] in {"tap", "down", "up"}:
        action = fields.pop(0)
    else:
        action = "tap"
    if not fields:
        raise ValueError("missing key name")
    hold_ms = float(fields[1]) if action == "tap" and len(fields) > 1 else default_hold_ms
    if len(fields) > (2 if action == "tap" else 1):
        raise ValueError("too many fields")
    return action, parse_key(fields[0], keymap), hold_ms


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("keys", nargs="*", help="key names or numeric codes to tap")
    parser.add_argument("--device", default="/dev/uinput", help="uinput device path")
    parser.add_argument("--hold-ms", type=float, default=80, help="tap duration in milliseconds")
    parser.add_argument("--move", nargs=2, type=int, metavar=("DX", "DY"), help="move the virtual pointer by relative pixel offsets")
    parser.add_argument("--name", default="remote-input", help="virtual input device name")
    parser.add_argument("--list", action="store_true", help="list every KEY_* and BTN_* mapping")
    parser.add_argument("--dry-run", action="store_true", help="validate and print commands without sending them")
    args = parser.parse_args()

    keymap = aliases(read_keymap())
    if not keymap:
        parser.error("could not read Linux input-event-codes.h")
    if args.list:
        for name, code in sorted(read_keymap().items(), key=lambda item: (item[1], item[0])):
            print(f"{name:<32} {code}")
        return 0

    if args.move is not None:
        lines = [f"move {args.move[0]} {args.move[1]}"]
    else:
        lines = args.keys or [line.rstrip() for line in sys.stdin]
    try:
        commands = [parse_command(line, args.hold_ms, keymap) for line in lines]
    except EOFError:
        commands = []
    except ValueError as error:
        parser.error(str(error))

    if not commands:
        parser.error("provide a key or commands on standard input")
    if args.dry_run:
        for action, code, hold_ms in commands:
            if action == "move":
                print(f"move {code} {int(hold_ms)}")
            else:
                print(f"{action} {code}" + (f" {hold_ms:g}ms" if action == "tap" else ""))
        return 0

    keyboard = UInputKeyboard(args.device, args.name)
    signal.signal(signal.SIGINT, lambda *_: keyboard.close())
    signal.signal(signal.SIGTERM, lambda *_: keyboard.close())
    try:
        for action, code, hold_ms in commands:
            if action == "tap":
                keyboard.tap(code, hold_ms)
            elif action == "move":
                keyboard.move(code, int(hold_ms))
            else:
                keyboard.event(code, 1 if action == "down" else 0)
    finally:
        keyboard.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

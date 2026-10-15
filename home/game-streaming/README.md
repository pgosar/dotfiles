# Game streaming: PC to MacBook, monitors off

Sunshine on the gaming PC (stealth) streams to Moonlight on the MacBook.
The trick: Sunshine never captures a real monitor. It captures a fake
one, so the real panels stay dark the whole time — during the stream
and after it.

## The phantom display

The PC's graphics card has an unused DisplayPort socket (DP-3). Two
kernel parameters turn it into a phantom display:

- `video=DP-3:e` forces the socket on even with nothing plugged in.
- `drm.edid_firmware=DP-3:edid/phantom.bin` feeds it a copy of the main
  monitor's EDID (an MSI MPG 321URX), with the serial number changed so
  KDE treats it as a separate screen.

Without this, the normal trick — putting the panels to sleep — does not
work: Sunshine feeds the stream's keyboard and mouse input into the PC
as local input, and any input wakes the panels back up. A disabled
panel cannot be woken by input at all.

## How a stream runs

1. Open **Moonlight Wake** on the Mac. It asks the NAS to run its wake
   script (the PC wakes, its panels stay dark), then switches the PC
   to stream mode and opens Moonlight once Sunshine answers.
2. Stream mode (`stream-mode.sh` on the PC): only the phantom is on —
   3840x2160 at 120 Hz, scaled 1.5, the same 2560x1440 logical desktop
   as the desk. The real panels are disabled. Sunshine restarts after
   the switch because it only maps displays correctly at startup.
3. `phantom-watcher.sh` runs alongside. When the stream's network
   flows end and stay gone for about 3 minutes, it restores the desk.
   If no stream starts within 10 minutes, it restores the desk too.
4. Desk mode (`desk-mode.sh`): the main panel (DP-2, 3840x2160 at
   240 Hz, HDR on) and the second panel (DP-1) come back, the phantom
   turns off — and then the panels are put straight back to sleep.
   They stay dark until a real keyboard or mouse is used at the desk.
   **PC Desk Mode** on the Mac runs the same restore on demand.

Sunshine itself is pinned to the phantom in
`~/.config/sunshine/sunshine.conf`: `output_name = DP-3`. That is why
opening Moonlight directly while the PC sits in the desk layout fails
with error 503 — there is no phantom to capture. Use Moonlight Wake.

## Limits

- The phantom tops out at 3840x2160 at 120 Hz. The 240 Hz mode needs a
  real cable link, and the MacBook screen is 120 Hz anyway.
- No HDR on the phantom: the graphics driver rejects HDR on a forced
  connector. This also fixed the washed-out colours from before — the
  stream is now plain SDR end to end instead of an HDR picture squeezed
  into SDR.

## Install

This folder lives in the dotfiles repo at `home/game-streaming/`. The
repo's main installer sets it up on its own: running `./install.sh`
from the repo root runs the right installer for the machine it is on
(the PC one on Linux, the Mac one on macOS), and a failure in this
feature does not stop the rest of the install.

To set up just this feature by hand, run the installer for the machine
from this folder. On the PC (Arch/CachyOS, needs sudo):

    ./pc/install-pc.sh

Then reboot so the phantom comes up. Sunshine must be installed and
its user service enabled in the desktop session.

On the Mac:

    ./mac/install-mac.sh

This installs the two scripts to `~/.local/bin` and rebuilds the two
launcher apps in `~/Applications` with `osacompile`. The launchers
reach the PC through the NAS, using the SSH key
`~/.ssh/id_ed25519_nas`.

The scripts are written for this exact setup — user `chilly`, DP-2 as
the main panel, DP-1 as the second, DP-3 as the phantom. They are a
record of how this machine is set up, not a general tool.

## Roll back

On the PC:

1. `sudo cp /etc/default/grub.bak-phantom /etc/default/grub`
2. Remove `/etc/mkinitcpio.conf.d/20-phantom-edid.conf` and
   `/usr/lib/firmware/edid/phantom.bin`
3. `sudo mkinitcpio -P && sudo grub-mkconfig -o /boot/grub/grub.cfg`
4. Reboot. The phantom is gone.
5. Optional cleanup: delete `stream-mode.sh`, `desk-mode.sh` and
   `phantom-watcher.sh` from `~/.local/bin`, and the one line in
   `~/.config/sunshine/sunshine.conf`.

On the Mac: delete **Moonlight Wake** and **PC Desk Mode** from
`~/Applications`, and `moonlight-wake.sh` and `pc-desk-mode.sh` from
`~/.local/bin`.

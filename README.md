# Razer Seiren V3 gain control on Linux

Control the hardware gain of a Razer Seiren V3 / V3 Chroma on PipeWire, and
remember the level across reboots.

openrazer does not handle the microphone gain. The gain is a standard USB Audio
control (`Mic Capture Volume`, -17.62 dB to +15 dB), and PipeWire's input volume
already maps onto it. This repo adds a small CLI for setting gain in real
decibels and a login service that re-applies the saved value, because
WirePlumber's route-state restore tends to reset the level to maximum.

## Requirements

- PipeWire + WirePlumber (`wpctl`, `pw-dump`)
- Python 3
- Linux with `/proc/asound` (tested on NixOS 26.11)

## Install

```bash
./install.sh
```

This copies `siren-gain` to `~/.local/bin`, installs the user service, and
enables it.

## Usage

```bash
siren-gain                 # show current/saved gain and hardware range
siren-gain -6              # set -6 dB and remember it
siren-gain 0               # set 0 dB
siren-gain --save-current  # remember the current gain
siren-gain --apply         # apply the saved gain (used by the login service)
```

The saved value lives in `~/.config/siren-gain/gain-db`.

## How it works

PipeWire exposes the hardware control through the source node volume:

```
dB = dBmax + 60 * log10(volume)
```

The script reads `dBmin`/`dBmax` from `/proc/asound/card*/usbmixer`, converts
between dB and the PipeWire volume, and applies it with `wpctl set-volume`.
Because it goes through PipeWire, the GNOME input slider and `wpctl` stay in
sync with the same hardware gain.

The login service (`siren-gain.service`) runs `siren-gain --apply` after
WirePlumber starts, waiting for the device and confirming the value sticks.

## Notes

- If you change gain from the GNOME Sound settings slider, run
  `siren-gain --save-current` so the saved value matches.
- Adjust the service name in `siren-gain` if you have a non-Chroma V3 that
  reports a different node name. The matcher looks for `razer` + `seiren` in
  the source node name.

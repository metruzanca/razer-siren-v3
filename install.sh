#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -Dm755 "$here/siren-gain" "$HOME/.local/bin/siren-gain"
install -Dm644 "$here/siren-gain.service" "$HOME/.config/systemd/user/siren-gain.service"

systemctl --user daemon-reload
systemctl --user enable --now siren-gain.service

echo "Installed. Current gain:"
"$HOME/.local/bin/siren-gain"

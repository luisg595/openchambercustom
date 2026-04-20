#!/bin/sh
set -eu

config_root="${1:-/root/.config/opencode}"
template_root="${2:-/opt/openchamber/config-template}"

mkdir -p "$config_root"

copy_if_missing() {
  src="$1"
  dest="$2"

  if [ -f "$src" ] && [ ! -f "$dest" ]; then
    cp "$src" "$dest"
  fi
}

copy_if_missing "$template_root/opencode.json" "$config_root/opencode.json"
copy_if_missing "$template_root/opencode.json.example" "$config_root/opencode.json.example"
copy_if_missing "$template_root/oh-my-opencode-slim.json" "$config_root/oh-my-opencode-slim.json"
copy_if_missing "$template_root/oh-my-opencode-slim.json.example" "$config_root/oh-my-opencode-slim.json.example"

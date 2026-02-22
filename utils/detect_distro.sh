#!/usr/bin/env bash

detect_distro() {
  local id=""

  if [ -r /etc/os-release ]; then
    . /etc/os-release
    id=${ID:-$NAME}
  elif command -v lsb_release >/dev/null 2>&1; then
    id=$(lsb_release -si 2>/dev/null)
  elif [ -r /etc/lsb-release ]; then
    . /etc/lsb-release
    id=${DISTRIB_ID:-$DISTRIB_DESCRIPTION}
  elif [ -r /etc/issue ]; then
    id=$(head -n1 /etc/issue 2>/dev/null)
  fi

  id=$(printf '%s' "${id:-unknown}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
  DISTRO=${id:-unknown}
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  detect_distro
  printf '%s\n' "$DISTRO"
fi


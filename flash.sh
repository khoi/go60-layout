#!/bin/bash

set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
firmware=${1:-"$root/go60.uf2"}
volume_root=/Volumes

fail() {
  printf '\nError: %s\n' "$1" >&2
  exit 1
}

wait_for_volume() {
  local label=$1
  local volume

  printf 'Waiting for %s' "$label" >&2
  while true; do
    for volume in "$volume_root"/"$label"*; do
      if [[ -d "$volume" ]]; then
        printf '\n' >&2
        printf '%s\n' "$volume"
        return
      fi
    done
    printf '.' >&2
    sleep 1
  done
}

wait_for_disconnect() {
  local volume=$1
  local attempt

  for ((attempt = 0; attempt < 30; attempt += 1)); do
    [[ ! -d "$volume" ]] && return
    sleep 1
  done
  return 1
}

flash_half() {
  local side=$1
  local label=$2
  local shortcut=$3
  local position=$4
  local volume
  local copied=false

  printf '\n%s half\n' "$side"
  printf '1. Switch the %s half off.\n' "$side"
  printf '2. Connect its USB-C cable to this Mac.\n'
  printf '3. Hold T3 (innermost %s thumb key) and C3R3 (physical %s key).\n' "$side" "$position"
  printf '4. While holding both keys, switch the half on.\n'
  printf '5. Release them when the red LED slowly pulses.\n'
  printf '   If the current firmware works, you can instead press %s.\n\n' "$shortcut"

  volume=$(wait_for_volume "$label")
  printf 'Found %s\n' "$volume"
  printf 'Copying %s...\n' "$(basename "$firmware")"

  if cp "$firmware" "$volume/go60.uf2"; then
    copied=true
  fi

  if [[ $copied == false && -d "$volume" ]]; then
    fail "copy failed while $label remained mounted"
  fi

  printf 'Waiting for the bootloader to finish'
  if wait_for_disconnect "$volume"; then
    printf '\n%s half flashed.\n' "$side"
    return
  fi

  printf '\n'
  fail "$label did not disconnect after receiving the firmware"
}

trap 'printf "\nCancelled. No further halves were changed.\n"; exit 130' INT TERM

[[ $(uname -s) == Darwin ]] || fail "flash.sh currently requires macOS"
[[ -d $volume_root ]] || fail "$volume_root is unavailable"
[[ -s $firmware ]] || fail "firmware not found at $firmware; run ./build.sh first"
[[ ${firmware##*.} =~ ^[uU][fF]2$ ]] || fail "firmware must have a .uf2 extension"

printf 'GO60 firmware flash\n'
printf 'Firmware: %s\n' "$firmware"
printf 'Both halves must receive this file. Keep this terminal open.\n'
printf 'Press Control-C at any time to stop waiting.\n'

flash_half right GO60RHBOOT 'Magic + \' K

printf '\nDisconnect the right half, then prepare the left half.\n'
read -r -p 'Press Return to continue: '

flash_half left GO60LHBOOT 'Magic + Tab' D

printf '\nBoth halves are flashed.\n'
printf 'Disconnect USB, switch both halves off, then switch both on.\n'
printf 'If pairing or settings behave unexpectedly, factory-reset and re-pair both halves.\n'

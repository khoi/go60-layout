# Go60 keyboard layout

My personal firmware for the Moergo Go60 layout

## Build

Requires Docker.

```sh
./build.sh
```

The combined firmware is written to `go60.uf2`.

## Render layers

```sh
./render-layers
```

The interactive layer map is written to `~/Downloads/GO60 Layers.html`.

## Update the layout

Export the latest ZMK keymap from the Layout Editor, replace `config/go60.keymap`, then rebuild. The JSON export is only needed for restoring the Layout Editor workspace.

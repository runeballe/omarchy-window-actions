# Window Actions for Omarchy

A bar widget for the [Omarchy](https://omarchy.org/) shell that closes, maximizes, or minimizes the active window.

Click the 󰖲 icon to open a popup with three buttons:

| Button | Action |
|---|---|
| 󰅖 Close window | Closes the window |
| 󰊓 Maximize window | Toggles maximized (the bar stays visible) |
| 󰖰 Minimize window | Moves the window to `special:minimized` |

The popup acts on the window that was active when you clicked the icon, and shows its title.

## Install

```bash
git clone https://github.com/runeballe/omarchy-window-actions ~/.config/omarchy/plugins/rune.window-actions
omarchy bar put rune.window-actions
```

Needs `hyprctl` and `jq`, both included with Omarchy.

## Minimize

Minimize uses `~/.local/bin/minimize-window minimize` if that script exists. That script also works on tiled workspaces.

Otherwise it uses Omarchy's `omarchy-hyprland-window-minimize`, which works on floating workspaces only.

## Command line

```bash
./window-action close    [address]
./window-action maximize [address]
./window-action minimize [address]
```

Without an address, the active window is used.

## Languages

Strings are in `i18n/`: English (`en.json`) and Norwegian (`no.json`). Add a file named after an Omarchy language code to translate it.

## License

MIT

# smart_crt_tv
A set of smart stuff and graphics to be played on a small black and white crt tv.

## Running on the Pi

```bash
nohup sudo startx /home/pi/processing-4.1.1/processing-java --sketch=/home/pi/Documents/smart_crt_tv --run &
```

**Use `--run`, never `--present`.** `--present` creates a fullscreen surface, and on the
interlaced composite mode (`video=Composite-1:720x576@50i`) a fullscreen page-flip is only
permitted on full-frame boundaries — every 2 fields — which caps the sketch at a hard 25 fps
no matter how little it draws. With `--run` it holds 50 fps.

`setup()` must have `size(720, 576, P2D)` active for this (not `fullScreen()`). No window
manager runs under `startx`, so the window sits undecorated at 0,0 on a 720×576 display and
looks identical to fullscreen.

Sketch stdout (including `println`) goes to `nohup.out` in the launch directory:

```bash
tail -f ~/nohup.out
```

Restart:

```bash
sudo pkill -f processing-java; sudo pkill -f startx
```

## Diagnostics overlay

`diagnostics` in `overscan.txt` turns on a readout in the overscan band showing frame rate
(one decimal), the smoothed `draw()` body time in ms, and the current program number. The body
time excludes the buffer swap, so a low ms figure alongside a low fps means the frame finishes
in time and the cost is in the present path, not in the drawing code.

Overscan values and the diagnostics flags are read live from `~/overscan.txt` — edit over SSH,
no rebuild needed.

## Local dev toggles

`smart_crt_tv.pde` carries working-tree edits for running on a desktop that should not be
committed: the `processing.io` / GPIO blocks are wrapped in
`/* !!!!!! GPIO RELATED: UN-COMMENT TO PUSH TO DEVICE */`, and the renderer in `size()` is
`P2D` for desktop vs `P3D` on the Pi. Stage feature hunks only.

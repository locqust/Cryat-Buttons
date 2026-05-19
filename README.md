# Crayt Buttons Installation Guide
Version 1.0 | For FrSky ETHOS 1.6.x | Tested on X20S

---

## SD Card Folder Structure

```
/scripts/
  Crayt Buttons/
    main.lua                  ← main widget
    Images/
      greenwifi.png           (32x32px - WiFi ON icon)
      redwifi.png             (32x32px - WiFi OFF icon)
      shuffle.png             (32x32px - Random ON icon)
      arrowlr.png             (32x32px - Random OFF icon)
      one.png                 (32x32px - Bank 1 indicator)
      two.png                 (32x32px - Bank 2 indicator)
      three.png               (32x32px - Bank 3 indicator)
      imuon.png               (32x32px - IMU/stabilisation ON icon)
      imuoff.png              (32x32px - IMU/stabilisation OFF icon)
    config/                   (folder must exist, files created automatically)
  Crayt Buttons Source/
    main.lua                  ← companion source script
```

---

## Step 1 - Copy Files to Radio

- Power on the radio
- Connect via USB, choose Ethos Suite on the radio screen
- Copy both folders above to `/scripts/` on the SD card
- Create the `/scripts/Crayt Buttons/config/` folder (empty, required)
- Copy all 9 image files into `/scripts/Crayt Buttons/Images/`
- Unplug USB, power cycle the radio

---

## Step 2 - Enable the LUA Source

- Main screen → tap the **Model** icon (plane) → **Edit Model**
- Scroll down to **Lua Sources** → tap it
- Tick **Crayt Buttons Source**
- Go back to the Model page

---

## Step 3 - Set Up the Mixer Channel

- Model page → **Mixer** → tap **+** → **Free Mix** → **Last Position**
- Set the **Name** to: `CRAYT BUTTONS`
- Tap **Source** → Category: **Lua** → select **Crayt Buttons Source**
- Scroll down to **Output1** → select a free channel (e.g. CH9)
- When asked to copy the mix name to the channel, tap **Yes**
- Go back to the main screen

---

## Step 4 - Add the Widget to a Screen

- Main screen → tap the **Display Edit** icon (grid symbol)
- Tap **+** to add a new screen
- Choose the **full screen** window layout (the large single panel option)
- Tap **Change Widget** → select **Crayt Buttons**
- Tap **Configure**

---

## Step 5 - Configure the Widget

In the Configure screen, set the following:

| Field | What to set |
|-------|-------------|
| Bank Toggle (3-position) | Your 3-position switch (e.g. SA, SB, SD) |
| WiFi Toggle Switch | Your WiFi on/off switch |
| Random Toggle Switch | Your random/shuffle switch |
| IMU Toggle Switch | Your stabilisation on/off switch |
| Button Pressed Colour | Colour shown when a button is tapped |
| B1 Btn 1 Name | Label for Bank 1, Button 1 (max ~10 chars single line, ~20 chars two lines separated by a space) |
| B1 Btn 1 Colour | Colour for Bank 1, Button 1 |
| ... repeat for all 45 buttons across 3 banks |

**Button naming tip:** A space in the name splits it across two lines on the button.
Example: `HAPPY SND` displays as HAPPY on line 1, SND on line 2.

**Toggle switches:** All toggles expect a standard 2 or 3 position switch.
Switch values are read on the -1024 to +1024 internal ETHOS scale:
- 3-position: low = -1024, mid = 0, high = +1024
- 2-position: off = -1024, on = +1024

---

## Step 6 - Teach the Crayt Board Button Values

The Crayt Buttons widget sends sBus values on the configured channel.
Use the Crayt board web interface to map each button:

1. Open the Crayt board web interface
2. Go to **Buttons Value** tab
3. With no buttons pressed, note the **sBus Value** shown — enter this in the **Released** field
4. Tap **Button 1** on the radio screen, note the sBus value, enter it in **Button 1**
5. Repeat for all buttons on Bank 1 (buttons 1-15)
6. Flip the bank toggle to Bank 2, repeat for buttons 1-15 (these are global buttons 16-30)
7. Flip to Bank 3, repeat for buttons 1-15 (global buttons 31-45)
8. Click **Save to Memory**

**Expected sBus values (approximate):**

| Button | sBus | Button | sBus |
|--------|------|--------|------|
| 1 | 176 | 9 | 652 |
| 2 | 244 | 10 | 788 |
| 3 | 311 | 11 | 856 |
| 4 | 379 | 12 | 924 |
| 5 | 448 | 13 | 1059 |
| 6 | 516 | 14 | 1127 |
| 7 | 584 | 15 | 1195 |
| 8 | 651 | Released | 992 |

These values are the same across all 3 banks — the bank toggle channel
tells the board which bank is active.

---

## Status Bar Icons

The bottom strip of the widget shows live status:

| Position | Icon | Meaning |
|----------|------|---------|
| Left | WiFi icon | Green = WiFi on, Red = WiFi off |
| Centre-left | Play/Shuffle | Shuffle = Random on, Play = Random off |
| Centre | Figure | IMU stabilisation on/off |
| Right | 1 / 2 / 3 | Currently active bank |

---

## Notes

- Button colours and labels are saved per model name automatically
  in `/scripts/Crayt Buttons/config/YourModelName.txt`
- Switching models reloads the correct button config for that model
- The `Crayt Buttons Source` folder and its `main.lua` must remain
  separate from the `Crayt Buttons` folder — do not merge them
- Crayt Buttons can coexist with Kyberpad on the same radio — assign
  each to different models, both scripts use different keys and folders
- ETHOS source values use a -1024 to +1024 internal scale (not -100 to +100)
- The widget requires ETHOS 1.6.x or later

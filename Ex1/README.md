# GeoCardGame – Ex1

A location-based two-player card game built with **UIKit + Storyboard** for iOS.

The player's side (West or East) is determined automatically by the device's longitude. The game then plays 10 rounds of a "high card wins" duel against the PC, and shows a summary screen with the winner.

---

## Demo Video

📹 **Watch the demo:** [demo.mov](./demo.mov)

https://github.com/SagiDreshman/hw1/raw/main/demo.mov

---

## Features

- **Menu screen** – name input (saved with `UserDefaults`), START button.
- **CoreLocation** – samples the device location on every launch.
  - `longitude ≥ 34.817549168324334` → East Side
  - `longitude <  34.817549168324334` → West Side
- **Game screen** – fully automatic, no user interaction during play:
  - 5 seconds with face-down cards.
  - 3 seconds with face-up cards.
  - Repeats for 10 rounds.
  - Equal cards are ignored.
  - The house (PC) wins ties at game end.
- **Summary screen** – winner and final score, with `BACK TO MENU` button.
- **Lifecycle** – the countdown timer pauses when the app moves to the background and resumes when it returns to the foreground.
- **Landscape only**, 52 real playing card images, animated card backs.

---

## Screens

| Menu | Game | Summary |
|------|------|---------|
| _[screenshot]_ | _[screenshot]_ | _[screenshot]_ |

---

## How to Run

1. Open `Ex1.xcodeproj` in Xcode 15+.
2. Select an iPhone simulator (any model) – **landscape orientation**.
3. Press **⌘R** to build and run.
4. In the simulator, set a mock location via **Features → Location → Custom Location...**
   - West Side: e.g. lat `32.08`, lng `34.78` (Tel Aviv).
   - East Side: e.g. lat `31.78`, lng `35.21` (Jerusalem).

> The first time the app launches it will ask for location permission and a player name.

---

## Project Structure

```
Ex1/
├── ViewController.swift          – Menu (name + location + START)
├── GameViewController.swift      – Game logic (timers, rounds, scoring)
├── SummaryViewController.swift   – Winner + score + back to menu
├── AppDelegate.swift / SceneDelegate.swift
├── Info.plist                    – Location usage + landscape only
├── Base.lproj/Main.storyboard    – 3 scenes with segues
└── Assets.xcassets               – 52 card images, card back, West/East globes
```

---

## Tech Stack

- **Language:** Swift 5
- **UI:** UIKit + Storyboards + Auto Layout
- **Location:** CoreLocation (`CLLocationManager`)
- **Persistence:** `UserDefaults` for the player name
- **Min iOS:** 17

---

## Author

Created by **Sagi Dreshman** as part of the iOS development course – Assignment 1.

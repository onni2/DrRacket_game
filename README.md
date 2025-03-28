# Maze Escape Game in Racket

A simple maze navigation game where players guide a red character through a maze to reach a green exit, avoiding walls and obstacles.

## Prerequisites
- Racket programming language (v8.0+)
- DrRacket IDE (recommended)
- 2htdp libraries (included with Racket installation)

## Installation
1. Save the code as `maze-game.rkt`
2. Open in DrRacket
3. Ensure language is set to "Deterministic" (via `#lang racket` at file start)

## How to Play
- Run the program (click "Run" in DrRacket)
- Use arrow keys to move:
  - ↑/↓: Move up/down
  - ←/→: Move left/right
- Objective: Reach the green exit square
- Collision detection prevents wall penetration
- Win screen appears on successful escape

## Features
- Predefined complex maze structure
- Smooth character movement
- Wall collision detection
- Visual feedback for win condition
- Responsive controls
- Clean visual design with:
  - Black walls
  - Red player character
  - Green exit marker

## Code Structure
```racket
#lang racket
(require 2htdp/image)
(require 2htdp/universe)

;; [Game constants definition]
;; [Maze structure]
;; [Collision detection system]
;; [Movement handling]
;; [Rendering system]
;; [Game world setup]

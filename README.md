# Kanban

A World of Warcraft addon for WoW Classic Anniversary featuring a kanban-style to-do list

## Features

- Kanban-style to-do list with three columns: To-Do, In Progress, and Done
- Drag and drop functionality (planned)
- Persistent data storage
- Clean, intuitive interface

## Installation

1. Download or clone this repository
2. Place the `Kanban` folder in your WoW Classic `Interface/AddOns/` directory
3. Restart WoW Classic or reload your UI (`/reload`)
4. The addon will automatically load

## Usage

- Type `/kanban` or `/kb` to open the kanban window
- The window can be moved by dragging the title bar
- Click the X button to close the window

## Development

This addon is built using vanilla WoW API with plans to integrate external libraries for enhanced functionality.

### Project Structure

```
Kanban/
├── Kanban.toc          # Addon metadata and file loading
├── Kanban.lua          # Main addon logic and slash commands
├── Kanban_GUI.lua      # GUI components and kanban board
├── libs/               # External libraries
└── README.md           # This file
```

### Required Libraries

The following libraries will be added to the `libs/` folder as development progresses:

- **LibStub** - Library management system
- **AceAddon-3.0** - Addon framework
- **AceGUI-3.0** - GUI framework
- **AceConfig-3.0** - Configuration system

## Version

Current version: 1.0.0
WoW Classic Interface: 11501
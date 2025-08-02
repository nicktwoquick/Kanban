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

This addon is built using the Ace3 framework and has been refactored into a modular structure for better maintainability and scalability.

### Refactoring Benefits

The addon has been refactored from a monolithic structure into focused modules:

- **Separation of Concerns**: Each module has a single, clear responsibility
- **Maintainability**: Easier to find and modify specific functionality
- **Testability**: Individual modules can be tested in isolation
- **Reusability**: Modules can be reused or extended independently
- **Scalability**: New features can be added as new modules

See `modules/README.md` for detailed module documentation.

### Project Structure

```
Kanban/
├── Kanban.toc              # Addon metadata and file loading
├── Kanban.lua              # Main addon logic and slash commands
├── Kanban_GUI.lua          # Legacy GUI loader (backward compatibility)
├── modules/                # Refactored modules
│   ├── Utils.lua           # Common utilities and constants
│   ├── TaskManager.lua     # Task data and CRUD operations
│   ├── UIComponents.lua    # Individual UI components
│   ├── Dialogs.lua         # Dialog windows
│   ├── Board.lua           # Main board layout and refresh
│   └── README.md           # Module documentation
├── libs/                   # External libraries
└── README.md               # This file
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
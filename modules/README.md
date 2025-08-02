# Kanban Modules

This directory contains the refactored modules for the Kanban addon, organized by responsibility.

## Module Structure

### `Utils.lua`
- **Purpose**: Common utilities and constants
- **Contains**: 
  - Debug function
  - Column configuration (To-Do, In Progress, Done)
  - Priority options (Low, Medium, High)

### `TaskManager.lua`
- **Purpose**: Task data management and CRUD operations
- **Contains**:
  - Task data structure
  - `getTasksByStatus()` - Get tasks by column
  - `getAllTasks()` - Get all tasks
  - `getTaskById()` - Get specific task
  - `moveTask()` - Move task between columns
  - `addTask()` - Create new task
  - `updateTask()` - Update existing task
  - `deleteTask()` - Remove task

### `UIComponents.lua`
- **Purpose**: Individual UI components
- **Contains**:
  - `createTaskCard()` - Create task card widget
  - `createColumn()` - Create column widget
  - Handles task card styling and move buttons

### `Dialogs.lua`
- **Purpose**: Dialog windows for user interaction
- **Contains**:
  - `ShowAddTaskDialog()` - Add new task dialog
  - `ShowEditTaskDialog()` - Edit existing task dialog
  - Form handling and validation

### `Board.lua`
- **Purpose**: Main board layout and refresh logic
- **Contains**:
  - `CreateKanbanBoard()` - Create the main board layout
  - `RefreshBoard()` - Refresh the entire board
  - Orchestrates columns and overall layout

## Benefits of This Structure

1. **Separation of Concerns**: Each module has a single, clear responsibility
2. **Maintainability**: Easier to find and modify specific functionality
3. **Testability**: Individual modules can be tested in isolation
4. **Reusability**: Modules can be reused or extended independently
5. **Scalability**: New features can be added as new modules

## Usage

Modules are loaded by the TOC file in order and made available as global tables. The main `Kanban.lua` file then attaches them to the addon object:

```lua
-- Modules are loaded by TOC file and available as:
-- _G.Kanban_Utils
-- _G.Kanban_TaskManager
-- _G.Kanban_UIComponents
-- _G.Kanban_Dialogs
-- _G.Kanban_Board

-- In Kanban.lua, they're attached to the addon:
self.Utils = _G.Kanban_Utils
self.TaskManager = _G.Kanban_TaskManager
-- ... etc
```

## Backward Compatibility

The original `Kanban_GUI.lua` file has been converted to a legacy loader that maintains compatibility with existing code while delegating to the new modules. 
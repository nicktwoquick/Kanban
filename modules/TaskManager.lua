-- Kanban TaskManager Module
-- Handles all task data and CRUD operations

local addonName, addon = ...

-- Import utilities
local Utils = _G.Kanban_Utils or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

-- Lazy database access - don't try to access it during module loading
local function getDB()
    return _G.Kanban and _G.Kanban.db
end

local tasks = {}
local nextTaskId = 1 -- Track the next available task ID

-- Initialize with sample data - we'll load from DB later when available
tasks = {
    {
        id = 1,
        title = "Sample Task",
        description = "This is a sample task to test the kanban board functionality.",
        status = "To-Do",
        created = time(),
        priority = "Medium"
    }
}

-- Function to load tasks from database when available
local function loadTasksFromDB()
    local db = getDB()
    if db and db.profile and db.profile.tasks then
        tasks = db.profile.tasks
        debug("Loaded " .. #tasks .. " tasks from database")
        
        -- Load nextTaskId from database, or calculate it if not available
        if db.profile.nextTaskId then
            nextTaskId = db.profile.nextTaskId
            debug("Loaded nextTaskId from database: " .. nextTaskId)
        else
            -- Fallback: calculate nextTaskId to be higher than any existing task ID
            nextTaskId = 1
            for _, task in ipairs(tasks) do
                if task.id >= nextTaskId then
                    nextTaskId = task.id + 1
                end
            end
            debug("Calculated nextTaskId: " .. nextTaskId)
        end
    else
        debug("No database or tasks found, using default sample task")
        nextTaskId = 2 -- Since we have the sample task with ID 1
    end
end

-- Function to save tasks to database when available
local function saveTasksToDB()
    local db = getDB()
    if db and db.profile then
        db.profile.tasks = tasks
        db.profile.nextTaskId = nextTaskId
        debug("Saved " .. #tasks .. " tasks to database with nextTaskId: " .. nextTaskId)
    else
        debug("Database not available, tasks not saved")
    end
end

-- Task management functions
local function getTasksByStatus(status)
    local result = {}
    for _, task in ipairs(tasks) do
        if task.status == status then
            table.insert(result, task)
        end
    end
    return result
end

local function getAllTasks()
    return tasks
end

local function getTaskById(taskId)
    debug("getTaskById called with taskId: " .. tostring(taskId))
    debug("Available tasks:")
    for i, task in ipairs(tasks) do
        debug("  " .. i .. ". ID=" .. task.id .. ", Title=" .. task.title)
        if task.id == taskId then
            debug("Found matching task: ID=" .. task.id .. ", Title=" .. task.title)
            return task
        end
    end
    debug("No task found with ID: " .. tostring(taskId))
    return nil
end

local function moveTask(taskId, newStatus)
    debug("moveTask called: ID=" .. taskId .. ", newStatus=" .. newStatus)
    debug("Current tasks count: " .. #tasks)

    for _, task in ipairs(tasks) do
        if task.id == taskId then
            local oldStatus = task.status
            task.status = newStatus
            saveTasksToDB() -- Save to database
            debug("Moved task '" .. task.title .. "' from " .. oldStatus .. " to " .. newStatus)
            debug("Task data after move: ID=" .. task.id .. ", Title=" .. task.title .. ", Status=" .. task.status)

            -- Debug: Show all tasks after the move
            debug("All tasks after move:")
            for i, t in ipairs(tasks) do
                debug("  " .. i .. ". ID=" .. t.id .. ", Title=" .. t.title .. ", Status=" .. t.status)
            end

            return true
        end
    end
    debug("Failed to move task with ID " .. taskId .. " to " .. newStatus)
    debug("Available task IDs: " .. table.concat({ unpack(tasks, 1, #tasks, function(t) return t.id end) }, ", "))
    return false
end

local function addTask(title, description, priority)
    local newTask = {
        id = nextTaskId,
        title = title,
        description = description,
        status = "To-Do",
        created = time(),
        priority = priority or "Medium"
    }
    table.insert(tasks, newTask)
    nextTaskId = nextTaskId + 1 -- Increment for next task
    saveTasksToDB() -- Save to database
    debug("Added new task: " .. title .. " with ID: " .. newTask.id)
    return newTask.id
end

local function updateTask(taskId, updates)
    for _, task in ipairs(tasks) do
        if task.id == taskId then
            for key, value in pairs(updates) do
                task[key] = value
            end
            saveTasksToDB() -- Save to database
            debug("Updated task: " .. task.title)
            return true
        end
    end
    return false
end

local function deleteTask(taskId)
    for i, task in ipairs(tasks) do
        if task.id == taskId then
            local title = task.title
            table.remove(tasks, i)
            saveTasksToDB() -- Save to database
            debug("Deleted task: " .. title)
            return true
        end
    end
    return false
end

local function clearAllTasks()
    local taskCount = #tasks
    tasks = {}
    saveTasksToDB() -- Save to database
    debug("Cleared all " .. taskCount .. " tasks")
    return true
end

-- Function to initialize the TaskManager (call this after database is ready)
local function initialize()
    loadTasksFromDB()
    debug("TaskManager initialized")
end

-- Export task manager
local TaskManager = {
    getTasksByStatus = getTasksByStatus,
    getAllTasks = getAllTasks,
    getTaskById = getTaskById,
    moveTask = moveTask,
    addTask = addTask,
    updateTask = updateTask,
    deleteTask = deleteTask,
    clearAllTasks = clearAllTasks,
    initialize = initialize
}

-- Make available globally
_G.Kanban_TaskManager = TaskManager

-- Attach to addon if available
if addon then
    addon.TaskManager = TaskManager
end

return TaskManager

-- Kanban TaskManager Module
-- Handles all task data and CRUD operations

local addonName, addon = ...

-- Import utilities
local Utils = _G.Kanban_Utils or {}
local debug = Utils.debug or function(msg) print("|cFF00FF00Kanban|r: " .. msg) end

-- Task data structure
local tasks = {
    {
        id = 1,
        title = "Sample Task",
        description = "This is a sample task to test the kanban board functionality.",
        status = "To-Do",
        created = time(),
        priority = "Medium"
    }
}

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
    for _, task in ipairs(tasks) do
        if task.id == taskId then
            return task
        end
    end
    return nil
end

local function moveTask(taskId, newStatus)
    debug("moveTask called: ID=" .. taskId .. ", newStatus=" .. newStatus)
    debug("Current tasks count: " .. #tasks)
    
    for _, task in ipairs(tasks) do
        if task.id == taskId then
            local oldStatus = task.status
            task.status = newStatus
            debug("Moved task '" .. task.title .. "' from " .. oldStatus .. " to " .. newStatus)
            debug("Task data after move: ID=" .. task.id .. ", Title=" .. task.title .. ", Status=" .. task.status)
            return true
        end
    end
    debug("Failed to move task with ID " .. taskId .. " to " .. newStatus)
    debug("Available task IDs: " .. table.concat({unpack(tasks, 1, #tasks, function(t) return t.id end)}, ", "))
    return false
end

local function addTask(title, description, priority)
    local newTask = {
        id = #tasks + 1,
        title = title,
        description = description,
        status = "To-Do",
        created = time(),
        priority = priority or "Medium"
    }
    table.insert(tasks, newTask)
    debug("Added new task: " .. title)
    return newTask.id
end

local function updateTask(taskId, updates)
    for _, task in ipairs(tasks) do
        if task.id == taskId then
            for key, value in pairs(updates) do
                task[key] = value
            end
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
            debug("Deleted task: " .. title)
            return true
        end
    end
    return false
end

local function clearAllTasks()
    local taskCount = #tasks
    tasks = {}
    debug("Cleared all " .. taskCount .. " tasks")
    return true
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
    clearAllTasks = clearAllTasks
}

-- Make available globally
_G.Kanban_TaskManager = TaskManager

-- Attach to addon if available
if addon then
    addon.TaskManager = TaskManager
end

return TaskManager 
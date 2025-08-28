local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "GUI_Maker"
gui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Active = true
mainFrame.Draggable = true

-- Close Button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = ""
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- UI Type Input
local uiType = Instance.new("TextBox", mainFrame)
uiType.PlaceholderText = "Enter UI Type (TextLabel, ImageLabel, Frame, TextButton, ImageButton, TextBox)"
uiType.Size = UDim2.new(0.6, 0, 0, 40)
uiType.Position = UDim2.new(0.05, 0, 0, 10)
uiType.TextScaled = true
uiType.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
uiType.TextColor3 = Color3.new(1, 1, 1)

-- Create Button
local createBtn = Instance.new("TextButton", mainFrame)
createBtn.Text = "Create UI Element"
createBtn.Size = UDim2.new(0.3, 0, 0, 40)
createBtn.Position = UDim2.new(0.65, 0, 0, 10)
createBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
createBtn.TextColor3 = Color3.new(1, 1, 1)

-- Explorer Panel
local explorer = Instance.new("ScrollingFrame", mainFrame)
explorer.Size = UDim2.new(0.3, 0, 0.7, 0)
explorer.Position = UDim2.new(0, 0, 0.15, 0)
explorer.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
explorer.CanvasSize = UDim2.new(0, 0, 5, 0)
explorer.Name = "Explorer"

-- Properties Panel
local properties = Instance.new("Frame", mainFrame)
properties.Size = UDim2.new(0.3, 0, 0.25, 0)
properties.Position = UDim2.new(0, 0, 0.85, 0)
properties.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
properties.Name = "Properties"
properties.Visible = false

local layout = Instance.new("UIListLayout", properties)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Selected UI reference
local selectedUI = nil

-- Property builder
local function addProperty(labelText, defaultText, onChange)
    local label = Instance.new("TextLabel", properties)
    label.Text = labelText
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)

    local input = Instance.new("TextBox", properties)
    input.Text = defaultText
    input.Size = UDim2.new(1, -10, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.ClearTextOnFocus = false
    input.FocusLost:Connect(function()
        onChange(input.Text)
    end)
end

-- Update Properties Panel
local function updateProperties(ui)
    for _, child in pairs(properties:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    properties.Visible = true

    if ui:IsA("TextLabel") or ui:IsA("TextButton") or ui:IsA("TextBox") then
        addProperty("Text", ui.Text or "", function(val)
            ui.Text = val
        end)
    end

    if ui:IsA("ImageLabel") or ui:IsA("ImageButton") then
        addProperty("Image ID", ui.Image or "", function(val)
            ui.Image = "rbxassetid://" .. val
        end)
    end

    addProperty("Position", tostring(ui.Position), function(val)
        local success, result = pcall(function() return loadstring("return " .. val)() end)
        if success and typeof(result) == "UDim2" then
            ui.Position = result
        end
    end)

    addProperty("Size", tostring(ui.Size), function(val)
        local success, result = pcall(function() return loadstring("return " .. val)() end)
        if success and typeof(result) == "UDim2" then
            ui.Size = result
        end
    end)

    if ui:IsA("TextButton") or ui:IsA("ImageButton") then
        addProperty("Button Script (Lua)", "", function(code)
            local func = loadstring(code)
            if func then
                ui.MouseButton1Click:Connect(function()
                    pcall(func)
                end)
            end
        end)
    end
end

-- Make UI draggable
local function makeDraggable(obj)
    obj.Active = true
    obj.Draggable = true
end

-- Create UI Element
createBtn.MouseButton1Click:Connect(function()
    local typeStr = uiType.Text
    local newUI
    pcall(function()
        newUI = Instance.new(typeStr)
    end)
    if not newUI then return end

    newUI.Size = UDim2.new(0.2, 0, 0.1, 0)
    newUI.Position = UDim2.new(math.random(), 0, math.random(), 0)
    newUI.Parent = gui
    newUI.Name = "Custom_" .. typeStr
    newUI.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    makeDraggable(newUI)

    -- Add to Explorer
    local item = Instance.new("TextButton", explorer)
    item.Size = UDim2.new(1, 0, 0, 30)
    item.Text = newUI.Name
    item.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    item.MouseButton1Click:Connect(function()
        selectedUI = newUI
        updateProperties(newUI)
    end)

    local deleteBtn = Instance.new("TextButton", item)
    deleteBtn.Text = ""
    deleteBtn.Size = UDim2.new(0, 30, 1, 0)
    deleteBtn.Position = UDim2.new(1, -30, 0, 0)
    deleteBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    deleteBtn.MouseButton1Click:Connect(function()
        newUI:Destroy()
        item:Destroy()
        properties.Visible = false
    end)
end)

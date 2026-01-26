-- ==========================
-- Matcha Drawing UI Library
-- ==========================
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UiLib = {}
UiLib.__index = UiLib

local function newDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Visible = true
    return obj
end

-- ==========================
-- Window
-- ==========================
function UiLib:CreateWindow(title, size)
    local win = {}
    setmetatable(win, self)

    size = size or Vector2.new(400, 300)
    local viewport = workspace.CurrentCamera.ViewportSize
    local position = Vector2.new(
        (viewport.X - size.X) / 2,
        (viewport.Y - size.Y) / 2
    )

    win.Position = position
    win.Size = size
    win.Dragging = false
    win.Elements = {}

    win.Frame = newDrawing("Square", {
        Size = size,
        Position = position,
        Color = Color3.fromRGB(25, 25, 25),
        Filled = true
    })

    win.TitleBar = newDrawing("Square", {
        Size = Vector2.new(size.X, 30),
        Position = position,
        Color = Color3.fromRGB(35, 35, 35),
        Filled = true
    })

    win.Title = newDrawing("Text", {
        Text = title or "UiLib",
        Size = 16,
        Position = position + Vector2.new(10, 7),
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true
    })

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UIS:GetMouseLocation()
            if mouse.X >= win.Position.X and mouse.X <= win.Position.X + win.Size.X
            and mouse.Y >= win.Position.Y and mouse.Y <= win.Position.Y + 30 then
                win.Dragging = true
                win.DragOffset = mouse - win.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            win.Dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if win.Dragging then
            local mouse = UIS:GetMouseLocation()
            win.Position = mouse - win.DragOffset
        end

        win.Frame.Position = win.Position
        win.TitleBar.Position = win.Position
        win.Title.Position = win.Position + Vector2.new(10, 7)

        for _, el in pairs(win.Elements) do
            el:Update()
        end
    end)

    return win
end

-- ==========================
-- Button
-- ==========================
function UiLib:AddButton(text, callback)
    local btn = {}
    btn.Parent = self

    local y = 40 + (#self.Elements * 35)

    btn.Box = newDrawing("Square", {
        Size = Vector2.new(self.Size.X - 20, 30),
        Position = self.Position + Vector2.new(10, y),
        Color = Color3.fromRGB(50, 50, 50),
        Filled = true
    })

    btn.Text = newDrawing("Text", {
        Text = text,
        Size = 15,
        Position = btn.Box.Position + Vector2.new(10, 7),
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true
    })

    function btn:Update()
        btn.Box.Position = self.Parent.Position + Vector2.new(10, y)
        btn.Text.Position = btn.Box.Position + Vector2.new(10, 7)
    end

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UIS:GetMouseLocation()
            local pos = btn.Box.Position
            local size = btn.Box.Size
            if mouse.X >= pos.X and mouse.X <= pos.X + size.X
            and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y then
                if callback then callback() end
            end
        end
    end)

    table.insert(self.Elements, btn)
end

-- ==========================
-- Toggle
-- ==========================
function UiLib:AddToggle(text, default, callback)
    local toggle = {}
    toggle.Parent = self

    local y = 40 + (#self.Elements * 35)
    toggle.State = default or false

    toggle.Box = newDrawing("Square", {
        Size = Vector2.new(self.Size.X - 20, 30),
        Position = self.Position + Vector2.new(10, y),
        Color = Color3.fromRGB(50, 50, 50),
        Filled = true
    })

    toggle.Indicator = newDrawing("Square", {
        Size = Vector2.new(20, 20),
        Position = toggle.Box.Position + Vector2.new(toggle.Box.Size.X - 30, 5),
        Color = toggle.State and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0),
        Filled = true
    })

    toggle.Text = newDrawing("Text", {
        Text = text,
        Size = 15,
        Position = toggle.Box.Position + Vector2.new(10, 7),
        Color = Color3.fromRGB(255, 255, 255),
        Outline = true
    })

    function toggle:Update()
        toggle.Box.Position = self.Parent.Position + Vector2.new(10, y)
        toggle.Text.Position = toggle.Box.Position + Vector2.new(10, 7)
        toggle.Indicator.Position = toggle.Box.Position + Vector2.new(toggle.Box.Size.X - 30, 5)
    end

    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UIS:GetMouseLocation()
            local pos = toggle.Box.Position
            local size = toggle.Box.Size
            if mouse.X >= pos.X and mouse.X <= pos.X + size.X
            and mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y then
                toggle.State = not toggle.State
                toggle.Indicator.Color = toggle.State and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(120, 0, 0)
                if callback then callback(toggle.State) end
            end
        end
    end)

    table.insert(self.Elements, toggle)
end

return UiLib

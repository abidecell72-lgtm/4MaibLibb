-- ============================================
-- ALTHERA UI LIBRARY (All-in-One)
-- Created by Cabu
-- ============================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- ============================================
-- 1. THEME
-- ============================================
local Theme = {
    colors = {
        bg      = Color3.fromHex("#0A0A0A"),
        panel   = Color3.fromHex("#121212"),
        card    = Color3.fromHex("#1A1A1A"),
        accent  = Color3.fromHex("#E0E0E0"),
        accent2 = Color3.fromHex("#FFFFFF"),
        text    = Color3.fromHex("#F5F5F5"),
        text2   = Color3.fromHex("#9E9E9E"),
        border  = Color3.fromHex("#2C2C2C"),
        danger  = Color3.fromHex("#FF4C4C"),
    },
    fonts = {
        bold = Enum.Font.GothamBold,
        body = Enum.Font.Gotham,
    }
}

-- ============================================
-- 2. RESPONSIVE
-- ============================================
local Responsive = {}

function Responsive.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Responsive.GetWindowSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = Responsive.IsMobile()
    local targetW = isMobile and 440 or 580
    local targetH = isMobile and 300 or 380
    local finalW = math.min(targetW, viewport.X - 40)
    local finalH = math.min(targetH, viewport.Y - 100)
    return UDim2.new(0, finalW, 0, finalH)
end

function Responsive.GetWindowPosition(size)
    return UDim2.new(0.5, -(size.X.Offset / 2), 0.5, -(size.Y.Offset / 2))
end

-- ============================================
-- 3. UTILS
-- ============================================
local function new(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    return obj
end

local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

-- ============================================
-- 4. CORE LIBRARY
-- ============================================
local Library = {}
Library.Theme = Theme
Library.Responsive = Responsive

function Library:CreateWindow(config)
    local Window = { Tabs = {}, ActiveTab = nil, TabButtons = {} }
    config = config or {}
    
    local isMobile = Responsive.IsMobile()
    local winSize = Responsive.GetWindowSize()
    local winPos = Responsive.GetWindowPosition(winSize)
    local topBarH = isMobile and 45 or 40

    Window.Gui = new("ScreenGui", { Name = "AltheraUI", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    Window.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- MAIN FRAME
    Window.Main = new("Frame", {
        Name = "Main", Size = winSize, Position = winPos, BackgroundColor3 = Theme.colors.bg, BorderSizePixel = 0,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 8) }),
        new("UIStroke", { Color = Theme.colors.border, Thickness = 1.5 }),
    })
    Window.Main.Parent = Window.Gui

    -- TOPBAR
    Window.TopBar = new("Frame", {
        Name = "TopBar", Size = UDim2.new(1, 0, 0, topBarH), BackgroundColor3 = Theme.colors.panel, BorderSizePixel = 0,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
    Window.TopBar.Parent = Window.Main

    -- Title
    new("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
        Text = config.Title or "ALTHERA UI", Font = Theme.fonts.bold, TextSize = isMobile and 13 or 15,
        TextColor3 = Theme.colors.text, TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = Window.TopBar

    -- Tombol Minimize [-]
    local minBtn = new("TextButton", {
        Size = UDim2.new(0, 36, 0, 30), Position = UDim2.new(1, -44, 0.5, -15),
        BackgroundColor3 = Theme.colors.card, Text = "[-]", Font = Theme.fonts.bold, TextSize = 14,
        TextColor3 = Theme.colors.text, AutoButtonColor = false,
    }, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    minBtn.Parent = Window.TopBar
    
    minBtn.MouseEnter:Connect(function() tween(minBtn, 0.1, {BackgroundColor3 = Theme.colors.panel, TextColor3 = Theme.colors.accent}) end)
    minBtn.MouseLeave:Connect(function() tween(minBtn, 0.1, {BackgroundColor3 = Theme.colors.card, TextColor3 = Theme.colors.text}) end)

    -- Minimize Logic
    local minimized = false
    local miniTab = new("TextButton", {
        Name = "MinimizedTab", Size = UDim2.new(0, 100, 0, 35), Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Theme.colors.panel, Text = "ALTHERA", Font = Theme.fonts.bold, TextSize = 12,
        TextColor3 = Theme.colors.text, Visible = false, AutoButtonColor = false,
    }, { 
        new("UICorner", { CornerRadius = UDim.new(0, 6) }),
        new("UIStroke", { Color = Theme.colors.border, Thickness = 1 })
    })
    miniTab.Parent = Window.Gui

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Window.Main.Visible = not minimized
        miniTab.Visible = minimized
    end)

    miniTab.MouseButton1Click:Connect(function()
        minimized = false
        Window.Main.Visible = true
        miniTab.Visible = false
    end)

    -- TAB AREA (Sidebar di PC, Top-Nav di Mobile)
    local tabBarW = isMobile and winSize.X.Offset or 160
    Window.Sidebar = new("Frame", {
        Name = "Sidebar",
        Size = isMobile and UDim2.new(1, 0, 0, 35) or UDim2.new(0, tabBarW, 1, -topBarH),
        Position = isMobile and UDim2.new(0, 0, 0, topBarH) or UDim2.new(0, 0, 0, topBarH),
        BackgroundColor3 = isMobile and Theme.colors.bg or Theme.colors.panel,
        BorderSizePixel = 0,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, isMobile and 0 or 8) }),
        new("UIListLayout", { 
            FillDirection = isMobile and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder, 
            Padding = UDim.new(0, 4) 
        }),
        new("UIPadding", { 
            PaddingTop = UDim.new(0, isMobile and 4 or 12), 
            PaddingLeft = UDim.new(0, 8), 
            PaddingRight = UDim.new(0, 8) 
        })
    })
    Window.Sidebar.Parent = Window.Main

    -- CONTENT AREA
    local contentPosX = isMobile and 0 or 160
    local contentPosY = isMobile and (topBarH + 35) or topBarH
    local contentSizeY = isMobile and (winSize.Y.Offset - topBarH - 35) or (winSize.Y.Offset - topBarH)
    
    Window.Content = new("Frame", {
        Name = "Content", Size = UDim2.new(1, -contentPosX, 0, contentSizeY), Position = UDim2.new(0, contentPosX, 0, contentPosY),
        BackgroundTransparency = 1,
    }, {
        new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) })
    })
    Window.Content.Parent = Window.Main

    -- CREATE TAB FUNCTION
    function Window:CreateTab(name)
        local Page = { Elements = {} }

        -- Tombol Tab
        local tabBtnSize = isMobile and UDim2.new(0, 80, 1, 0) or UDim2.new(1, 0, 0, 36)
        local tabBtn = new("TextButton", {
            Name = "Tab_" .. name, Size = tabBtnSize, BackgroundColor3 = Theme.colors.panel,
            Text = name, Font = Theme.fonts.bold, TextSize = 12, TextColor3 = Theme.colors.text2, AutoButtonColor = false,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        
        tabBtn.Parent = Window.Sidebar
        tabBtn.MouseButton1Click:Connect(function() Window:SelectTab(Page) end)
        Page.Btn = tabBtn
        table.insert(Window.TabButtons, tabBtn)

        -- Frame Konten
        Page.Frame = new("ScrollingFrame", {
            Name = "Page_" .. name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.colors.text2, 
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        }, {
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
            new("UIPadding", { PaddingRight = UDim.new(0, 8) })
        })
        Page.Frame.Parent = Window.Content
        table.insert(Window.Tabs, Page)
        
        if #Window.Tabs == 1 then Window:SelectTab(Page) end

        -- METHOD: ADD CARD
        function Page:AddCard(title)
            local card = new("Frame", {
                Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.colors.card, AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                new("UICorner", { CornerRadius = UDim.new(0, 8) }),
                new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
                new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
            })
            card.Parent = Page.Frame

            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = title,
                Font = Theme.fonts.bold, TextSize = 14, TextColor3 = Theme.colors.accent, TextXAlignment = Enum.TextXAlignment.Left,
            }).Parent = card

            return card
        end

        -- METHOD: ADD TOGGLE
        function Page:AddToggle(parent, label, default, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.colors.card,
            }, {
                new("UICorner", { CornerRadius = UDim.new(0, 6) }),
                new("UIStroke", { Color = Theme.colors.border, Thickness = 1 })
            })
            row.Parent = parent or Page.Frame

            new("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1,
                Text = label, Font = Theme.fonts.body, TextSize = 13, TextColor3 = Theme.colors.text, TextXAlignment = Enum.TextXAlignment.Left,
            }).Parent = row

            local state = default or false
            local track = new("Frame", {
                Size = UDim2.new(0, isMobile and 44 or 36, 0, isMobile and 24 or 20),
                Position = UDim2.new(1, isMobile and -54 or -46, 0.5, isMobile and -12 or -10),
                BackgroundColor3 = state and Theme.colors.accent2 or Theme.colors.panel,
            }, {
                new("UICorner", { CornerRadius = UDim.new(1, 0) }),
                new("UIStroke", { Color = Theme.colors.border, Thickness = 1 })
            })
            track.Parent = row

            local knobSize = isMobile and 20 or 16
            local knob = new("Frame", {
                Size = UDim2.new(0, knobSize, 0, knobSize),
                Position = state and UDim2.new(1, -(knobSize+2), 0.5, -(knobSize/2)) or UDim2.new(0, 2, 0.5, -(knobSize/2)),
                BackgroundColor3 = state and Theme.colors.bg or Theme.colors.text2,
            }, {
                new("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            knob.Parent = track

            local click = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })
            click.Parent = track

            click.MouseButton1Click:Connect(function()
                state = not state
                tween(track, 0.2, {BackgroundColor3 = state and Theme.colors.accent2 or Theme.colors.panel})
                tween(knob, 0.2, {
                    Position = state and UDim2.new(1, -(knobSize+2), 0.5, -(knobSize/2)) or UDim2.new(0, 2, 0.5, -(knobSize/2)),
                    BackgroundColor3 = state and Theme.colors.bg or Theme.colors.text2
                })
                if callback then callback(state) end
            end)
        end

        -- METHOD: ADD SLIDER
        function Page:AddSlider(parent, label, min, max, default, callback)
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 })
            row.Parent = parent or Page.Frame

            new("TextLabel", {
                Size = UDim2.new(1, -60, 0, 18), BackgroundTransparency = 1, Text = label,
                Font = Theme.fonts.body, TextSize = 13, TextColor3 = Theme.colors.text, TextXAlignment = Enum.TextXAlignment.Left,
            }).Parent = row

            local valueLabel = new("TextLabel", {
                Size = UDim2.new(0, 60, 0, 18), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1,
                Text = tostring(default), Font = Theme.fonts.bold, TextSize = 13, TextColor3 = Theme.colors.accent, TextXAlignment = Enum.TextXAlignment.Right,
            })
            valueLabel.Parent = row

            local track = new("Frame", {
                Size = UDim2.new(1, 0, 0, isMobile and 8 or 6), Position = UDim2.new(0, 0, 0, 30),
                BackgroundColor3 = Theme.colors.panel,
            }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }), new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }) })
            track.Parent = row

            local fill = new("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = Theme.colors.accent2,
            }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            fill.Parent = track

            local hitbox = new("TextButton", {
                Size = UDim2.new(1, 0, 1, 24), Position = UDim2.new(0, 0, 0, -12), BackgroundTransparency = 1, Text = "",
            })
            hitbox.Parent = track

            local dragging = false
            local function updateSlider(inputPos)
                local relX = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + relX * (max - min) + 0.5)
                fill.Size = UDim2.new(relX, 0, 1, 0)
                valueLabel.Text = tostring(val)
                if callback then callback(val) end
            end

            hitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input.Position)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        return Page
    end

    function Window:SelectTab(Page)
        Window.ActiveTab = Page
        for _, tab in ipairs(Window.Tabs) do
            tab.Frame.Visible = (tab == Page)
            if tab.Btn then
                tween(tab.Btn, 0.1, {
                    BackgroundColor3 = (tab == Page) and Theme.colors.card or Theme.colors.panel,
                    TextColor3 = (tab == Page) and Theme.colors.accent or Theme.colors.text2
                })
            end
        end
    end

    -- DRAG WINDOW (PC)
    if not isMobile then
        local dragging, dragStart, startPos
        Window.TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = Window.Main.Position
            end
        end)
        Window.TopBar.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Window.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    return Window
end

return Library

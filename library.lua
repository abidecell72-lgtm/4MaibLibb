-- ============================================
-- ALTHERA UI LIBRARY (All-in-One)
-- Created by Cabu
-- ============================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ============================================
-- 1. THEME (Warna & Font)
-- ============================================
local Theme = {
    colors = {
        bg      = Color3.fromHex("#0A0A0A"), -- Hitam pekat
        panel   = Color3.fromHex("#121212"), -- Hitam keabuan (Sidebar/Topbar)
        card    = Color3.fromHex("#1A1A1A"), -- Abu gelap (Fitur)
        accent  = Color3.fromHex("#E0E0E0"), -- Perak terang (Teks aktif)
        accent2 = Color3.fromHex("#FFFFFF"), -- Putih bersih (Toggle ON)
        text    = Color3.fromHex("#F5F5F5"), -- Putih tulang
        text2   = Color3.fromHex("#9E9E9E"), -- Abu-abu terang (Teks pasif)
        border  = Color3.fromHex("#2C2C2C"), -- Abu gelap (Garis tepi)
        danger  = Color3.fromHex("#FF4C4C"), -- Merah (Close)
    },
    fonts = {
        bold = Enum.Font.GothamBold,
        body = Enum.Font.Gotham,
    }
}

-- ============================================
-- 2. RESPONSIVE (Ukuran & Device)
-- ============================================
local Responsive = {}

function Responsive.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Responsive.GetWindowSize()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = Responsive.IsMobile()

    -- Target: 440x300 Mobile | 580x380 PC
    local targetW = isMobile and 440 or 580
    local targetH = isMobile and 300 or 380

    -- Pengaman layar kecil
    local finalW = math.min(targetW, viewport.X - 40)
    local finalH = math.min(targetH, viewport.Y - 60) 

    return UDim2.new(0, finalW, 0, finalH)
end

function Responsive.GetWindowPosition(size)
    return UDim2.new(0.5, -(size.X.Offset / 2), 0.5, -(size.Y.Offset / 2))
end

-- ============================================
-- 3. UTILS (Helper Bikin UI)
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
    local Window = { Tabs = {}, ActiveTab = nil }
    config = config or {}
    
    local isMobile = Responsive.IsMobile()
    local winSize = Responsive.GetWindowSize()
    local winPos = Responsive.GetWindowPosition(winSize)

    -- SCREEN GUI
    Window.Gui = new("ScreenGui", {
        Name = "AltheraUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    Window.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- MAIN FRAME
    Window.Main = new("Frame", {
        Name = "Main",
        Size = winSize,
        Position = winPos,
        BackgroundColor3 = Theme.colors.bg,
        BorderSizePixel = 0,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, isMobile and 12 or 8) }),
        new("UIStroke", { Color = Theme.colors.border, Thickness = 1.5 }),
    })
    Window.Main.Parent = Window.Gui

    -- TOPBAR
    local topBarH = isMobile and 50 or 40
    Window.TopBar = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, topBarH),
        BackgroundColor3 = Theme.colors.panel,
        BorderSizePixel = 0,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, isMobile and 12 or 8) }),
    })
    Window.TopBar.Parent = Window.Main

    -- Topbar Text
    new("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "ALTHERA | UI",
        Font = Theme.fonts.bold,
        TextSize = isMobile and 14 or 16,
        TextColor3 = Theme.colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = Window.TopBar

    -- Close Button
    local closeBtn = new("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "✕",
        Font = Theme.fonts.bold,
        TextSize = 16,
        TextColor3 = Theme.colors.text2,
        AutoButtonColor = false,
    })
    closeBtn.Parent = Window.TopBar
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.15, {TextColor3 = Theme.colors.danger}) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.15, {TextColor3 = Theme.colors.text2}) end)
    closeBtn.MouseButton1Click:Connect(function()
        Window.Gui:Destroy()
    end)

    -- SIDEBAR
    local sidebarW = isMobile and 0 or 160 -- Mobile: 0 (karena nanti ganti page di konten), PC: 160
    Window.Sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, sidebarW, 1, -topBarH),
        Position = UDim2.new(0, 0, 0, topBarH),
        BackgroundColor3 = Theme.colors.panel,
        BorderSizePixel = 0,
        Visible = not isMobile,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, isMobile and 12 or 8) }),
        new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
        new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    })
    Window.Sidebar.Parent = Window.Main

    -- CONTENT AREA
    local contentPosX = isMobile and 0 or sidebarW
    Window.Content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -contentPosX, 1, -topBarH),
        Position = UDim2.new(0, contentPosX, 0, topBarH),
        BackgroundTransparency = 1,
    }, {
        new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) })
    })
    Window.Content.Parent = Window.Main

    -- SISTEM PAGES (TAB)
    function Window:CreateTab(name)
        local Page = { Elements = {} }

        -- 1. Tombol Tab di Sidebar (PC Only)
        if not isMobile then
            local tabBtn = new("TextButton", {
                Name = "Tab_" .. name,
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.colors.panel,
                Text = "  " .. name,
                Font = Theme.fonts.body,
                TextSize = 13,
                TextColor3 = Theme.colors.text2,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
            }, {
                new("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            tabBtn.Parent = Window.Sidebar
            tabBtn.MouseEnter:Connect(function() tween(tabBtn, 0.1, {BackgroundColor3 = Theme.colors.card, TextColor3 = Theme.colors.text}) end)
            tabBtn.MouseLeave:Connect(function() 
                if Window.ActiveTab ~= Page then tween(tabBtn, 0.1, {BackgroundColor3 = Theme.colors.panel, TextColor3 = Theme.colors.text2}) end 
            end)
            tabBtn.MouseButton1Click:Connect(function() Window:SelectTab(Page) end)
            Page.Btn = tabBtn
        end

        -- 2. Frame Konten
        Page.Frame = new("ScrollingFrame", {
            Name = "Page_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.colors.text2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, {
            new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
            new("UIPadding", { PaddingRight = UDim.new(0, 8) })
        })
        Page.Frame.Parent = Window.Content

        table.insert(Window.Tabs, Page)
        
        -- Otomatis buka tab pertama
        if #Window.Tabs == 1 then Window:SelectTab(Page) end

        -- Method: AddToggle
        function Page:AddToggle(label, default, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.colors.card,
            }, {
                new("UICorner", { CornerRadius = UDim.new(0, 6) }),
                new("UIStroke", { Color = Theme.colors.border, Thickness = 1 })
            })
            row.Parent = Page.Frame

            new("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                Font = Theme.fonts.body,
                TextSize = 13,
                TextColor3 = Theme.colors.text,
                TextXAlignment = Enum.TextXAlignment.Left,
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

    -- DRAG WINDOW (Khusus PC)
    if not isMobile then
        local dragging, dragInput, dragStart, startPos
        Window.TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Window.Main.Position
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

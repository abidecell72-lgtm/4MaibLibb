-- ============================================
-- STARLESS UI LIBRARY (V4.1 COMPACT)
-- Created by Cabu
-- ============================================

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")

-- ============================================
-- 1. THEME
-- ============================================
local Theme = {
    colors = {
        bg      = Color3.fromHex("#0A0A0A"),
        panel   = Color3.fromHex("#121212"),
        card    = Color3.fromHex("#1A1A1A"),
        hover   = Color3.fromHex("#2C2C2C"),
        accent  = Color3.fromHex("#E0E0E0"),
        accent2 = Color3.fromHex("#FFFFFF"),
        text    = Color3.fromHex("#F5F5F5"),
        text2   = Color3.fromHex("#9E9E9E"),
        border  = Color3.fromHex("#2C2C2C"),
        red     = Color3.fromHex("#FF5F56"),
        yellow  = Color3.fromHex("#FFBD2E"),
        green   = Color3.fromHex("#27C93F"),
    },
    fonts = {
        bold = Enum.Font.GothamBold,
        body = Enum.Font.Gotham,
    }
}

-- ============================================
-- 2. UTILS + CACHE
-- ============================================
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function GetWindowSize()
    local m = IsMobile()
    return UDim2.new(0, m and 440 or 580, 0, m and 320 or 400)
end

local function GetWindowPosition(size)
    return UDim2.new(0.5, -(size.X.Offset / 2), 0.5, -(size.Y.Offset / 2))
end

local function new(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = obj end
    return obj
end

local TI = {
    fast   = TweenInfo.new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    normal = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}
local function tween(obj, info, props)
    TweenService:Create(obj, type(info) == "table" and info or TI.normal, props):Play()
end

local function randomName(prefix)
    return (prefix or "UI_") .. tostring(math.random(100000, 999999))
end

-- ============================================
-- 3. LIBRARY TABLE
-- ============================================
local Library = {}
Library.Theme = Theme

-- ============================================
-- 4. NOTIFY
-- ============================================
local NotifyGui
local function ensureNotifyGui()
    if NotifyGui and NotifyGui.Parent then return NotifyGui end
    NotifyGui = new("ScreenGui", {
        Name = randomName("NT_"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if gethui then pcall(function() NotifyGui.Parent = gethui() end) end
    if not NotifyGui.Parent then
        NotifyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    if protectgui then pcall(protectgui, NotifyGui) end
    return NotifyGui
end

function Library:Notify(title, text, duration)
    duration = duration or 3
    local parent = ensureNotifyGui()

    local holder = parent:FindFirstChild("Holder")
    if not holder then
        holder = new("Frame", {
            Name = "Holder",
            Size = UDim2.new(0, 300, 1, -40),
            Position = UDim2.new(1, -320, 0, 20),
            BackgroundTransparency = 1,
        }, {
            new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 8),
            }),
        })
        holder.Parent = parent
    end

    local toast = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.colors.panel,
        BackgroundTransparency = 1,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 8) }),
        new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
        new("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        new("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
    })
    toast.Parent = holder

    local t1 = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = title or "Notify",
        Font = Theme.fonts.bold,
        TextSize = 13,
        TextColor3 = Theme.colors.accent2,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
    })
    t1.Parent = toast

    local t2 = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text or "",
        Font = Theme.fonts.body,
        TextSize = 12,
        TextColor3 = Theme.colors.text2,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1,
    })
    t2.Parent = toast

    tween(toast, TI.fast, { BackgroundTransparency = 0 })
    tween(t1, TI.fast, { TextTransparency = 0 })
    tween(t2, TI.fast, { TextTransparency = 0 })

    task.delay(duration, function()
        tween(toast, TI.normal, { BackgroundTransparency = 1 })
        tween(t1, TI.normal, { TextTransparency = 1 })
        tween(t2, TI.normal, { TextTransparency = 1 })
        task.delay(0.25, function() toast:Destroy() end)
    end)
end

-- ============================================
-- 5. CORE: CreateWindow
-- ============================================
function Library:CreateWindow(config)
    config = config or {}

    local old = Players.LocalPlayer:FindFirstChild("PlayerGui")
        and Players.LocalPlayer.PlayerGui:FindFirstChild("StarlessUI")
    if old then old:Destroy() end

    local Window = { Tabs = {}, ActiveTab = nil, TabButtons = {} }
    local isMobile = IsMobile()
    local winSize  = GetWindowSize()
    local winPos   = GetWindowPosition(winSize)
    local topBarH  = 45

    Window.Gui = new("ScreenGui", {
        Name = randomName("StarlessUI_"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if gethui then pcall(function() Window.Gui.Parent = gethui() end) end
    if not Window.Gui.Parent then
        Window.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    if protectgui then pcall(protectgui, Window.Gui) end

    Window.Main = new("Frame", {
        Name = "Main",
        Size = winSize,
        Position = winPos,
        BackgroundColor3 = Theme.colors.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 10) }),
        new("UIStroke", { Color = Theme.colors.border, Thickness = 1.5 }),
    })
    Window.Main.Parent = Window.Gui

    -- TOPBAR
    Window.TopBar = new("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, topBarH),
        BackgroundColor3 = Theme.colors.panel,
        BorderSizePixel = 0,
    }, { new("UICorner", { CornerRadius = UDim.new(0, 10) }) })
    Window.TopBar.Parent = Window.Main

    local dots = new("TextButton", {
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, {
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        new("UIPadding", { PaddingLeft = UDim.new(0, 12) }),
    })
    dots.Parent = Window.TopBar

    local function makeDot(color)
        new("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = color,
        }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) }).Parent = dots
    end
    makeDot(Theme.colors.red); makeDot(Theme.colors.yellow); makeDot(Theme.colors.green)

    new("TextLabel", {
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "STARLESS",
        Font = Theme.fonts.bold,
        TextSize = isMobile and 13 or 15,
        TextColor3 = Theme.colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = Window.TopBar

    local minBtn = new("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Theme.colors.card,
        Text = "-",
        Font = Theme.fonts.bold,
        TextSize = 20,
        TextColor3 = Theme.colors.text,
        AutoButtonColor = false,
    }, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    minBtn.Parent = Window.TopBar

    -- FLOAT BUTTON
    local minimized = false
    local miniBtn = new("ImageButton", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 20, 0, 100),
        BackgroundTransparency = 1,
        Image = "rbxassetid://129880169172545",
        ImageColor3 = Theme.colors.text,
        Visible = false,
        AutoButtonColor = false,
    })
    miniBtn.Parent = Window.Gui

    local function setMinimized(state)
        minimized = state
        Window.Main.Visible = not minimized
        miniBtn.Visible = minimized
    end
    minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)

    -- SIDEBAR (COMPACT: 110)
    local tabBarW = 110
    Window.Sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, tabBarW, 1, -topBarH),
        Position = UDim2.new(0, 0, 0, topBarH),
        BackgroundColor3 = Theme.colors.panel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 10) }),
        new("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        }),
        new("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })
    Window.Sidebar.Parent = Window.Main

    Window.Content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -tabBarW, 1, -topBarH),
        Position = UDim2.new(0, tabBarW, 0, topBarH),
        BackgroundTransparency = 1,
    }, {
        new("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
        }),
    })
    Window.Content.Parent = Window.Main

    -- BUILDERS
    local function buildRow(parent, height)
        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, height or 30),
            BackgroundColor3 = Theme.colors.card,
        }, {
            new("UICorner", { CornerRadius = UDim.new(0, 6) }),
            new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
        })
        row.Parent = parent
        return row
    end

    local function buildLabel(parent, text, props)
        local l = new("TextLabel", {
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            Font = Theme.fonts.body,
            TextSize = 12,
            TextColor3 = Theme.colors.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        for k, v in pairs(props or {}) do l[k] = v end
        l.Parent = parent
        return l
    end

    -- CreateTab
    function Window:CreateTab(name)
        local Page = { Elements = {} }

        local tabBtn = new("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Theme.colors.panel,
            Text = name,
            Font = Theme.fonts.bold,
            TextSize = 11,
            TextColor3 = Theme.colors.text2,
            AutoButtonColor = false,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        tabBtn.Parent = Window.Sidebar
        tabBtn.MouseButton1Click:Connect(function() Window:SelectTab(Page) end)

        Page.Btn = tabBtn
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
            new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }),
            new("UIPadding", { PaddingRight = UDim.new(0, 8) }),
        })
        Page.Frame.Parent = Window.Content

        table.insert(Window.Tabs, Page)
        if #Window.Tabs == 1 then Window:SelectTab(Page) end

        -- AddSection
        function Page:AddSection(title, defaultOpen)
            local isOpen = defaultOpen ~= false

            local wrapper = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            wrapper.Parent = Page.Frame

            local container = new("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Theme.colors.card,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                new("UICorner", { CornerRadius = UDim.new(0, 8) }),
                new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
            })
            container.Parent = wrapper

            local header = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
            })
            header.Parent = container

            new("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = title,
                Font = Theme.fonts.bold,
                TextSize = 12,
                TextColor3 = Theme.colors.text,
                TextXAlignment = Enum.TextXAlignment.Left,
            }).Parent = header

            local arrow = new("TextLabel", {
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -35, 0.5, -15),
                BackgroundTransparency = 1,
                Text = isOpen and "v" or ">",
                Font = Theme.fonts.bold,
                TextSize = 12,
                TextColor3 = Theme.colors.accent,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
            })
            arrow.Parent = header

            local bodyWrapper = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Visible = isOpen,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                new("UIPadding", {
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                }),
            })
            bodyWrapper.Parent = container

            local bodyLayout = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                new("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                }),
            })
            bodyLayout.Parent = bodyWrapper

            header.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                arrow.Text = isOpen and "v" or ">"
                bodyWrapper.Visible = isOpen
            end)

            local Section = {}
            Section.Layout = bodyLayout

            function Section:AddLabel(text)
                local row = buildRow(bodyLayout, 24)
                buildLabel(row, text, { TextColor3 = Theme.colors.text2, TextSize = 11 })
                table.insert(Page.Elements, row)
                return row
            end

            function Section:AddToggle(label, default, callback)
                local row = buildRow(bodyLayout, 30)
                buildLabel(row, label)

                local state = default or false
                local track = new("Frame", {
                    Size = UDim2.new(0, isMobile and 44 or 32, 0, isMobile and 24 or 18),
                    Position = UDim2.new(1, isMobile and -54 or -42, 0.5, isMobile and -12 or -9),
                    BackgroundColor3 = state and Theme.colors.accent2 or Theme.colors.panel,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                })
                track.Parent = row

                local knobSize = isMobile and 20 or 14
                local knobPosOn  = UDim2.new(1, -(knobSize + 2), 0.5, -(knobSize / 2))
                local knobPosOff = UDim2.new(0, 2, 0.5, -(knobSize / 2))

                local knob = new("Frame", {
                    Size = UDim2.new(0, knobSize, 0, knobSize),
                    Position = state and knobPosOn or knobPosOff,
                    BackgroundColor3 = state and Theme.colors.bg or Theme.colors.text2,
                }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                knob.Parent = track

                local click = new("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                })
                click.Parent = track

                click.MouseButton1Click:Connect(function()
                    state = not state
                    tween(track, TI.normal, {
                        BackgroundColor3 = state and Theme.colors.accent2 or Theme.colors.panel,
                    })
                    tween(knob, TI.normal, {
                        Position = state and knobPosOn or knobPosOff,
                        BackgroundColor3 = state and Theme.colors.bg or Theme.colors.text2,
                    })
                    if callback then callback(state) end
                end)

                table.insert(Page.Elements, row)
                return row
            end

            function Section:AddDropdown(label, options, default, callback)
                local row = buildRow(bodyLayout, 30)
                row.ClipsDescendants = false
                row.ZIndex = 2

                buildLabel(row, label, { Size = UDim2.new(1, -80, 1, 0) })

                local displayLabel = new("TextLabel", {
                    Size = UDim2.new(0, 80, 1, 0),
                    Position = UDim2.new(1, -90, 0, 0),
                    BackgroundTransparency = 1,
                    Text = default or "Select...",
                    Font = Theme.fonts.bold,
                    TextSize = 11,
                    TextColor3 = Theme.colors.accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                displayLabel.Parent = row

                local arrow = new("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = ">",
                    Font = Theme.fonts.bold,
                    TextSize = 11,
                    TextColor3 = Theme.colors.text2,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })
                arrow.Parent = row

                local click = new("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                })
                click.Parent = row

                local list = new("Frame", {
                    Size = UDim2.new(0, 200, 0, 0),
                    Position = UDim2.new(1, 10, 0, 0),
                    BackgroundColor3 = Theme.colors.panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 10,
                    ClipsDescendants = true,
                    Active = true,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                })
                list.Parent = row

                local searchBox = new("TextBox", {
                    Size = UDim2.new(1, -10, 0, 30),
                    Position = UDim2.new(0, 5, 0, 5),
                    BackgroundColor3 = Theme.colors.bg,
                    Text = "",
                    PlaceholderText = "Search...",
                    Font = Theme.fonts.body,
                    TextSize = 11,
                    TextColor3 = Theme.colors.text,
                    PlaceholderColor3 = Theme.colors.text2,
                    ClearTextOnFocus = false,
                    ZIndex = 11,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    new("UIPadding", { PaddingLeft = UDim.new(0, 5) }),
                })
                searchBox.Parent = list

                local scroll = new("ScrollingFrame", {
                    Size = UDim2.new(1, -10, 0, 0),
                    Position = UDim2.new(0, 5, 0, 40),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.colors.text2,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 11,
                }, {
                    new("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2),
                    }),
                })
                scroll.Parent = list

                local itemButtons = {}

                local function updateList(filterText)
                    local q = string.lower(filterText or "")
                    local count = 0
                    for _, btn in ipairs(itemButtons) do
                        if string.find(string.lower(btn.Text), q, 1, true) then
                            btn.Visible = true; count += 1
                        else
                            btn.Visible = false
                        end
                    end
                    local h = math.min(count * 30, 120)
                    scroll.Size = UDim2.new(1, -10, 0, h)
                    scroll.CanvasSize = UDim2.new(0, 0, 0, count * 30)
                    list.Size = UDim2.new(0, 200, 0, h + 45)
                end

                for _, opt in ipairs(options) do
                    local optBtn = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Theme.colors.panel,
                        Text = opt,
                        Font = Theme.fonts.body,
                        TextSize = 11,
                        TextColor3 = Theme.colors.text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 12,
                    }, {
                        new("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        new("UIPadding", { PaddingLeft = UDim.new(0, 5) }),
                    })
                    optBtn.Parent = scroll
                    table.insert(itemButtons, optBtn)

                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, TI.fast, { BackgroundColor3 = Theme.colors.hover })
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, TI.fast, { BackgroundColor3 = Theme.colors.panel })
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        displayLabel.Text = opt
                        list.Visible = false
                        arrow.Text = ">"
                        if callback then callback(opt) end
                    end)
                end

                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    updateList(searchBox.Text)
                end)

                local isOpen = false
                click.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    list.Visible = isOpen
                    arrow.Text = isOpen and "<" or ">"
                    if isOpen then
                        searchBox.Text = ""
                        updateList("")
                    end
                end)

                table.insert(Page.Elements, row)
                return row
            end

            function Section:AddButton(label, callback)
                local btn = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.colors.card,
                    Text = label,
                    Font = Theme.fonts.bold,
                    TextSize = 12,
                    TextColor3 = Theme.colors.text,
                    AutoButtonColor = false,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                })
                btn.Parent = bodyLayout
                btn.MouseEnter:Connect(function()
                    tween(btn, TI.fast, { BackgroundColor3 = Theme.colors.hover })
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, TI.fast, { BackgroundColor3 = Theme.colors.card })
                end)
                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                table.insert(Page.Elements, btn)
                return btn
            end

            function Section:AddTextBox(label, placeholder, default, callback)
                local row = buildRow(bodyLayout, 30)
                buildLabel(row, label, { Size = UDim2.new(0.5, -12, 1, 0) })

                local box = new("TextBox", {
                    Size = UDim2.new(0.5, -24, 0, 22),
                    Position = UDim2.new(0.5, 12, 0.5, -11),
                    BackgroundColor3 = Theme.colors.bg,
                    Text = default or "",
                    PlaceholderText = placeholder or "",
                    Font = Theme.fonts.body,
                    TextSize = 11,
                    TextColor3 = Theme.colors.text,
                    PlaceholderColor3 = Theme.colors.text2,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                    new("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                    }),
                })
                box.Parent = row

                box.FocusLost:Connect(function(enterPressed)
                    if callback then callback(box.Text, enterPressed) end
                end)

                table.insert(Page.Elements, row)
                return box
            end

            function Section:AddNumericBox(label, placeholder, default, min, max, callback)
                local row = buildRow(bodyLayout, 30)
                buildLabel(row, label, { Size = UDim2.new(0.5, -12, 1, 0) })

                local box = new("TextBox", {
                    Size = UDim2.new(0.5, -24, 0, 22),
                    Position = UDim2.new(0.5, 12, 0.5, -11),
                    BackgroundColor3 = Theme.colors.bg,
                    Text = default and tostring(default) or "",
                    PlaceholderText = placeholder or "0",
                    Font = Theme.fonts.body,
                    TextSize = 11,
                    TextColor3 = Theme.colors.text,
                    PlaceholderColor3 = Theme.colors.text2,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                    new("UIPadding", {
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                    }),
                })
                box.Parent = row

                box:GetPropertyChangedSignal("Text"):Connect(function()
                    local cleaned = box.Text:gsub("[^%-%d%.]", "")
                    local minusCount = select(2, cleaned:gsub("%-", ""))
                    if minusCount > 1 then
                        cleaned = cleaned:gsub("%-", "")
                    elseif minusCount == 1 and not cleaned:match("^%-") then
                        cleaned = cleaned:gsub("%-", "")
                    end
                    local dotIdx = cleaned:find("%.")
                    if dotIdx then
                        cleaned = cleaned:sub(1, dotIdx) .. cleaned:sub(dotIdx + 1):gsub("%.", "")
                    end
                    if cleaned ~= box.Text then
                        box.Text = cleaned
                    end
                end)

                box.FocusLost:Connect(function(enterPressed)
                    if box.Text == "" or box.Text == "-" or box.Text == "." then
                        box.Text = default and tostring(default) or "0"
                    end
                    local num = tonumber(box.Text)
                    if not num then
                        box.Text = default and tostring(default) or "0"
                        return
                    end
                    if min and num < min then num = min end
                    if max and num > max then num = max end
                    box.Text = tostring(num)
                    if callback then callback(num, enterPressed) end
                end)

                table.insert(Page.Elements, row)
                return box
            end

            function Section:AddKeybind(label, defaultKey, callback)
                local row = buildRow(bodyLayout, 30)
                buildLabel(row, label, { Size = UDim2.new(1, -80, 1, 0) })

                local keyBtn = new("TextButton", {
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -70, 0.5, -11),
                    BackgroundColor3 = Theme.colors.bg,
                    Text = defaultKey and defaultKey.Name or "None",
                    Font = Theme.fonts.bold,
                    TextSize = 11,
                    TextColor3 = Theme.colors.accent,
                    AutoButtonColor = false,
                }, {
                    new("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    new("UIStroke", { Color = Theme.colors.border, Thickness = 1 }),
                })
                keyBtn.Parent = row

                local currentKey = defaultKey
                local listening = false

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.TextColor3 = Theme.colors.yellow
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            keyBtn.Text = input.KeyCode.Name
                            keyBtn.TextColor3 = Theme.colors.accent
                            listening = false
                            if callback then callback(currentKey, "bind") end
                        end
                        return
                    end
                    if gpe then return end
                    if currentKey and input.KeyCode == currentKey and callback then
                        callback(currentKey, "press")
                    end
                end)

                table.insert(Page.Elements, row)
                return keyBtn
            end

            function Section:SetOpen(state)
                isOpen = state
                arrow.Text = isOpen and "v" or ">"
                bodyWrapper.Visible = isOpen
            end

            function Section:Destroy()
                wrapper:Destroy()
            end

            return Section
        end

        return Page
    end

    function Window:SelectTab(Page)
        Window.ActiveTab = Page
        for _, tab in ipairs(Window.Tabs) do
            tab.Frame.Visible = (tab == Page)
            if tab == Page then
                tab.Frame.CanvasPosition = Vector2.new(0, 0)
            end
            if tab.Btn then
                tween(tab.Btn, TI.fast, {
                    BackgroundColor3 = (tab == Page) and Theme.colors.card or Theme.colors.panel,
                    TextColor3 = (tab == Page) and Theme.colors.accent or Theme.colors.text2,
                })
            end
        end
    end

    -- DRAG
    local dragState = {
        window = { dragging = false, start = nil, startPos = nil },
        float  = { dragging = false, start = nil, startPos = nil, moved = false },
    }

    local function beginDrag(target, input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if target == "window" then
                dragState.window.dragging = true
                dragState.window.start    = input.Position
                dragState.window.startPos = Window.Main.Position
            else
                dragState.float.dragging = true
                dragState.float.start    = input.Position
                local abs = miniBtn.AbsolutePosition
                dragState.float.startPos = UDim2.new(0, abs.X, 0, abs.Y)
                dragState.float.moved    = false
            end
        end
    end

    dots.InputBegan:Connect(function(i) beginDrag("window", i) end)
    Window.TopBar.InputBegan:Connect(function(i) beginDrag("window", i) end)
    miniBtn.InputBegan:Connect(function(i) beginDrag("float", i) end)

    UserInputService.InputChanged:Connect(function(input)
        local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
        if not isMove then return end

        if dragState.window.dragging then
            local d = input.Position - dragState.window.start
            local sp = dragState.window.startPos
            Window.Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                            sp.Y.Scale, sp.Y.Offset + d.Y)
        end

        if dragState.float.dragging then
            local d = input.Position - dragState.float.start
            if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then
                dragState.float.moved = true
            end
            local sp = dragState.float.startPos
            miniBtn.Position = UDim2.new(0, sp.X.Offset + d.X, 0, sp.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragState.window.dragging then
                dragState.window.dragging = false
            end
            if dragState.float.dragging then
                dragState.float.dragging = false
                if not dragState.float.moved then
                    setMinimized(false)
                end
            end
        end
    end)

    function Window:Destroy()
        Window.Gui:Destroy()
    end

    return Window
end

return Library

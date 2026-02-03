local UIExt = {}

function UIExt:Init(Hub)
    self.Hub = Hub
    self.Notifications = {}
end

local function getSectionFrame(Section)
    if typeof(Section) == "userdata" then
        return Section
    elseif type(Section) == "table" then
        return Section._Content or Section.Container or Section.Frame
    end
    return nil
end

--=============================
-- Multi-dropdown
--=============================
function UIExt:CreateMultiDropdown(data)
    local Tab = data.Tab
    local SectionParam = data.Section
    local Name = data.Name
    local Items = data.Items or {}
    local Callback = data.Callback or function() end

    assert(Tab, "[CreateMultiDropdown] Tab argument is missing or nil")
    assert(Name, "[CreateMultiDropdown] Name argument is missing")
    assert(Items and type(Items) == "table", "[CreateMultiDropdown] Items must be a table")

    -- Determine Section object
    local Section
    if typeof(SectionParam) == "userdata" then
        Section = SectionParam
    elseif typeof(SectionParam) == "string" then
        if Tab.Sections and Tab.Sections[SectionParam] then
            Section = Tab.Sections[SectionParam]
        elseif Tab.AddSection then
            Section = Tab:AddSection(SectionParam)
        else
            error("[CreateMultiDropdown] Tab does not have AddSection method")
        end
    else
        error("[CreateMultiDropdown] Section must be a Section object or string")
    end

    local SectionFrame = getSectionFrame(Section)
    assert(SectionFrame, "[CreateMultiDropdown] Cannot find section Frame")

    -- Container frame
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 25)
    container.BackgroundTransparency = 1
    container.Parent = SectionFrame  -- parent to actual frame

    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, 0, 0, 25)
    toggleBtn.Text = Name .. " ▼"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Parent = container

    local ItemsFrame = Instance.new("Frame")
    ItemsFrame.Size = UDim2.new(1, 0, 0, 0)
    ItemsFrame.Position = UDim2.new(0, 0, 0, 25)
    ItemsFrame.BackgroundTransparency = 1
    ItemsFrame.ClipsDescendants = true
    ItemsFrame.Parent = container

    local TweenService = game:GetService("TweenService")
    local isOpen = false
    local selected = {}

    for i, item in ipairs(Items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 20)
        btn.Text = item
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = ItemsFrame

        btn.MouseButton1Click:Connect(function()
            if table.find(selected, item) then
                table.remove(selected, table.find(selected, item))
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            else
                table.insert(selected, item)
                btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            end
            Callback(selected)
        end)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local goal
        if isOpen then
            goal = UDim2.new(1, 0, 0, #Items * 20)
            toggleBtn.Text = Name .. " ▲"
        else
            goal = UDim2.new(1, 0, 0, 0)
            toggleBtn.Text = Name .. " ▼"
        end
        local tween = TweenService:Create(ItemsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = goal})
        tween:Play()
    end)
end

--=============================
-- Color Picker
--=============================
function UIExt:CreateColorPicker(data)
    local Tab = data.Tab
    local SectionParam = data.Section
    local Name = data.Name
    local Default = data.Default or Color3.fromRGB(255, 255, 255)
    local Callback = data.Callback or function() end

    -- Determine Section object
    local Section
    if typeof(SectionParam) == "userdata" then
        Section = SectionParam
    elseif typeof(SectionParam) == "string" then
        if Tab.Sections and Tab.Sections[SectionParam] then
            Section = Tab.Sections[SectionParam]
        elseif Tab.AddSection then
            Section = Tab:AddSection(SectionParam)
        else
            error("[CreateColorPicker] Tab does not have AddSection method")
        end
    else
        error("[CreateColorPicker] Section must be a Section object or string")
    end

    local SectionFrame = getSectionFrame(Section)
    assert(SectionFrame, "[CreateColorPicker] Cannot find section Frame")

    -- Color picker button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Text = Name
    btn.BackgroundColor3 = Default
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = SectionFrame

    btn.MouseButton1Click:Connect(function()
        local ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
        local Picker = Instance.new("Frame")
        Picker.Size = UDim2.new(0, 200, 0, 200)
        Picker.Position = UDim2.new(0.5, -100, 0.5, -100)
        Picker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Picker.Parent = ScreenGui

        local rSlider = Instance.new("TextBox")
        rSlider.Size = UDim2.new(0, 180, 0, 25)
        rSlider.Position = UDim2.new(0, 10, 0, 10)
        rSlider.PlaceholderText = "R: " .. math.floor(Default.R * 255)
        rSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        rSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        rSlider.Parent = Picker

        local gSlider = rSlider:Clone()
        gSlider.PlaceholderText = "G: " .. math.floor(Default.G * 255)
        gSlider.Position = UDim2.new(0, 10, 0, 45)
        gSlider.Parent = Picker

        local bSlider = rSlider:Clone()
        bSlider.PlaceholderText = "B: " .. math.floor(Default.B * 255)
        bSlider.Position = UDim2.new(0, 10, 0, 80)
        bSlider.Parent = Picker

        local confirm = Instance.new("TextButton")
        confirm.Size = UDim2.new(0, 180, 0, 25)
        confirm.Position = UDim2.new(0, 10, 0, 115)
        confirm.Text = "Confirm"
        confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirm.Parent = Picker

        confirm.MouseButton1Click:Connect(function()
            local r = tonumber(rSlider.Text) or Default.R * 255
            local g = tonumber(gSlider.Text) or Default.G * 255
            local b = tonumber(bSlider.Text) or Default.B * 255
            local color = Color3.fromRGB(r, g, b)
            btn.BackgroundColor3 = color
            Callback(color)
            Picker:Destroy()
        end)
    end)
end

return UIExt

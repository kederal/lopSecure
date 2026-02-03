-- Library

local Library = {
	Theme = {
		Accent = Color3.fromRGB(0, 255, 0),
		TopbarColor = Color3.fromRGB(20, 20, 20),
		SidebarColor = Color3.fromRGB(15, 15, 15),
		BackgroundColor = Color3.fromRGB(10, 10, 10),
		SectionColor = Color3.fromRGB(20, 20, 20),
		TextColor = Color3.fromRGB(255, 255, 255),
	},
	Notif = {
		Active = {},
		Queue = {},
		IsBusy = false,
	},
	Settings = {
		ConfigPath = nil,
		MaxNotifLines = 5,
		MaxNotifStacking = 5,
	},
}

-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local TXS = game:GetService("TextService")
local HS = game:GetService("HttpService")
local CG = game:GetService("CoreGui")

-- Variables

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local SelfModules = {
	UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))(),
	Directory = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Directory.lua"))(),
}
local Storage = { Connections = {}, Tween = { Cosmetic = {} } }

local ListenForInput = false

-- Directory

local Directory = SelfModules.Directory.Create({
	["Vynixius UI Library"] = {
		"Configs",
	},
})

Library.Settings.ConfigPath = Directory.Configs

-- Misc Functions

local function tween(...)
	local args = {...}

	if typeof(args[2]) ~= "string" then
		table.insert(args, 2, "")
	end

	local tween = TS:Create(args[1], TweenInfo.new(args[3], Enum.EasingStyle.Quint), args[4])

	if args[2] == "Cosmetic" then
		Storage.Tween.Cosmetic[args[1]] = tween

		task.spawn(function()
			task.wait(args[3])

			if Storage.Tween.Cosmetic[tween] then
				Storage.Tween.Cosmetic[tween] = nil
			end
		end)
	end

	tween:Play()
end

-- Functions

local ScreenGui = SelfModules.UI.Create("ScreenGui", {
	Name = "Vynixius UI Library",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

function Library:Notify(options, callback)
	if Library.Notif.IsBusy == true then
		Library.Notif.Queue[#Library.Notif.Queue + 1] = { options, callback }
		return
	end	

	Library.Notif.IsBusy = true

	local Notification = {
		Type = "Notification",
		Selection = nil,
		Callback = callback,
	}

	Notification.Frame = SelfModules.UI.Create("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 10, 1, -66),
		Size = UDim2.new(0, 320, 0, 42 + Library.Settings.MaxNotifLines * 14),

		SelfModules.UI.Create("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Library.Theme.TopbarColor,
			Size = UDim2.new(1, 0, 0, 28),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.TopbarColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
			}),

			SelfModules.UI.Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 7, 0.5, -8),
				Size = UDim2.new(1, -54, 0, 16),
				Font = Enum.Font.SourceSans,
				Text = options.title or "Notification",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			SelfModules.UI.Create("ImageButton", {
				Name = "Yes",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "http://www.roblox.com/asset/?id=7919581359",
				ImageColor3 = Library.Theme.TextColor,
			}),

			SelfModules.UI.Create("ImageButton", {
				Name = "No",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -2, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "http://www.roblox.com/asset/?id=7919583990",
				ImageColor3 = Library.Theme.TextColor,
			}),
		}, UDim.new(0,5)),

		SelfModules.UI.Create("Frame", {
			Name = "Background",
			BackgroundColor3 = Library.Theme.BackgroundColor,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 1, -28),

			SelfModules.UI.Create("TextLabel", {
				Name = "Description",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 7, 0, 7),
				Size = UDim2.new(1, -14, 1, -14),
				Font = Enum.Font.SourceSans,
				Text = options.text,
				TextColor3 = Library.Theme.TextColor,
				TextSize = 14,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
			}),
		}, UDim.new(0, 5)),
	})

    -- [Notification logic continues as normal...]
    function Notification:GetHeight()
		local desc = self.Frame.Background.Description
		return 42 + math.round(TXS:GetTextSize(desc.Text, 14, Enum.Font.SourceSans, Vector2.new(desc.AbsoluteSize.X, Library.Settings.MaxNotifStacking * 14)).Y + 0.5)
	end

	function Notification:Select(bool)
		tween(self.Frame.Topbar[bool and "Yes" or "No"], 0.1, { ImageColor3 = bool and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) })
		tween(self.Frame, 0.5, { Position = UDim2.new(0, -320, 0, self.Frame.AbsolutePosition.Y) })
		local notifIdx = table.find(Library.Notif.Active, self)
		if notifIdx then
			table.remove(Library.Notif.Active, notifIdx)
			task.delay(0.5, self.Frame.Destroy, self.Frame)
		end
		pcall(task.spawn, self.Callback, bool)
	end

	Library.Notif.Active[#Library.Notif.Active + 1] = Notification
	Storage.Connections[Notification] = {}
	Notification.Frame.Size = UDim2.new(0, 320, 0, Notification:GetHeight())
	Notification.Frame.Position = UDim2.new(0, -320, 1, -Notification:GetHeight() - 10)
	Notification.Frame.Parent = ScreenGui

	for i, v in next, Library.Notif.Active do
		if v ~= Notification then
			tween(v.Frame, 0.5, { Position = v.Frame.Position - UDim2.new(0, 0, 0, Notification:GetHeight() + 10) })
		end
	end
	tween(Notification.Frame, 0.5, { Position = UDim2.new(0, 10, 1, -Notification:GetHeight() - 10) })

	task.spawn(function()
		task.wait(0.5)
		Storage.Connections[Notification].Yes = Notification.Frame.Topbar.Yes.Activated:Connect(function() Notification:Select(true) end)
		Storage.Connections[Notification].No = Notification.Frame.Topbar.No.Activated:Connect(function() Notification:Select(false) end)
		Library.Notif.IsBusy = false
	end)

	return Notification
end

function Library:AddWindow(options)
	local Window = {
		Name = options.title[1].. " ".. options.title[2],
		Type = "Window",
		Tabs = {},
		Sidebar = { List = {}, Toggled = false },
		Key = options.key or Enum.KeyCode.RightControl,
		Toggled = options.default ~= false,
	}

	Window.Frame = SelfModules.UI.Create("Frame", {
		Name = "Window",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 460, 0, 497),
		Position = UDim2.new(1, -490, 1, -527),
		Visible = options.default ~= false,

		SelfModules.UI.Create("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Library.Theme.TopbarColor,
			Size = UDim2.new(1, 0, 0, 40),
            SelfModules.UI.Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 0, 22),
				Font = Enum.Font.SourceSans,
				Text = string.format("%s - <font color='%s'>%s</font>", options.title[1], SelfModules.UI.Color.ToFormat(Library.Theme.Accent), options.title[2]),
				RichText = true,
				TextColor3 = Library.Theme.TextColor,
				TextSize = 22,
			}),
		}, UDim.new(0, 5)),

		SelfModules.UI.Create("Frame", {
			Name = "Background",
			BackgroundColor3 = Library.Theme.BackgroundColor,
			Position = UDim2.new(0, 30, 0, 40),
			Size = UDim2.new(1, -30, 1, -40),
            SelfModules.UI.Create("Frame", {
				Name = "Tabs",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(15, 15, 15)),
				Position = UDim2.new(0, 3, 0, 3),
				Size = UDim2.new(1, -6, 1, -6),
				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(5, 5, 5)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5)),

        SelfModules.UI.Create("Frame", {
			Name = "Sidebar",
			BackgroundColor3 = Library.Theme.SidebarColor,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(0, 30, 1, -40),
			ZIndex = 2,
            SelfModules.UI.Create("ScrollingFrame", {
				Name = "List",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 5, 0, 35),
				Size = UDim2.new(1, -10, 1, -40),
				CanvasSize = UDim2.new(0,0,0,0),
				ScrollBarThickness = 0,
				SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
			}),
            SelfModules.UI.Create("TextLabel", {
				Name = "Indicator",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -30, 0, 0),
				Size = UDim2.new(0, 30, 0, 30),
				Text = "+",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 20,
			}),
		}, UDim.new(0, 5))
	})

    -- Window Logic
    SelfModules.UI.MakeDraggable(Window.Frame, Window.Frame.Topbar, 0.1)
    Window.Frame.Parent = ScreenGui

	function Window:AddTab(name, options)
		local Tab = { Sections = {}, Button = { Selected = false } }
		Tab.Frame = SelfModules.UI.Create("ScrollingFrame", {
			Name = "Tab",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			Visible = false,
			ScrollBarThickness = 5,
			SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
		})

        Tab.Button.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = Color3.fromRGB(30,30,30),
			Size = UDim2.new(1, 0, 0, 32),
			Parent = Window.Frame.Sidebar.List,
			SelfModules.UI.Create("TextButton", {
				Name = "Button",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
			})
		}, UDim.new(0, 5))

        function Tab:UpdateHeight()
            local h = 0
            for _, s in next, self.Sections do h = h + s:GetHeight() + 5 end
            self.Frame.CanvasSize = UDim2.new(0,0,0,h)
        end

		function Window.Tabs:Show(tab)
			for _, v in next, Window.Tabs do v.Frame.Visible = (v == tab) end
		end
        
        Tab.Button.Frame.Button.Activated:Connect(function()
            for _, t in next, Window.Tabs do t.Frame.Visible = false end
            Tab.Frame.Visible = true
        end)

		function Tab:AddSection(name, options)
			local Section = { List = {}, Toggled = true }
			Section.Frame = SelfModules.UI.Create("Frame", {
				Name = "Section",
				BackgroundColor3 = Library.Theme.SectionColor,
				Size = UDim2.new(1, -10, 0, 40),
				ClipsDescendants = true,
				Parent = Tab.Frame,
				SelfModules.UI.Create("TextLabel", {
					Name = "Header",
					Text = name,
					Size = UDim2.new(1, -40, 0, 30),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = Library.Theme.TextColor,
					TextXAlignment = "Left",
				}),
                SelfModules.UI.Create("TextLabel", {
					Name = "Indicator",
					Text = "+",
					Position = UDim2.new(1, -30, 0, 0),
					Size = UDim2.new(0, 30, 0, 30),
					BackgroundTransparency = 1,
					TextColor3 = Library.Theme.TextColor,
				}),
				SelfModules.UI.Create("Frame", {
					Name = "List",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0, 35),
					Size = UDim2.new(1, -10, 1, -40),
					SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
				})
			}, UDim.new(0, 5))

			function Section:GetHeight()
				local h = 40
				if self.Toggled then
					for _, v in next, self.List do h = h + (v.Frame and v.Frame.AbsoluteSize.Y or 0) + 5 end
				end
				return h
			end

			function Section:UpdateHeight()
				local targetH = self:GetHeight()
				tween(self.Frame, 0.3, {Size = UDim2.new(1, -10, 0, targetH)})
				self.Frame.Indicator.Rotation = self.Toggled and 45 or 0
				task.wait(0.3)
				Tab:UpdateHeight()
			end

			function Section:AddMultiDropdown(name, list, options, callback)
				local Multi = { Value = options.default or {}, Toggled = false }
				Multi.Frame = SelfModules.UI.Create("Frame", {
					Name = name,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Size = UDim2.new(1, -10, 0, 32),
					ClipsDescendants = true,
					Parent = Section.Frame.List,
					SelfModules.UI.Create("TextButton", {
						Name = "Header",
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						Text = "",
						SelfModules.UI.Create("TextLabel", {Name = "Title", Text = name, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextColor, TextXAlignment = "Left"}),
						SelfModules.UI.Create("TextLabel", {Name = "SelectedText", Text = "None", Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(1,-130,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150), TextXAlignment = "Right"}),
						SelfModules.UI.Create("TextLabel", {Name = "Icon", Text = "<", Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1,-30,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150)})
					}),
					SelfModules.UI.Create("Frame", {
						Name = "Controls",
						Size = UDim2.new(1, -20, 0, 25),
						Position = UDim2.new(0, 10, 0, 38),
						Visible = false,
						BackgroundTransparency = 1,
						SelfModules.UI.Create("TextBox", {Name = "Search", Size = UDim2.new(1, -55, 1, 0), PlaceholderText = "Search...", BackgroundColor3 = Color3.fromRGB(35,35,35), TextColor3 = Color3.fromRGB(255,255,255)}),
						SelfModules.UI.Create("TextButton", {Name = "Clear", Text = "Clear", Position = UDim2.new(1,-50,0,0), Size = UDim2.new(0,50,1,0), BackgroundColor3 = Color3.fromRGB(45,25,25), TextColor3 = Color3.fromRGB(255,100,100)})
					}),
					SelfModules.UI.Create("Frame", {
						Name = "List",
						Position = UDim2.new(0, 10, 0, 70),
						Size = UDim2.new(1, -20, 0, 0),
						BackgroundTransparency = 1,
						SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)})
					})
				}, UDim.new(0, 4))

				local function refresh()
					local s = {}
					for k, v in next, Multi.Value do if v then table.insert(s, k) end end
					Multi.Frame.Header.SelectedText.Text = #s > 0 and table.concat(s, ", ") or "None"
					for _, b in next, Multi.Frame.List:GetChildren() do
						if b:IsA("TextButton") then
							b.BackgroundColor3 = Multi.Value[b.Name] and Color3.fromRGB(45,45,45) or Color3.fromRGB(30,30,30)
						end
					end
				end

				for _, v in next, list do
					local b = SelfModules.UI.Create("TextButton", {
						Name = tostring(v), Text = tostring(v), Size = UDim2.new(1, 0, 0, 28),
						BackgroundColor3 = Color3.fromRGB(30,30,30), TextColor3 = Color3.fromRGB(200,200,200),
						Parent = Multi.Frame.List
					}, UDim.new(0, 4))
					b.Activated:Connect(function()
						Multi.Value[b.Name] = not Multi.Value[b.Name]
						refresh()
						pcall(task.spawn, callback, Multi.Value)
					end)
				end

				Multi.Frame.Header.Activated:Connect(function()
					Multi.Toggled = not Multi.Toggled
					Multi.Frame.Controls.Visible = Multi.Toggled
					local target = Multi.Toggled and (#list * 33 + 80) or 32
					tween(Multi.Frame, 0.3, {Size = UDim2.new(1, -10, 0, target)})
					task.wait(0.35)
					Section:UpdateHeight()
				end)

				Multi.Frame.Controls.Clear.Activated:Connect(function()
					for k in next, Multi.Value do Multi.Value[k] = false end
					refresh()
					pcall(task.spawn, callback, Multi.Value)
				end)

				table.insert(Section.List, Multi)
				refresh()
				Section:UpdateHeight()
				return Multi
			end

			Section.Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Y - Section.Frame.AbsolutePosition.Y <= 30 then
					Section.Toggled = not Section.Toggled
					Section:UpdateHeight()
				end
			end)

			table.insert(Tab.Sections, Section)
			return Section
		end

		table.insert(Window.Tabs, Tab)
		return Tab
	end
	return Window
end

return Library

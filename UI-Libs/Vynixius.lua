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

-- Directory
local Directory = SelfModules.Directory.Create({
	["lopSecure"] = {
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

	local tweenObj = TS:Create(args[1], TweenInfo.new(args[3], Enum.EasingStyle.Quint), args[4])

	if args[2] == "Cosmetic" then
		Storage.Tween.Cosmetic[args[1]] = tweenObj
		task.spawn(function()
			task.wait(args[3])
			if Storage.Tween.Cosmetic[args[1]] == tweenObj then
				Storage.Tween.Cosmetic[args[1]] = nil
			end
		end)
	end

	tweenObj:Play()
end

-- ScreenGui Setup
local ScreenGui = SelfModules.UI.Create("ScreenGui", {
	Name = "lopSecure",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = CG,
})

-- Notification Function
function Library:Notify(options, callback)
	if Library.Notif.IsBusy then
		table.insert(Library.Notif.Queue, {options, callback})
		return
	end	

	Library.Notif.IsBusy = true
	local Notification = { Type = "Notification", Callback = callback }

	Notification.Frame = SelfModules.UI.Create("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 10, 1, -66),
		Size = UDim2.new(0, 320, 0, 100),

		SelfModules.UI.Create("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Library.Theme.TopbarColor,
			Size = UDim2.new(1, 0, 0, 28),
			SelfModules.UI.Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 7, 0.5, -8),
				Size = UDim2.new(1, -54, 0, 16),
				Font = Enum.Font.SourceSans,
				Text = options.title or "Notification",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 16,
				TextXAlignment = "Left",
			}),
			SelfModules.UI.Create("ImageButton", {
				Name = "Yes",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "rbxassetid://7919581359",
				ImageColor3 = Library.Theme.TextColor,
			}),
			SelfModules.UI.Create("ImageButton", {
				Name = "No",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -2, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "rbxassetid://7919583990",
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
				Text = options.text or "",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 14,
				TextWrapped = true,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
			}),
		}, UDim.new(0, 5)),
	})

	function Notification:GetHeight()
		local desc = self.Frame.Background.Description
		local size = TXS:GetTextSize(desc.Text, 14, Enum.Font.SourceSans, Vector2.new(desc.AbsoluteSize.X, 1000))
		return 42 + math.clamp(size.Y, 14, Library.Settings.MaxNotifStacking * 14)
	end

	function Notification:Select(bool)
		tween(self.Frame.Topbar[bool and "Yes" or "No"], 0.1, { ImageColor3 = bool and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) })
		tween(self.Frame, 0.5, { Position = UDim2.new(0, -320, 0, self.Frame.AbsolutePosition.Y) })
		local idx = table.find(Library.Notif.Active, self)
		if idx then table.remove(Library.Notif.Active, idx) end
		task.delay(0.5, function() self.Frame:Destroy() end)
		if self.Callback then task.spawn(self.Callback, bool) end
	end

	Notification.Frame.Size = UDim2.new(0, 320, 0, Notification:GetHeight())
	Notification.Frame.Parent = ScreenGui
	table.insert(Library.Notif.Active, Notification)

	for i, v in next, Library.Notif.Active do
		if v ~= Notification then
			tween(v.Frame, 0.5, { Position = v.Frame.Position - UDim2.new(0, 0, 0, Notification.Frame.AbsoluteSize.Y + 10) })
		end
	end
	tween(Notification.Frame, 0.5, { Position = UDim2.new(0, 10, 1, -Notification.Frame.AbsoluteSize.Y - 10) })

	Notification.Frame.Topbar.Yes.Activated:Connect(function() Notification:Select(true) end)
	Notification.Frame.Topbar.No.Activated:Connect(function() Notification:Select(false) end)
	
	Library.Notif.IsBusy = false
	if #Library.Notif.Queue > 0 then
		local nextNotif = table.remove(Library.Notif.Queue, 1)
		Library:Notify(nextNotif[1], nextNotif[2])
	end

	return Notification
end

-- Window Function
function Library:AddWindow(options)
	local Window = {
		Tabs = {},
		Key = options.key or Enum.KeyCode.RightControl,
		Toggled = options.default ~= false,
	}

	Window.Frame = SelfModules.UI.Create("Frame", {
		Name = "Window",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 460, 0, 497),
		Position = UDim2.new(0.5, -230, 0.5, -248),
		Visible = Window.Toggled,
		Parent = ScreenGui,

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
				Name = "TabHolder",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 5, 0, 5),
				Size = UDim2.new(1, -10, 1, -10),
			}),
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
				Position = UDim2.new(0, 5, 0, 5),
				Size = UDim2.new(1, -10, 1, -10),
				ScrollBarThickness = 0,
				SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
			}),
		}, UDim.new(0, 5))
	})

	SelfModules.UI.MakeDraggable(Window.Frame, Window.Frame.Topbar, 0.1)

	function Window:AddTab(name)
		local Tab = { Sections = {} }
		Tab.Frame = SelfModules.UI.Create("ScrollingFrame", {
			Name = "Tab_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			ScrollBarThickness = 2,
			Parent = Window.Frame.Background.TabHolder,
			SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = "Center"}),
		})

		Tab.Button = SelfModules.UI.Create("TextButton", {
			Name = name,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			Size = UDim2.new(1, 0, 0, 30),
			Text = name:sub(1,1),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Parent = Window.Frame.Sidebar.List,
		}, UDim.new(0, 4))

		function Tab:UpdateHeight()
			local h = 0
			for _, s in next, self.Sections do h = h + s.Frame.AbsoluteSize.Y + 5 end
			self.Frame.CanvasSize = UDim2.new(0, 0, 0, h)
		end

		Tab.Button.Activated:Connect(function()
			for _, t in next, Window.Tabs do t.Frame.Visible = false end
			Tab.Frame.Visible = true
		end)

		function Tab:AddSection(name)
			local Section = { List = {}, Toggled = true }
			Section.Frame = SelfModules.UI.Create("Frame", {
				Name = "Section_" .. name,
				BackgroundColor3 = Library.Theme.SectionColor,
				Size = UDim2.new(1, -10, 0, 40),
				ClipsDescendants = true,
				Parent = Tab.Frame,
				SelfModules.UI.Create("TextLabel", {
					Name = "Header",
					Text = "  " .. name,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					TextColor3 = Library.Theme.TextColor,
					TextXAlignment = "Left",
				}),
				SelfModules.UI.Create("Frame", {
					Name = "Container",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0, 35),
					Size = UDim2.new(1, -10, 0, 0),
					SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 5)}),
				})
			}, UDim.new(0, 5))

			function Section:UpdateHeight()
				local h = 40
				if self.Toggled then
					for _, v in next, self.List do h = h + v.Frame.AbsoluteSize.Y + 5 end
				end
				tween(self.Frame, 0.3, {Size = UDim2.new(1, -10, 0, h)})
				task.wait(0.3)
				Tab:UpdateHeight()
			end

			function Section:AddMultiDropdown(name, list, options, callback)
				local Multi = { Value = options.default or {}, Toggled = false, Items = {} }
				Multi.Frame = SelfModules.UI.Create("Frame", {
					Name = name,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Size = UDim2.new(1, 0, 0, 32),
					ClipsDescendants = true,
					Parent = Section.Frame.Container,
					SelfModules.UI.Create("TextButton", {
						Name = "Header",
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						Text = "",
						SelfModules.UI.Create("TextLabel", {Name = "Title", Text = "  " .. name, Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextColor, TextXAlignment = "Left"}),
						SelfModules.UI.Create("TextLabel", {Name = "SelectedText", Text = "None", Position = UDim2.new(0.5, -5, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = "Right"}),
					}),
					SelfModules.UI.Create("Frame", {
						Name = "Controls",
						Size = UDim2.new(1, -10, 0, 25),
						Position = UDim2.new(0, 5, 0, 35),
						BackgroundTransparency = 1,
						Visible = false,
						SelfModules.UI.Create("TextBox", {
							Name = "Search",
							Size = UDim2.new(1, -60, 1, 0),
							BackgroundColor3 = Color3.fromRGB(35, 35, 35),
							PlaceholderText = "Search...",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							Text = "",
						}, UDim.new(0, 4)),
						SelfModules.UI.Create("TextButton", {
							Name = "Clear",
							Size = UDim2.new(0, 55, 1, 0),
							Position = UDim2.new(1, -55, 0, 0),
							BackgroundColor3 = Color3.fromRGB(45, 25, 25),
							Text = "Clear",
							TextColor3 = Color3.fromRGB(255, 100, 100),
						}, UDim.new(0, 4))
					}),
					SelfModules.UI.Create("Frame", {
						Name = "DropList",
						Position = UDim2.new(0, 5, 0, 65),
						Size = UDim2.new(1, -10, 0, 0),
						BackgroundTransparency = 1,
						SelfModules.UI.Create("UIListLayout", {Padding = UDim.new(0, 3)}),
					})
				}, UDim.new(0, 4))

				local function refresh()
					local s = {}
					for k, v in next, Multi.Value do if v then table.insert(s, k) end end
					Multi.Frame.Header.SelectedText.Text = #s > 0 and table.concat(s, ", ") or "None"
				end

				local function updateDropdownHeight()
					if not Multi.Toggled then return end
					local visibleItems = 0
					for _, item in next, Multi.Items do
						if item.Visible then visibleItems = visibleItems + 1 end
					end
					local target = (visibleItems * 28) + 70
					tween(Multi.Frame, 0.2, {Size = UDim2.new(1, 0, 0, target)})
					task.wait(0.2)
					Section:UpdateHeight()
				end

				for _, v in next, list do
					local item = SelfModules.UI.Create("TextButton", {
						Text = tostring(v),
						Size = UDim2.new(1, 0, 0, 25),
						BackgroundColor3 = Multi.Value[v] and Library.Theme.Accent or Color3.fromRGB(35, 35, 35),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Parent = Multi.Frame.DropList,
					}, UDim.new(0, 4))
					
					item.Activated:Connect(function()
						Multi.Value[v] = not Multi.Value[v]
						item.BackgroundColor3 = Multi.Value[v] and Library.Theme.Accent or Color3.fromRGB(35, 35, 35)
						refresh()
						if callback then task.spawn(callback, Multi.Value) end
					end)
					Multi.Items[v] = item
				end

				Multi.Frame.Header.Activated:Connect(function()
					Multi.Toggled = not Multi.Toggled
					Multi.Frame.Controls.Visible = Multi.Toggled
					if Multi.Toggled then
						updateDropdownHeight()
					else
						tween(Multi.Frame, 0.3, {Size = UDim2.new(1, 0, 0, 32)})
						task.wait(0.3)
						Section:UpdateHeight()
					end
				end)

				Multi.Frame.Controls.Search:GetPropertyChangedSignal("Text"):Connect(function()
					local query = Multi.Frame.Controls.Search.Text:lower()
					for name, btn in next, Multi.Items do
						btn.Visible = name:lower():find(query) ~= nil
					end
					updateDropdownHeight()
				end)

				Multi.Frame.Controls.Clear.Activated:Connect(function()
					for k in next, Multi.Value do 
						Multi.Value[k] = false 
						if Multi.Items[k] then Multi.Items[k].BackgroundColor3 = Color3.fromRGB(35, 35, 35) end
					end
					refresh()
					if callback then task.spawn(callback, Multi.Value) end
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

		if #Window.Tabs == 0 then Tab.Frame.Visible = true end
		table.insert(Window.Tabs, Tab)
		return Tab
	end

	return Window
end

return Library

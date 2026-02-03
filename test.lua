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
	UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/kederal/UI-Librarys-2.0/main/Vynixius/Utilities/UI.lua"))(),
	Directory = loadstring(game:HttpGet("https://raw.githubusercontent.com/kederal/UI-Librarys-2.0/main/Vynixius/Utilities/Directory.lua"))(),
}
local Storage = { Connections = {}, Tween = { Cosmetic = {} } }

local ListenForInput = false

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
	Name = "lopSecure",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

function Library:Destroy()
	if ScreenGui.Parent then
		ScreenGui:Destroy()
	end
end

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

	if options.color ~= nil then
		local indicator = SelfModules.UI.Create("Frame", {
			Name = "Indicator",
			BackgroundColor3 = options.color,
			Size = UDim2.new(0, 4, 1, 0),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = options.color,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
			}),
		}, UDim.new(0, 3))

		Notification.Frame.Topbar.Title.Position = UDim2.new(0, 11, 0.5, -8)
		Notification.Frame.Topbar.Title.Size = UDim2.new(1, -60, 0, 16)
		Notification.Frame.Background.Description.Position = UDim2.new(0, 11, 0, 7)
		Notification.Frame.Background.Description.Size = UDim2.new(1, -18, 1, -14)
		indicator.Parent = Notification.Frame
	end

	-- Functions

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

	-- Scripts

	Library.Notif.Active[#Library.Notif.Active + 1] = Notification
	Storage.Connections[Notification] = {}
	Notification.Frame.Size = UDim2.new(0, 320, 0, Notification:GetHeight())
	Notification.Frame.Position = UDim2.new(0, -320, 1, -Notification:GetHeight() - 10)
	Notification.Frame.Parent = ScreenGui

	if #Library.Notif.Active > Library.Settings.MaxNotifStacking then
		Library.Notif.Active[1]:Select(false)
	end

	for i, v in next, Library.Notif.Active do
		if v ~= Notification then
			tween(v.Frame, 0.5, { Position = v.Frame.Position - UDim2.new(0, 0, 0, Notification:GetHeight() + 10) })
		end
	end

	tween(Notification.Frame, 0.5, { Position = UDim2.new(0, 10, 1, -Notification:GetHeight() - 10) })

	task.spawn(function()
		task.wait(0.5)

		Storage.Connections[Notification].Yes = Notification.Frame.Topbar.Yes.Activated:Connect(function()
			Notification:Select(true)
		end)

		Storage.Connections[Notification].No = Notification.Frame.Topbar.No.Activated:Connect(function()
			Notification:Select(false)
		end)

		Library.Notif.IsBusy = false

		if #Library.Notif.Queue > 0 then
			local notif = Library.Notif.Queue[1]
			table.remove(Library.Notif.Queue, 1)

			Library:Notify(notif[1], notif[2])
		end
	end)

	task.spawn(function()
		task.wait(options.duration or 10)

		if Notification.Frame.Parent ~= nil then
			Notification:Select(false)
		end
	end)

	return Notification
end

function Library:AddWindow(options)
	assert(options, "No options data assigned to Window")

	local Window = {
		Name = options.title[1].. " ".. options.title[2],
		Type = "Window",
		Tabs = {},
		Sidebar = { List = {}, Toggled = false },
		Key = options.key or Enum.KeyCode.RightControl,
		Toggled = options.default ~= false,
	}

	-- Custom theme setup

	if options.theme ~= nil then
		for i, v in next, options.theme do
			for i2, _ in next, Library.Theme do
				if string.lower(i) == string.lower(i2) and typeof(v) == "Color3" then
					Library.Theme[i2] = v
				end
			end
		end
	end

	-- Window construction

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

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.TopbarColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
			}),

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
				TextWrapped = true,
			}),
		}, UDim.new(0, 5)),

		SelfModules.UI.Create("Frame", {
			Name = "Background",
			BackgroundColor3 = Library.Theme.BackgroundColor,
			Position = UDim2.new(0, 30, 0, 40),
			Size = UDim2.new(1, -30, 1, -40),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 5, 1, 0),
			}),

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

			SelfModules.UI.Create("Frame", {
				Name = "Sidebar",
				BackgroundColor3 = Library.Theme.SidebarColor,
				Position = UDim2.new(0, 0, 0, 40),
				Size = UDim2.new(0, 30, 1, -40),
				ZIndex = 2,

				SelfModules.UI.Create("Frame", {
					Name = "Filling",
					BackgroundColor3 = Library.Theme.SidebarColor,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 5),
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Filling",
					BackgroundColor3 = Library.Theme.SidebarColor,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -5, 0, 0),
					Size = UDim2.new(0, 5, 1, 0),
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Border",
					BackgroundColor3 = Library.Theme.BackgroundColor,
					BorderSizePixel = 0,
					Position = UDim2.new(1, 0, 0, 0),
					Selectable = true,
					Size = UDim2.new(0, 5, 1, 0),
					ZIndex = 2,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Line",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(10, 10, 10)),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 29),
					Size = UDim2.new(1, -10, 0, 2),
				}),

				SelfModules.UI.Create("ScrollingFrame", {
					Name = "List",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Position = UDim2.new(0, 5, 0, 35),
					Size = UDim2.new(1, -10, 1, -40),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarThickness = 5,

					SelfModules.UI.Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5),
					}),
				}),

				SelfModules.UI.Create("TextLabel", {
					Name = "Indicator",
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -30, 0, 0),
					Size = UDim2.new(0, 30, 0, 30),
					Font = Enum.Font.SourceSansBold,
					Text = "+",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 20,
				}),
			}, UDim.new(0, 5))
		})

		-- Functions

		local function saveConfig(filePath)
			pcall(function()
				local config = { Flags = {}, Binds = {}, Sliders = {}, Pickers = {} }
	
				for _, tab in next, Window.Tabs do
					for flag, value in next, tab.Flags do
						config.Flags[flag] = value
					end
		
					for _, section in next, tab.Sections do
						for _, item in next, section.List do
							local flag = item.Flag or item.Name
		
							if item.Type == "Bind" then
								config.Binds[flag] = item.Bind.Name
		
							elseif item.Type == "Slider" then
								config.Sliders[flag] = item.Value
		
							elseif item.Type == "Picker" then
								config.Pickers[flag] = { Color = item.Color, Rainbow = item.Rainbow }
		
							elseif item.Type == "SubSection" then
								for _, item2 in next, item.List do
									local flag2 = item2.Flag or item2.Name
		
									if item2.Type == "Bind" then
										config.Binds[flag2] = item2.Bind.Name
		
									elseif item2.Type == "Slider" then
										config.Sliders[flag2] = item2.Value
		
									elseif item2.Type == "Picker" then
										config.Pickers[flag2] = { Color = item2.Color, Rainbow = item2.Rainbow }
									end
								end
							end
						end
					end
				end
		
				writefile(filePath, HS:JSONEncode(config))
			end)
		end
		
		local function loadConfig(filePath)
			pcall(function()
				local config = HS:JSONDecode(readfile(filePath))
		
				if config then
					for _, tab in next, Window.Tabs do
						for _, section in next, tab.Sections do
							for _, item in next, section.List do
								local flag = item.Flag or item.Name
		
								if config.Flags[flag] ~= nil then
									item[item.Type == "Toggle" and "Set" or "Toggle"](item, config.Flags[flag])
								end
		
								if item.Type == "Bind" then
									item:Set(Enum.KeyCode[config.Binds[flag]])
		
								elseif item.Type == "Slider" then
									item:Set(config.Sliders[flag])
		
								elseif item.Type == "Picker" then
									local picker = config.Pickers[flag]
		
									item:Set(picker.Color.R, picker.Color.G, picker.Color.B)
									item:ToggleRainbow(picker.Rainbow)
		
								elseif item.Type == "SubSection" then
									for _, item2 in next, item.List do
										local flag2 = item2.Flag or item2.Name
		
										if config.Flags[flag2] ~= nil then
											item2[item2.Type == "Toggle" and "Set" or "Toggle"](item2, config.Flags[flag2])
										end
		
										if item2.Type == "Bind" then
											item2:Set(Enum.KeyCode[config.Binds[flag2]])
		
										elseif item2.Type == "Slider" then
											item2:Set(config.Sliders[flag2])
		
										elseif item2.Type == "Picker" then
											local picker = config.Pickers[flag2]
		
											item2:Set(picker.Color.R, picker.Color.G, picker.Color.B)
											item2:ToggleRainbow(picker.Rainbow)
										end
									end
								end
							end
						end
					end
				end
			end)
		end

		function Window:Toggle(bool)
			self.Toggled = bool
			self.Frame.Visible = bool
		end

		function Window:SetKey(keycode)
			self.Key = keycode
		end

		local function setAccent(accent)
			Library.Theme.Accent = accent
			Window.Frame.Topbar.Title.Text = string.format("%s - <font color='%s'>%s</font>", options.title[1], SelfModules.UI.Color.ToFormat(accent), options.title[2])

			for _, tab in next, Window.Tabs do
				for _, section in next, tab.Sections do
					for _, item in next, section.List do
						local flag = item.Flag or item.Name

						if tab.Flags[flag] == true or item.Rainbow == true then
							local overlay = nil

							for _, v in next, item.Frame:GetDescendants() do
								if v.Name == "Overlay" then
									overlay = v; break
								end
							end
								
							if overlay then
								local tween = Storage.Tween.Cosmetic[overlay]

								if tween then
									tween:Cancel(); tween = nil
								end

								overlay.BackgroundColor3 = SelfModules.UI.Color.Add(accent, Color3.fromRGB(50, 50, 50))
							end
						end

						if item.Type == "Slider" then
							item.Frame.Holder.Slider.Bar.Fill.BackgroundColor3 = SelfModules.UI.Color.Sub(accent, Color3.fromRGB(50, 50, 50))
							item.Frame.Holder.Slider.Point.BackgroundColor3 = accent

						elseif item.Type == "SubSection" then
							for _, item2 in next, item.List do
								local flag2 = item2.Flag or item2.Name
		
								if tab.Flags[flag2] == true or item2.Rainbow == true then
									local overlay = nil
		
									for _, v in next, item2.Frame:GetDescendants() do
										if v.Name == "Overlay" then
											overlay = v; break
										end
									end
										
									if overlay then
										local tween = Storage.Tween.Cosmetic[overlay]
		
										if tween then
											tween:Cancel(); tween = nil
										end
		
										overlay.BackgroundColor3 = SelfModules.UI.Color.Add(accent, Color3.fromRGB(50, 50, 50))
									end
								end
		
								if item2.Type == "Slider" then
									item2.Frame.Holder.Slider.Bar.Fill.BackgroundColor3 = SelfModules.UI.Color.Sub(accent, Color3.fromRGB(50, 50, 50))
									item2.Frame.Holder.Slider.Point.BackgroundColor3 = accent
								end
							end
						end
					end
				end
			end
		end

		function Window:SetAccent(accent)
			if Storage.Connections.WindowRainbow ~= nil then
				Storage.Connections.WindowRainbow:Disconnect()
			end

			if typeof(accent) == "string" and string.lower(accent) == "rainbow" then
				Storage.Connections.WindowRainbow = RS.Heartbeat:Connect(function()
					setAccent(Color3.fromHSV(tick() % 5 / 5, 1, 1))
				end)

			elseif typeof(accent) == "Color3" then
				setAccent(accent)
			end
		end

		local function toggleSidebar(bool)
			Window.Sidebar.Toggled = bool

			task.spawn(function()
				task.wait(bool and 0 or 0.5)
				Window.Sidebar.Frame.Border.Visible = bool
			end)

			tween(Window.Sidebar.Frame, 0.5, { Size = UDim2.new(0, bool and 130 or 30, 1, -40) })
			tween(Window.Sidebar.Frame.Indicator, 0.5, { Rotation = bool and 45 or 0 })

			for i, v in next, Window.Sidebar.List do
				tween(v.Frame.Button, 0.5, { BackgroundTransparency = bool and 0 or 1 })
				tween(v.Frame, 0.5, { BackgroundTransparency = bool and 0 or 1 })
			end
		end

		-- Scripts

		Window.Key = options.key or Window.Key
		Storage.Connections[Window] = {}
		SelfModules.UI.MakeDraggable(Window.Frame, Window.Frame.Topbar, 0.1)
		Window.Sidebar.Frame = Window.Frame.Sidebar
		Window.Frame.Parent = ScreenGui

		UIS.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == Window.Key and not ListenForInput then
				Window:Toggle(not Window.Toggled)
			end
		end)

		Window.Sidebar.Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Y - Window.Sidebar.Frame.AbsolutePosition.Y <= 25 then
				toggleSidebar(not Window.Sidebar.Toggled)
			end
		end)

		-- Tab

		function Window:AddTab(name, options)
			options = options or {}
			
			local Tab = {
				Name = name,
				Type = "Tab",
				Sections = {},
				Flags = {},
				Button = {
					Name = name,
					Selected = false,
				},
			}

			Tab.Frame = SelfModules.UI.Create("ScrollingFrame", {
				Name = "Tab",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 5),
				Size = UDim2.new(1, -10, 1, -10),
				ScrollBarImageColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(15, 15, 15)),
				ScrollBarThickness = 5,
				Visible = false,

				SelfModules.UI.Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5),
				}),
			})

			Tab.Button.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 120, 0, 32),

				SelfModules.UI.Create("TextButton", {
					Name = "Button",
					AutoButtonColor = false,
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Functions

			function Tab:Show()
				for i, v in next, Window.Tabs do
					local bool = v == self

					v.Frame.Visible = bool
					v.Button.Selected = bool

					tween(v.Button.Frame.Button, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(35, 35, 35)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)) })
					tween(v.Button.Frame, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(45, 45, 45)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)) })
				end

				toggleSidebar(false)
			end

			function Tab:Hide()
				self.Frame.Visible = false
			end

			function Tab:GetHeight()
				local height = 0

				for i, v in next, self.Sections do
					height = height + v:GetHeight() + (i < #self.Sections and 5 or 0)
				end

				return height
			end

			function Tab:UpdateHeight()
				Tab.Frame.CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight())
			end

			-- Scripts

			Window.Tabs[#Window.Tabs + 1] = Tab
			Window.Sidebar.List[#Window.Sidebar.List + 1] = Tab.Button
			Tab.Frame.Parent = Window.Frame.Background.Tabs.Holder
			Tab.Frame.CanvasSize = UDim2.new(0, 0, 0, Tab.Frame.AbsoluteSize.Y + 1)
			Tab.Button.Frame.Parent = Window.Frame.Sidebar.List

			Tab.Frame.ChildAdded:Connect(function(c)
				if c.ClassName == "Frame" then
					Tab:UpdateHeight()
				end
			end)

			Tab.Frame.ChildRemoved:Connect(function(c)
				if c.ClassName == "Frame" then
					Tab:UpdateHeight()
				end
			end)

			Tab.Button.Frame.Button.MouseEnter:Connect(function()
				if Tab.Button.Selected == false then
					tween(Tab.Button.Frame.Button, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)) })
					tween(Tab.Button.Frame, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(25, 25, 25)) })
				end
			end)

			Tab.Button.Frame.Button.MouseLeave:Connect(function()
				if Tab.Button.Selected == false then
					tween(Tab.Button.Frame.Button, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)) })
					tween(Tab.Button.Frame, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)) })
				end
			end)

			Tab.Button.Frame.Button.Activated:Connect(function()
				if Tab.Button.Selected == false then
					Tab:Show()
				end
			end)

			if options.default == true then
				Tab:Show()
			end

			-- Section

			function Tab:AddSection(name, options)
				options = options or {}
				
				local Section = {
					Name = name,
					Type = "Section",
					Toggled = options.default == true,
					List = {},
				}

				Section.Frame = SelfModules.UI.Create("Frame", {
					Name = "Section",
					BackgroundColor3 = Library.Theme.SectionColor,
					ClipsDescendants = true,
					Size = UDim2.new(1, -10, 0, 40),

					SelfModules.UI.Create("Frame", {
						Name = "Line",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 30),
						Size = UDim2.new(1, -10, 0, 2),
					}),

					SelfModules.UI.Create("TextLabel", {
						Name = "Header",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0, 8),
						Size = UDim2.new(1, -40, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "List",
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						Position = UDim2.new(0, 5, 0, 40),
						Size = UDim2.new(1, -10, 1, -40),

						SelfModules.UI.Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 5),
						}),

						SelfModules.UI.Create("UIPadding", {
							PaddingBottom = UDim.new(0, 1),
							PaddingLeft = UDim.new(0, 1),
							PaddingRight = UDim.new(0, 1),
							PaddingTop = UDim.new(0, 1),
						}),
					}),

					SelfModules.UI.Create("TextLabel", {
						Name = "Indicator",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -30, 0, 0),
						Size = UDim2.new(0, 30, 0, 30),
						Font = Enum.Font.SourceSansBold,
						Text = "+",
						TextColor3 = Library.Theme.TextColor,
						TextSize = 20,
					})
				}, UDim.new(0, 5))

				-- Functions

				local function toggleSection(bool)
					Section.Toggled = bool

					tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
					tween(Section.Frame.Indicator, 0.5, { Rotation = bool and 45 or 0 })

					tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
				end

				function Section:GetHeight()
					local height = 40

					if Section.Toggled == true then
						for i, v in next, self.List do
							height = height + (v.GetHeight ~= nil and v:GetHeight() or v.Frame.AbsoluteSize.Y) + 5
						end
					end

					return height
				end

				function Section:UpdateHeight()
					if Section.Toggled == true then
						Section.Frame.Size = UDim2.new(1, -10, 0, Section:GetHeight())
						Section.Frame.Indicator.Rotation = 45

						Tab:UpdateHeight()
					end
				end

				-- Scripts

				Tab.Sections[#Tab.Sections + 1] = Section
				Section.Frame.Parent = Tab.Frame

				Section.Frame.List.ChildAdded:Connect(function(c)
					if c.ClassName == "Frame" then
						Section:UpdateHeight()
					end
				end)

				Section.Frame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and #Section.List > 0 and Window.Sidebar.Frame.AbsoluteSize.X <= 35 and Mouse.Y - Section.Frame.AbsolutePosition.Y <= 30 then
						toggleSection(not Section.Toggled)
					end
				end)

				-- Button

				function Section:AddButton(name, callback)
					local Button = {
						Name = name,
						Type = "Button",
						Callback = callback,
					}

					Button.Frame = SelfModules.UI.Create("Frame", {
						Name = name,
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Size = UDim2.new(1, 2, 0, 32),

						SelfModules.UI.Create("Frame", {
							Name = "Holder",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
							Size = UDim2.new(1, -2, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),

							SelfModules.UI.Create("TextButton", {
								Name = "Button",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
								Position = UDim2.new(0, 2, 0, 2),
								Size = UDim2.new(1, -4, 1, -4),
								AutoButtonColor = false,
								Font = Enum.Font.SourceSans,
								Text = name,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5))

					-- Functions

					local function buttonVisual()
						task.spawn(function()
							local Visual = SelfModules.UI.Create("Frame", {
								Name = "Visual",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 0.9,
								Position = UDim2.new(0.5, 0, 0.5, 0),
								Size = UDim2.new(0, 0, 1, 0),
							}, UDim.new(0, 5))

							Visual.Parent = Button.Frame.Holder.Button
							tween(Visual, 0.5, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
							task.wait(0.5)
							Visual:Destroy()
						end)
					end

					-- Scripts

					Section.List[#Section.List + 1] = Button
					Button.Frame.Parent = Section.Frame.List

					Button.Frame.Holder.Button.MouseButton1Down:Connect(function()
						Button.Frame.Holder.Button.TextSize = 12
					end)

					Button.Frame.Holder.Button.MouseButton1Up:Connect(function()
						Button.Frame.Holder.Button.TextSize = 14
						buttonVisual()

						pcall(task.spawn, Button.Callback)
					end)

					Button.Frame.Holder.Button.MouseLeave:Connect(function()
						Button.Frame.Holder.Button.TextSize = 14
					end)

					return Button
				end

				-- Toggle

				function Section:AddToggle(name, options, callback)
					local Toggle = {
						Name = name,
						Type = "Toggle",
						Flag = options.flag or name,
						Callback = callback,
					}

					Toggle.Frame = SelfModules.UI.Create("Frame", {
						Name = name,
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Size = UDim2.new(1, 2, 0, 32),

						SelfModules.UI.Create("Frame", {
							Name = "Holder",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),

							SelfModules.UI.Create("TextLabel", {
								Name = "Label",
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 5, 0.5, -7),
								Size = UDim2.new(1, -50, 0, 14),
								Font = Enum.Font.SourceSans,
								Text = name,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),

							SelfModules.UI.Create("Frame", {
								Name = "Indicator",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
								Position = UDim2.new(1, -42, 0, 2),
								Size = UDim2.new(0, 40, 0, 26),

								SelfModules.UI.Create("ImageLabel", {
									Name = "Overlay",
									BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
									Position = UDim2.new(0, 2, 0, 2),
									Size = UDim2.new(0, 22, 0, 22),
									Image = "http://www.roblox.com/asset/?id=7827504335",
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),
					}, UDim.new(0, 5))

					-- Functions

					function Toggle:Set(bool, instant)
						Tab.Flags[Toggle.Flag] = bool

						tween(Toggle.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
						tween(Toggle.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })
					
						pcall(task.spawn, Toggle.Callback, bool)
					end

					-- Scripts

					Section.List[#Section.List + 1] = Toggle
					Tab.Flags[Toggle.Flag] = options.default == true
					Toggle.Frame.Parent = Section.Frame.List

                     Toggle.Frame.Holder.InputBegan:Connect(function(input)
                         if input.UserInputType == Enum.UserInputType.MouseButton1 then
                             Toggle:Set(not Tab.Flags[Toggle.Flag], false)
                         end
                     end)
 
                     Toggle:Set(options.default == true, true)
 
                     return Toggle
                 end
 
				-- SubSection prototype + constructor (was missing)
				local SubSection = {}

				function Section:AddSubSection(name, options)
					options = options or {}
					local sub = setmetatable({
						Name = name,
						Type = "SubSection",
						Toggled = options.default == true,
						List = {},
					}, { __index = SubSection })

					sub.Frame = SelfModules.UI.Create("Frame", {
						Name = name,
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Size = UDim2.new(1, 2, 0, 40),

						SelfModules.UI.Create("Frame", {
							Name = "Holder",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),

							SelfModules.UI.Create("Frame", {
								Name = "List",
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 5, 0, 30),
								Size = UDim2.new(1, -10, 0, 0),

								SelfModules.UI.Create("UIListLayout", {
									SortOrder = Enum.SortOrder.LayoutOrder,
									Padding = UDim.new(0, 5),
								}),

								SelfModules.UI.Create("UIPadding", {
									PaddingBottom = UDim.new(0, 1),
									PaddingLeft = UDim.new(0, 1),
									PaddingRight = UDim.new(0, 1),
									PaddingTop = UDim.new(0, 1),
								}),
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5))

					Section.List[#Section.List + 1] = sub
					sub.Frame.Parent = Section.Frame.List

					sub.Frame.List.ChildAdded:Connect(function(c)
						if c.ClassName == "Frame" then
							sub:UpdateHeight()
						end
					end)

					return sub
				end
			end
		end
	end
end

return Library

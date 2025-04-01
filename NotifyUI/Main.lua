local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local textService = game:GetService("TextService")

-- Object creation utility
local function object(class, properties)
    local localObject = Instance.new(class)
    for property, value in pairs(properties or {}) do
        pcall(function() localObject[property] = value end)
    end

    local methods = {
        AbsoluteObject = localObject
    }

    function methods:object(subClass, subProperties)
        subProperties = subProperties or {}
        subProperties.Parent = subProperties.Parent or localObject
        return object(subClass, subProperties)
    end

    function methods:round(radius)
        object("UICorner", {
            Parent = localObject,
            CornerRadius = UDim.new(0, radius or 4)
        })
        return methods
    end

    function methods:tween(mutations, tweenInfo)
        ts:Create(localObject, tweenInfo or TweenInfo.new(0.3), mutations):Play()
        return methods
    end

    return setmetatable(methods, {
        __index = function(_, k) return localObject[k] end,
        __newindex = function(_, k, v) localObject[k] = v end
    })
end

-- Notification system
local Notifications = (function()
    local gui = object("ScreenGui", {
        Parent = game:GetService("CoreGui"),
        Name = "NotificationGui",
        ResetOnSpawn = false
    })

    local notifications = {
        theme = "dark",
        activeNotification = nil,
        tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        colorSchemes = {
            dark = {
                Main = Color3.fromRGB(14, 14, 16),
                Secondary = Color3.fromRGB(30, 30, 35),
                Icon = Color3.fromRGB(255, 255, 255),
                Text = Color3.fromRGB(255, 255, 255),
                SecondaryText = Color3.fromRGB(200, 200, 200),
                Accept = Color3.fromRGB(60, 140, 60),
                Dismiss = Color3.fromRGB(140, 60, 60)
            },
            light = {
                Main = Color3.fromRGB(240, 240, 245),
                Secondary = Color3.fromRGB(230, 230, 235),
                Icon = Color3.fromRGB(60, 60, 60),
                Text = Color3.fromRGB(40, 40, 40),
                SecondaryText = Color3.fromRGB(80, 80, 80),
                Accept = Color3.fromRGB(60, 140, 60),
                Dismiss = Color3.fromRGB(140, 60, 60)
            }
        }
    }

    notifications.colorSchemes.dark.Main = getgenv().TripHub_Theme_Background or notifications.colorSchemes.dark.Main

    function notifications:setTheme(themeName)
        self.theme = self.colorSchemes[themeName] and themeName or "dark"
    end

    function notifications:notify(options)
        options = options or {}
        local theme = self.colorSchemes[self.theme]
        local hasCallbacks = options.Accept or options.Dismiss
        local duration = options.Length or (hasCallbacks and 10 or 3)

        if self.activeNotification then
            self.activeNotification:close()
        end

        local mainFrame = gui:object("Frame", {
            Size = UDim2.fromOffset(300, hasCallbacks and 100 or 56),
            Position = UDim2.new(1, 20, 1, 20),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            BackgroundColor3 = theme.Main
        }):round(8)

        local content = mainFrame:object("Frame", {
            Size = UDim2.new(1, 0, 1, hasCallbacks and -44 or 0),
            BackgroundTransparency = 1
        })

        local icon = content:object("ImageLabel", {
            Image = options.Icon and "rbxassetid://"..tostring(options.Icon) or "rbxassetid://6031071053",
            BackgroundTransparency = 1,
            ImageColor3 = theme.Icon,
            Position = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 1
        })

        local title = content:object("TextLabel", {
            Text = options.Title or "Notification",
            TextColor3 = theme.Text,
            Font = Enum.Font.SourceSansBold,
            TextSize = 16,
            Position = UDim2.new(0, 45, 0, 5),
            Size = UDim2.new(1, -55, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            TextTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd
        })

        local description
        if options.Description then
            description = content:object("TextLabel", {
                Text = options.Description,
                TextColor3 = theme.SecondaryText,
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                Position = UDim2.new(0, 45, 0, 25),
                Size = UDim2.new(1, -55, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                BackgroundTransparency = 1,
                TextTransparency = 1
            })

            local textSize = textService:GetTextSize(
                options.Description, 14, Enum.Font.SourceSans,
                Vector2.new(245, math.huge)
            )
            description.Size = UDim2.new(1, -55, 0, textSize.Y)
            mainFrame.Size = UDim2.fromOffset(300, textSize.Y + (hasCallbacks and 70 or 35))
        end

        local callbacksContainer
        if hasCallbacks then
            callbacksContainer = mainFrame:object("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.fromScale(0, 1),
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = theme.Secondary,
                BackgroundTransparency = 1
            }):round(8)
        end

        local function createButton(config, color, position)
            local btn = callbacksContainer:object("TextButton", {
                Size = UDim2.new(0.45, -10, 0, 24),
                Position = position,
                BackgroundColor3 = color,
                TextColor3 = theme.Text,
                Font = Enum.Font.SourceSansBold,
                TextSize = 14,
                Text = config.Text or "Button",
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):round(6)
            
            btn.MouseButton1Click:Connect(function()
                if config.Callback then config.Callback() end
                notification:close()
            end)
            return btn
        end

        local acceptBtn, dismissBtn
        if options.Accept then
            acceptBtn = createButton(options.Accept, theme.Accept, UDim2.new(0, 5, 0.5, 0))
        end
        if options.Dismiss then
            dismissBtn = createButton(options.Dismiss, theme.Dismiss, UDim2.new(1, -5, 0.5, 0))
            dismissBtn.AnchorPoint = Vector2.new(1, 0.5)
        end

        local notification = {
            closing = false,
            frame = mainFrame
        }

        function notification:close()
            if self.closing then return end
            self.closing = true
            self.activeNotification = nil

            local fadeOut = {
                BackgroundTransparency = 1,
                TextTransparency = 1,
                ImageTransparency = 1
            }
            
            -- Animación de salida: mueve la notificación hacia la derecha mientras se desvanece
            mainFrame:tween({
                Position = UDim2.new(1, 320, 1, -20), -- Mueve fuera de la pantalla
                BackgroundTransparency = 1
            }, TweenInfo.new(0.3))
            
            icon:tween(fadeOut)
            title:tween(fadeOut)
            if description then description:tween(fadeOut) end
            if callbacksContainer then callbacksContainer:tween(fadeOut) end
            if acceptBtn then acceptBtn:tween(fadeOut) end
            if dismissBtn then dismissBtn:tween(fadeOut) end
            
            -- Destruir después de la animación
            task.delay(0.3, function()
                if mainFrame and mainFrame.Parent then
                    mainFrame:Destroy()
                end
            end)
        end

        -- Animación de entrada
        mainFrame.Position = UDim2.new(1, 320, 1, -20) -- Posición inicial fuera de pantalla
        mainFrame:tween({
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -20, 1, -20)
        })
        icon:tween({ImageTransparency = 0})
        title:tween({TextTransparency = 0})
        if description then description:tween({TextTransparency = 0}) end
        if callbacksContainer then callbacksContainer:tween({BackgroundTransparency = 0}) end
        if acceptBtn then acceptBtn:tween({BackgroundTransparency = 0, TextTransparency = 0}) end
        if dismissBtn then dismissBtn:tween({BackgroundTransparency = 0, TextTransparency = 0}) end

        if duration > 0 then
            task.delay(duration, function()
                if not notification.closing then notification:close() end
            end)
        end

        self.activeNotification = notification
        return notification
    end

    notifications.notification = notifications.notify
    notifications.message = notifications.notify

    return notifications
end)()

-- Global setup
getgenv().NotificationLib = Notifications
getgenv().Notification_Loaded = true
getgenv().Notify = function(title, description, duration, options)
    options = options or {}
    options.Title = title
    options.Description = description
    options.Icon = options.Icon or 6031071053
    options.Length = duration or 4
    return Notifications:notify(options)
end


return Notifications

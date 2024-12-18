local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local function object(class, properties)

    local localObject = Instance.new(class)

    for property, value in next, properties do
        pcall(function() localObject[property] = value end)
    end

    local methods = {}

    function methods:object(subClass, subProperties)
        if not subProperties["Parent"] then 
            subProperties.Parent = localObject 
        end
        return object(subClass, subProperties)
    end

    function methods:round(radius)
        radius = radius or 4
        object("UICorner", {
            Parent = localObject,
            CornerRadius = UDim.new(0, radius)
        })
        return methods
    end

    function methods:tween(mutations)
        if ts then
            ts:Create(localObject, TweenInfo.new(0.3), mutations):Play()
        else
            warn("TweenService no está definido.")
        end
    end

    methods.AbsoluteObject = localObject

    return setmetatable(methods, {
        __index = function(_, k) 
            return localObject[k] 
        end,
        __newindex = function(_, k, v) 
            localObject[k] = v 
        end
    })
end


local gui = object("ScreenGui", {Parent = game:WaitForChild("CoreGui")})

local notifications = {
    theme = "dark",
    colorSchemes = {
        dark = {
            Main = Color3.fromRGB(40, 40, 45),
            Secondary = Color3.fromRGB(30, 30, 35),
            Icon = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(255, 255, 255),
            SecondaryText = Color3.fromRGB(200, 200, 200),
            Accept = Color3.fromRGB(60, 40, 200),
            Dismiss = Color3.fromRGB(60, 60, 65)
        }
    },
    closeOpened = nil
}

if getgenv().TripHub_Theme_Background then
    notifications.colorSchemes.dark.Main = getgenv().TripHub_Theme_Background
else
    notifications.colorSchemes.dark.Main = Color3.fromRGB(40, 40, 45)
end

function notifications:notify(options)
    local theme = self.colorSchemes[notifications.theme]
    local callbacksBool = options.Accept or options.Dismiss
    options.Title = options.Title or "Notification"
    if not callbacksBool then options.Length = 3 end
    if self.closeOpened then self.closeOpened() end

    local mainFrame = gui:object("Frame", {
        Size = UDim2.fromOffset(300, (callbacksBool and 100) or 56),
        Position = UDim2.new(1, -20, 1, -10),
        AnchorPoint = Vector2.new(1, 1),
        Visible = false,
        BackgroundTransparency = 1
    }):round()

    game:GetService('RunService').RenderStepped:Connect(function()
    mainFrame.BackgroundColor3 = theme.Main
    end)

    local content = mainFrame:object("Frame", {
        Size = UDim2.new(1, 0, 1, ((callbacksBool and -44) or 0)),
        BackgroundTransparency = 1
    })

    local icon = content:object("ImageLabel", {
        Image = (options.Icon and ("rbxassetid://" .. tostring(options.Icon))) or
            "rbxassetid://6031071053",
        BackgroundTransparency = 1,
        ImageColor3 = theme.Icon,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 15, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        ImageTransparency = 1
    })

    local title = content:object("TextLabel", {
        TextColor3 = theme.Text,
        Font = Enum.Font.SourceSansSemibold,
        TextSize = 18,
        Position = UDim2.fromOffset(60, 10),
        Size = UDim2.new(1, -70, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Text = options.Title,
        RichText = true,
        TextTransparency = 1
    })

    local description;
    if options.Description then
        description = content:object("TextLabel", {
            TextColor3 = theme.SecondaryText,
            Font = Enum.Font.SourceSans,
            TextSize = 18,
            Position = UDim2.new(0, 60, 0, 35),
            Size = UDim2.new(1, -70, 0, 0), 
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Text = options.Description,
            TextWrapped = true,
            RichText = true,
            TextTransparency = 1
        })

        local descriptionHeight = game:GetService("TextService"):GetTextSize(
                                      options.Description, 18,
                                      Enum.Font.SourceSans, Vector2.new(
                                          description.AbsoluteSize.X, math.huge)).Y
        description.Size = UDim2.new(1, -70, 0, descriptionHeight)
    end

    local callbacksContainer;
    if callbacksBool then
        callbacksContainer = mainFrame:object("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            BackgroundColor3 = theme.Secondary,
            BackgroundTransparency = 1
        }):round()

        local roundCorrection = callbacksContainer:object("Frame", {
            Size = UDim2.fromScale(1, 0.5),
            BackgroundColor3 = theme.Secondary,
            BackgroundTransparency = 1
        })
    end

    local close

    local acceptButton;
    if options.Accept then
        options.Accept.Callback = options.Accept.Callback or function() end
        acceptButton = callbacksContainer:object("TextButton", {
            Size = UDim2.new(0, 100, 0.5, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundColor3 = theme.Accept,
            AnchorPoint = Vector2.new(0.5, 0.5),
            TextColor3 = theme.Text,
            Font = Enum.Font.SourceSans,
            TextSize = 18,
            Text = options.Accept.Text or "Yes",
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):round()

        if acceptButton.TextBounds.X > 100 then
            acceptButton.Size = UDim2.new(0, acceptButton.TextBounds.X + 10,
                                          0.5, 0)
        end

        acceptButton.MouseButton1Click:connect(function()
            options.Accept.Callback()
            close()
        end)
    end

    local dismissButton;
    if options.Dismiss then
        options.Dismiss.Callback = options.Dismiss.Callback or function() end
        dismissButton = callbacksContainer:object("TextButton", {
            Size = UDim2.new(0, 100, 0.5, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundColor3 = theme.Dismiss,
            AnchorPoint = Vector2.new(0.5, 0.5),
            TextColor3 = theme.Text,
            Font = Enum.Font.SourceSans,
            TextSize = 18,
            Text = options.Dismiss.Text or "No",
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):round()

        if dismissButton.TextBounds.X > 100 then
            dismissButton.Size = UDim2.new(0, dismissButton.TextBounds.X + 10,
                                           0.5, 0)
        end

        dismissButton.MouseButton1Click:connect(function()
            options.Dismiss.Callback()
            close()
        end)
    end

    local closing = false

    close = function()
        closing = true
        self.closeOpened = nil
        spawn(function()
            icon:tween{ImageTransparency = 1}
            title:tween{TextTransparency = 1}
            if description then
                description:tween{TextTransparency = 1}
            end
            if acceptButton then
                acceptButton:tween{
                    BackgroundTransparency = 1,
                    TextTransparency = 1
                }
            end
            if dismissButton then
                dismissButton:tween{
                    BackgroundTransparency = 1,
                    TextTransparency = 1
                }
            end
            task.wait(0.15)
            if callbacksContainer then
                callbacksContainer:tween{BackgroundTransparency = 1}
            end
            task.wait(0.1)
            mainFrame:tween{
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 1, -10)
            }
            task.wait(0.25)
            mainFrame:Destroy()
        end)
    end

    self.closeOpened = close

    if description then
        mainFrame.Size = UDim2.fromOffset(math.clamp(70 +
                                                         description.TextBounds
                                                             .X, 230, 300),
                                          description.AbsoluteSize.Y + 60 +
                                              (callbacksBool and 44 or 0))
    end

    description.Size = UDim2.new(1, -70, 0,
                                 description and description.TextBounds.Y or 0)

    if options.Accept and options.Dismiss then
        acceptButton.Position = UDim2.new(0.5, 5, 0.5, 0)
        acceptButton.AnchorPoint = Vector2.new(0, 0.5)
        dismissButton.Position = UDim2.new(0.5, -5, 0.5, 0)
        dismissButton.AnchorPoint = Vector2.new(1, 0.5)
    end

    mainFrame.Visible = true
    mainFrame:tween{
        BackgroundTransparency = 0,
        Position = UDim2.new(1, -20, 1, -10)
    }

    icon:tween{ImageTransparency = 0}
    title:tween{TextTransparency = 0}
    if description then description:tween{TextTransparency = 0} end
    if acceptButton then
        acceptButton:tween{BackgroundTransparency = 0, TextTransparency = 0}
    end
    if dismissButton then
        dismissButton:tween{BackgroundTransparency = 0, TextTransparency = 0}
    end
    
    task.spawn(function()
        task.wait(options.Length or 4)
        if not closing then close() end
    end)
end

function notifications:notification(options) self:notify(options) end

function notifications:message(options) self:notify(options) end

return notifications



local NotificationLibUrl = "https://raw.githubusercontent.com/elxocasXD/Trip-Hub/main/NotifyUI/Notification.lua"

if getgenv().Notification_Loaded and getgenv().NotificationLib then
    print("[Notification]: It was already loaded")
else
    getgenv().NotificationLib = loadstring(game:HttpGet(NotificationLibUrl))()
    getgenv().Notification_Loaded = true

    getgenv().Notify = function(title, description)
        getgenv().NotificationLib:notify {
            Title = title,
            Description = description,
            Icon = 6031071053,
            Length = 3
        }
    end

    print("[Notification]: Library loaded successfully")
end

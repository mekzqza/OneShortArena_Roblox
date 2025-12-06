local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventBus = require(ReplicatedStorage:FindFirstChild("SystemsShared"):FindFirstChild("EventBus"))

local AssetUI = ReplicatedStorage:FindFirstChild("UI")
local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UIController = {}
UIController.LoadScreens ={}
function UIController:LoadScreens(screensName:string)
    if self.LoadScreens[screensName] then
        warn("Screen "..screensName.." is already loaded.")
        return
    end

    local originalScreen = AssetUI:FindFirstChild(screensName)
    if not originalScreen then
        warn("Screen "..screensName.." does not exist in AssetUI.")
        return
    end

    --load screen 1
    local newScreen = originalScreen:Clone()

    --เก็บไว้ใน PlayerGui 2
    newScreen.Parent = playerGui

    --เก็บไว้ในตาราง LoadScreens 3
    self.LoadScreens[screensName] = newScreen

    --แสดงผลใน Output ว่าโหลด UI แล้ว 4
    print(" UI Loaded :"..screensName)

    return newScreen
end

function UIController:Init()
    
    -- ตัวอย่างการโหลดหน้าจอ UI
    local hud = self:LoadScreens("HUD")

    if hud then
        print("HUD screen loaded successfully.")
    else
        warn("Failed to load HUD screen.")
    end

    EventBus:On("Toggle_UI", function(Uiname: string,isVisible: boolean)
        local screen = self.LoadScreens[Uiname] or self:LoadScreens(Uiname)
        if screen then
            screen.Enabled = isVisible
            print("Toggled UI "..Uiname.." to "..tostring(isVisible))
        else
            warn("UI "..Uiname.." not found to toggle.")
        end
    end)

    print("UIController initialized.")


end

return UIController
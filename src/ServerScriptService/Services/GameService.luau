--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- เรียกใช้ EventBus และ Events
local EventBus = require(ReplicatedStorage.SystemsShared.EventBus)
local Events = require(ReplicatedStorage.Shared.Events)

local GameService = {}

-- ============================================================================
-- ⚙️ Config (ตั้งค่า)
-- ============================================================================
local MIN_PLAYERS = 1         -- จำนวนคนขั้นต่ำที่จะเริ่มเกม (ตั้งเป็น 1 เพื่อเทสต์คนเดียวได้)
local LOBBY_WAIT_TIME = 10    -- เวลานับถอยหลัง (วินาที)

-- ============================================================================
-- 📊 State (สถานะปัจจุบัน)
-- ============================================================================
local isMatchActive = false
local lobbyTimer = LOBBY_WAIT_TIME

--[[\
    Init: ทำงานตอน Server เริ่มโหลด (เตรียมการ)
--]]
function GameService:Init()
    print("🏗️ GameService: Initializing...")
    
    -- เช็คความปลอดภัย: สร้างโฟลเดอร์ Spawns ให้ถ้าลืมสร้าง
    if not Workspace:FindFirstChild("Spawns") then
        local folder = Instance.new("Folder")
        folder.Name = "Spawns"
        folder.Parent = Workspace
        warn("⚠️ GameService: Created 'Spawns' folder. Please add a SpawnLocation named 'LobbySpawn' inside it!")
    end
end

--[[\
    Start: ทำงานหลัง Init (เริ่มระบบจริง)
--]]
function GameService:Start()
    print("🏁 GameService: Lobby System Started")

    -- 1. เมื่อผู้เล่นเข้าเกม -> บังคับให้ไปเกิดที่ Lobby
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerJoin(player)
    end)
    
    -- 2. เมื่อผู้เล่นออก -> ส่งข่าวบอกระบบอื่น
    Players.PlayerRemoving:Connect(function(player)
        EventBus:Emit(Events.PLAYER_LEFT, player)
    end)

    -- 3. เริ่มลูปหลักของเกม (Game Loop) แยก Thread ออกไปทำงานตลอดเวลา
    task.spawn(function()
        while true do
            self:GameLoop()
            task.wait(1) -- เช็คทุกๆ 1 วินาที
        end
    end)
end

--[[\
    OnPlayerJoin: จัดการผู้เล่นใหม่
--]]
function GameService:OnPlayerJoin(player: Player)
    print("👋 " .. player.Name .. " joined the lobby.")
    
    -- ค้นหาจุดเกิด Lobby ใน Workspace
    local spawns = Workspace:FindFirstChild("Spawns")
    local lobbySpawn = spawns and spawns:FindFirstChild("LobbySpawn")
    
    if lobbySpawn and lobbySpawn:IsA("SpawnLocation") then
        -- ✅ บังคับจุดเกิดของผู้เล่นคนนี้ให้เป็น LobbySpawn
        player.RespawnLocation = lobbySpawn
    else
        warn("⚠️ CRITICAL: 'LobbySpawn' (SpawnLocation) not found inside Workspace.Spawns!")
    end
    
    -- สั่งโหลดตัวละครทันที (เพื่อให้มายืนใน Lobby)
    player:LoadCharacter()
    
    -- แจ้งระบบอื่นว่ามีคนมาเพิ่ม
    EventBus:Emit(Events.PLAYER_JOINED, player)
end

--[[\
    GameLoop: หัวใจหลักของเกม (ทำงานทุกวินาที)
--]]
function GameService:GameLoop()
    -- ถ้าเกมเริ่มไปแล้ว ให้ข้าม Logic ของ Lobby ไป
    if isMatchActive then
        return
    end

    -- === Logic: การรอใน Lobby ===
    local playerCount = #Players:GetPlayers()
    
    if playerCount >= MIN_PLAYERS then
        -- คนครบ! เริ่มนับถอยหลัง
        lobbyTimer -= 1
        print("⏳ Waiting for match: " .. lobbyTimer)
        
        -- ส่งเวลาไปบอก UI (เพื่อให้หน้าจอผู้เล่นแสดงเลข)
        EventBus:Emit(Events.UI_SHOW_NOTIFICATION, "Starting in " .. lobbyTimer)
        
        -- ถ้าเวลานับถึง 0 -> เริ่มเกมเลย!
        if lobbyTimer <= 0 then
            self:StartMatch()
        end
    else
        -- คนไม่พอ -> รีเซ็ตเวลา
        if lobbyTimer ~= LOBBY_WAIT_TIME then
            lobbyTimer = LOBBY_WAIT_TIME
            print("❌ Not enough players. Timer reset.")
            EventBus:Emit(Events.UI_SHOW_NOTIFICATION, "Waiting for players...")
        end
    end
end

--[[\
    StartMatch: สั่งเริ่มเกมจริง
--]]
function GameService:StartMatch()
    print("🚀 STARTING MATCH!")
    isMatchActive = true
    
    -- ส่งสัญญาณเริ่มเกม! (ArenaService จะรับช่วงต่อเพื่อวาร์ปคน)
    EventBus:Emit(Events.GAME_STARTED)
end

return GameService
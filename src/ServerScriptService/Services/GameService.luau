--[[
	GameService - ตัวอย่างการใช้งาน EventBus ฝั่ง Server
	
	📌 หน้าที่:
	Service นี้แสดงตัวอย่างการใช้งาน EventBus สำหรับการสื่อสารระหว่าง Server-Server
	
	🔧 ฟีเจอร์ตัวอย่าง:
	- รับฟังอีเวนต์เมื่อผู้เล่นเข้าเกม
	- ส่งอีเวนต์เมื่อเกมเริ่ม
	- ใช้ Once สำหรับอีเวนต์ที่เกิดครั้งเดียว
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventBus = require(ReplicatedStorage.SystemsShared.EventBus)
local Events = require(ReplicatedStorage.Shared.Events)

local GameService = {}
GameService.isGameRunning = false
GameService.playerConnections = {} -- เก็บ connections เพื่อ cleanup

--[[
	Init: เริ่มต้น Service
	เรียกโดย Init.server.luau เมื่อเซิร์ฟเวอร์เริ่มทำงาน
--]]
function GameService:Init()
	print("🎮 GameService: Initializing...")
	
	-- ตัวอย่าง: ฟังอีเวนต์เมื่อเกมเริ่ม (แค่ครั้งเดียว)
	EventBus:Once(Events.GAME_STARTED, function(gameMode)
		self.isGameRunning = true
		print("🎮 Game has started! Mode:", gameMode)
	end)
	
	-- ตัวอย่าง: ฟังอีเวนต์เมื่อเกมจบ
	EventBus:On(Events.GAME_ENDED, function(winner)
		self.isGameRunning = false
		print("🎮 Game ended! Winner:", winner or "None")
		
		-- ทำความสะอาดข้อมูลเกม
		self:CleanupGame()
	end)
	
	-- ตัวอย่าง: ฟังอีเวนต์เมื่อผู้เล่นทำคะแนน
	EventBus:On(Events.PLAYER_SCORED, function(playerName, points)
		print("⭐ " .. playerName .. " scored " .. points .. " points!")
		
		-- ส่งอีเวนต์อื่นต่อ (Event Chain)
		EventBus:Emit(Events.PLAYER_STATS_UPDATED, playerName, { score = points })
	end)
	
	-- ตัวอย่าง: รับฟังอีเวนต์สำหรับ debug
	EventBus:On(Events.DEBUG_SHOW_EVENTS, function()
		local events = EventBus:GetEventNames()
		print("📋 Active Events:", table.concat(events, ", "))
	end)
	
	-- เชื่อมต่อกับ Players service
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeft(player)
	end)
	
	-- ส่งอีเวนต์ว่า GameService พร้อมแล้ว
	EventBus:Emit(Events.SERVICE_READY, "GameService")
	
	print("✅ GameService initialized.")
end

--[[
	OnPlayerJoined: เมื่อผู้เล่นเข้าเกม
	@param player: Player - ผู้เล่นที่เข้าเกม
--]]
function GameService:OnPlayerJoined(player: Player)
	print("👋 Player joined:", player.Name)
	
	-- ส่งอีเวนต์แจ้งว่ามีผู้เล่นเข้ามา
	EventBus:Emit(Events.PLAYER_JOINED, player.Name, player.UserId)
	
	-- ตัวอย่าง: สร้าง connection เฉพาะสำหรับผู้เล่น
	local connection = EventBus:On("Player_RequestInfo_" .. player.UserId, function()
		print("📊 Info requested for:", player.Name)
		-- ส่งข้อมูลผู้เล่นกลับไป
		EventBus:Emit("Player_InfoResponse_" .. player.UserId, {
			name = player.Name,
			userId = player.UserId,
			isInGame = self.isGameRunning
		})
	end)
	
	-- เก็บ connection ไว้สำหรับ cleanup
	self.playerConnections[player.UserId] = connection
end

--[[
	OnPlayerLeft: เมื่อผู้เล่นออกจากเกม
	@param player: Player - ผู้เล่นที่ออกจากเกม
--]]
function GameService:OnPlayerLeft(player: Player)
	print("👋 Player left:", player.Name)
	
	-- ส่งอีเวนต์แจ้งว่าผู้เล่นออกไป
	EventBus:Emit(Events.PLAYER_LEFT, player.Name, player.UserId)
	
	-- ทำความสะอาด connection ของผู้เล่น
	local connection = self.playerConnections[player.UserId]
	if connection then
		connection:Disconnect()
		self.playerConnections[player.UserId] = nil
	end
end

--[[
	StartGame: เริ่มเกม
	@param gameMode: string - โหมดเกม
	
	ตัวอย่างการเรียกใช้จาก Service อื่น:
	local GameService = require(...)
	GameService:StartGame("FreeForAll")
--]]
function GameService:StartGame(gameMode: string)
	if self.isGameRunning then
		warn("⚠️ Game is already running!")
		return
	end
	
	print("🎮 Starting game with mode:", gameMode)
	
	-- ส่งอีเวนต์เกมเริ่ม
	EventBus:Emit(Events.GAME_STARTED, gameMode)
end

--[[
	EndGame: จบเกม
	@param winner: string? - ชื่อผู้ชนะ (optional)
--]]
function GameService:EndGame(winner: string?)
	if not self.isGameRunning then
		warn("⚠️ No game is running!")
		return
	end
	
	print("🎮 Ending game...")
	
	-- ส่งอีเวนต์เกมจบ
	EventBus:Emit(Events.GAME_ENDED, winner)
end

--[[
	CleanupGame: ทำความสะอาดข้อมูลเกม
	ใช้เมื่อเกมจบหรือต้องการ reset
--]]
function GameService:CleanupGame()
	print("🧹 Cleaning up game data...")
	
	-- ทำความสะอาดข้อมูลต่างๆ
	-- (เพิ่มโค้ด cleanup ตามต้องการ)
	
	EventBus:Emit(Events.GAME_CLEANUP_COMPLETE)
end

return GameService

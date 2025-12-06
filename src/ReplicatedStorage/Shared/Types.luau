--[[
	Types.luau - Type Definitions สำหรับโปรเจ็กต์
	
	📌 หน้าที่:
	เก็บ Type definitions ทั้งหมดของโปรเจ็กต์ไว้ในที่เดียว
	เพื่อให้ใช้งานได้ทั่วทั้งโปรเจ็กต์และช่วยในการ type checking
--]]

export type EventCallback = (...any) -> ()
export type EventConnection = RBXScriptConnection

-- EventBus Types
export type EventBus = {
	signals: { [string]: BindableEvent },
	On: (self: EventBus, eventName: string, callback: EventCallback) -> EventConnection,
	Once: (self: EventBus, eventName: string, callback: EventCallback) -> EventConnection,
	Emit: (self: EventBus, eventName: string, ...any) -> (),
	Off: (self: EventBus, eventName: string) -> (),
	Clear: (self: EventBus) -> (),
	GetEventNames: (self: EventBus) -> {string},
}

-- Player Data Types (ตัวอย่าง - เพิ่มเติมตามโครงสร้างข้อมูลของเกม)
export type PlayerData = {
	userId: number,
	name: string,
	level: number,
	score: number,
	isInGame: boolean,
}

-- Game Types (ตัวอย่าง)
export type GameMode = "FreeForAll" | "TeamDeathmatch" | "CaptureTheFlag"

export type GameState = {
	isRunning: boolean,
	mode: GameMode,
	startTime: number?,
	endTime: number?,
	winner: string?,
}

return {}
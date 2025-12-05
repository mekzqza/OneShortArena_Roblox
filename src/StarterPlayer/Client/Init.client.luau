local ReplicatedStorage = game:GetService("ReplicatedStorage")
local controllersFolder = script.Parent:WaitForChild("Controllers")

print("🔌 Client Init: Starting Controllers...")

for _, controllerModule in pairs(controllersFolder:GetChildren()) do
    if controllerModule:IsA("ModuleScript") then
        -- ใช้ task.spawn เพื่อแยก Thread (ตัวใครตัวมัน ไม่รอกัน)
        task.spawn(function()
            local controller = require(controllerModule)
            
            -- เช็คว่ามีฟังก์ชัน Init ไหม ถ้ามีให้เรียกใช้
            if type(controller.Init) == "function" then
                -- ใช้ pcall กัน Error พังทั้งระบบ
                local success, err = pcall(function()
                    controller:Init() -- แนะนำใช้ : ถ้าออกแบบเป็น OOP/Singleton
                end)
                
                if not success then
                    warn("❌ Failed to init " .. controllerModule.Name .. ": " .. err)
                end
            end
        end)
    end
end
print("✅ Controllers initialized.")
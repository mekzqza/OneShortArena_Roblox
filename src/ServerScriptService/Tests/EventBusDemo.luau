--[[
	EventBusDemo.luau - ตัวอย่างและการทดสอบ EventBus
	
	📌 หน้าที่:
	ไฟล์นี้แสดงตัวอย่างการใช้งาน EventBus และทดสอบฟีเจอร์ต่างๆ
	สามารถรันไฟล์นี้เพื่อดูผลลัพธ์ของ EventBus ได้
	
	⚠️ หมายเหตุ:
	นี่เป็นไฟล์ demo/test เท่านั้น ไม่ใช่ unit test แบบเต็มรูปแบบ
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventBus = require(ReplicatedStorage.SystemsShared.EventBus)

print("\n" .. string.rep("=", 60))
print("🧪 EventBus Demo & Tests")
print(string.rep("=", 60) .. "\n")

-- Test 1: Basic On and Emit
print("Test 1: Basic On and Emit")
print("-" .. string.rep("-", 59))
local testPassed1 = false
local connection1 = EventBus:On("Test_Event", function(message)
	print("✅ Received event:", message)
	testPassed1 = true
end)

EventBus:Emit("Test_Event", "Hello EventBus!")
assert(testPassed1, "❌ Test 1 failed: Event was not received")
print("✅ Test 1 passed\n")

-- Test 2: Multiple Arguments
print("Test 2: Multiple Arguments")
print("-" .. string.rep("-", 59))
local testPassed2 = false
EventBus:On("Test_MultiArgs", function(name, age, isActive)
	print(string.format("✅ Received: name=%s, age=%d, isActive=%s", name, tostring(age), tostring(isActive)))
	testPassed2 = (name == "John" and age == 25 and isActive == true)
end)

EventBus:Emit("Test_MultiArgs", "John", 25, true)
assert(testPassed2, "❌ Test 2 failed: Arguments not received correctly")
print("✅ Test 2 passed\n")

-- Test 3: Once (Should only fire once)
print("Test 3: Once (One-time subscription)")
print("-" .. string.rep("-", 59))
local onceCounter = 0
EventBus:Once("Test_Once", function()
	onceCounter = onceCounter + 1
	print("✅ Once event fired (count:", onceCounter .. ")")
end)

EventBus:Emit("Test_Once")
task.wait(0.1)
EventBus:Emit("Test_Once") -- This should NOT fire
task.wait(0.1)

assert(onceCounter == 1, "❌ Test 3 failed: Once fired " .. onceCounter .. " times instead of 1")
print("✅ Test 3 passed (fired exactly once)\n")

-- Test 4: Multiple Listeners
print("Test 4: Multiple Listeners")
print("-" .. string.rep("-", 59))
local listener1Fired = false
local listener2Fired = false
local listener3Fired = false

EventBus:On("Test_MultipleListeners", function()
	listener1Fired = true
	print("✅ Listener 1 fired")
end)

EventBus:On("Test_MultipleListeners", function()
	listener2Fired = true
	print("✅ Listener 2 fired")
end)

EventBus:On("Test_MultipleListeners", function()
	listener3Fired = true
	print("✅ Listener 3 fired")
end)

EventBus:Emit("Test_MultipleListeners")
task.wait(0.1)

assert(listener1Fired and listener2Fired and listener3Fired, 
	"❌ Test 4 failed: Not all listeners fired")
print("✅ Test 4 passed (all listeners fired)\n")

-- Test 5: Connection Disconnect
print("Test 5: Connection Disconnect")
print("-" .. string.rep("-", 59))
local disconnectCounter = 0
local connToDisconnect = EventBus:On("Test_Disconnect", function()
	disconnectCounter = disconnectCounter + 1
	print("✅ Event fired (count:", disconnectCounter .. ")")
end)

EventBus:Emit("Test_Disconnect") -- Should fire (count: 1)
task.wait(0.1)

connToDisconnect:Disconnect() -- Disconnect now
print("🔌 Connection disconnected")

EventBus:Emit("Test_Disconnect") -- Should NOT fire
task.wait(0.1)

assert(disconnectCounter == 1, "❌ Test 5 failed: Event fired after disconnect")
print("✅ Test 5 passed (event stopped after disconnect)\n")

-- Test 6: Off (Remove all listeners)
print("Test 6: Off (Remove all listeners)")
print("-" .. string.rep("-", 59))
local offCounter = 0
EventBus:On("Test_Off", function()
	offCounter = offCounter + 1
end)
EventBus:On("Test_Off", function()
	offCounter = offCounter + 1
end)

EventBus:Emit("Test_Off") -- Both should fire (count: 2)
task.wait(0.1)
print("✅ Before Off: count =", offCounter)

EventBus:Off("Test_Off") -- Remove all listeners
print("🔌 Called EventBus:Off('Test_Off')")

local countBeforeOff = offCounter
EventBus:Emit("Test_Off") -- Should NOT fire
task.wait(0.1)

assert(offCounter == countBeforeOff, "❌ Test 6 failed: Events still fired after Off")
print("✅ Test 6 passed (all listeners removed)\n")

-- Test 7: GetEventNames
print("Test 7: GetEventNames")
print("-" .. string.rep("-", 59))
EventBus:On("Test_GetNames_1", function() end)
EventBus:On("Test_GetNames_2", function() end)
EventBus:On("Test_GetNames_3", function() end)

local eventNames = EventBus:GetEventNames()
print("✅ Active events:", table.concat(eventNames, ", "))

local found1, found2, found3 = false, false, false
for _, name in ipairs(eventNames) do
	if name == "Test_GetNames_1" then found1 = true end
	if name == "Test_GetNames_2" then found2 = true end
	if name == "Test_GetNames_3" then found3 = true end
end

assert(found1 and found2 and found3, "❌ Test 7 failed: Not all events found")
print("✅ Test 7 passed (all events listed)\n")

-- Test 8: Error Handling (pcall protection)
print("Test 8: Error Handling")
print("-" .. string.rep("-", 59))
local errorTestPassed = false
EventBus:On("Test_Error", function()
	error("Intentional error for testing") -- This should not crash the system
end)

EventBus:On("Test_Error", function()
	-- This listener should still work even if previous one errors
	errorTestPassed = true
	print("✅ Second listener still works after first one errored")
end)

EventBus:Emit("Test_Error")
task.wait(0.1)

assert(errorTestPassed, "❌ Test 8 failed: Error in one listener stopped others")
print("✅ Test 8 passed (error handling works)\n")

-- Test 9: Clear (Remove all events)
print("Test 9: Clear (Remove all events)")
print("-" .. string.rep("-", 59))
local clearTestCounter = 0
EventBus:On("Test_Clear_1", function() clearTestCounter = clearTestCounter + 1 end)
EventBus:On("Test_Clear_2", function() clearTestCounter = clearTestCounter + 1 end)

EventBus:Emit("Test_Clear_1")
EventBus:Emit("Test_Clear_2")
task.wait(0.1)
print("✅ Before Clear: count =", clearTestCounter)

local countBeforeClear = clearTestCounter
EventBus:Clear() -- Clear all events
print("🧹 Called EventBus:Clear()")

EventBus:Emit("Test_Clear_1")
EventBus:Emit("Test_Clear_2")
task.wait(0.1)

assert(clearTestCounter == countBeforeClear, "❌ Test 9 failed: Events still fired after Clear")
print("✅ Test 9 passed (all events cleared)\n")

-- Summary
print(string.rep("=", 60))
print("🎉 All EventBus tests passed!")
print(string.rep("=", 60))
print("\n💡 EventBus is ready for production use!")
print("📖 See EventBus_README.md for detailed documentation\n")

return true

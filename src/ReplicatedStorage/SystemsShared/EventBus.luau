---- หัวใจสำคัญของการสื่อสารในระบบของเรา -
-- EventBus Module

local EventBus = {}
EventBus._signals = {}

type  EventBusType = {
    On: (eventName: string, callback: () -> ()) -> RBXScriptConnection,
    Emit: (eventName: string, ...any) -> (),
    Once: (eventName: string, callback: () -> ()) -> (),
}

local function getSignal(eventName: string): Instance
    if not EventBus.signals[eventName] then
        EventBus.signals[eventName] = Instance.new("BindableEvent")
    end
    return EventBus.signals[eventName]
end

 --ฟังก์ชันสำหรับสมัครรับเหตุการณ์
function EventBus.On(eventName: string, callback: () -> ())
    local signal = getSignal(eventName)
    return signal.Event:Connect(callback)
end

--ฟังก์ชันสำหรับส่งเหตุการณ์
function EventBus.Emit(eventName: string, ...)
    local signal = getSignal(eventName)
    signal:Fire(...)
end

function EventBus.Once(eventName: string, callback: () -> ())
    local connection
    connection = EventBus.On(eventName, function(...)
        if connection then
            connection:Disconnect()
            connection = nil
        end
        callback(...)
    end)
end

return EventBus
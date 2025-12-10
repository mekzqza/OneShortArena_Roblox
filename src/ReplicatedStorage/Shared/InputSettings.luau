local InputSettings = {
    -- เอาชื่อ Action และการแมปปิ้งคีย์มาเก็บไว้ในตาราง
    Actions ={
        ATTACK = "Attack",
        DASH = "Dash",
        INTERRACT = "Interact",
        JUMP = "Jump",
    },
    --กำหนดการตั้งต่าเริ่มต้นของการแมปปิ้งคีย์
    Bindings={
        ATTACK = {Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2},
        DASH = {Enum.KeyCode.Q, Enum.KeyCode.ButtonL1},
        INTERACT ={Enum.KeyCode.F, Enum.KeyCode.ButtonX},
    },

    --ตั้งชื่อปุ่มที่จะแสดงบนมือถือ
    MobileButtonNames={
        ATTACK = "AttackButton",
        DASH = "DashButton",
        INTERACT = "InteractButton",
    }
    

}
return InputSettings
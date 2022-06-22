---Special Thanks To The DevForum For Helping Me Get This Specific Script!---
                       ---DevEthel---
local trapPart = script.Parent
local function onPartTouch(otherPart)
    local partParent = otherPart.Parent
    local humanoid = partParent:FindFirstChildWhichIsA("Humanoid")
    if ( humanoid ) then
        -- Set player's health to 0
        humanoid.Health = humanoid.Health -1
    end
end
trapPart.Touched:Connect(onPartTouch)
local M = {}
local firstEngine = powertrain.getDevicesByType("combustionEngine")[1]
local SafetySwitch = v.data.controller[0].SafetySwitch or false
local gearbox
local debugmode = false
local triggerpoint = 0.85

local function onInit()
   for _, d in pairs(powertrain.getOrderedDevices()) do
        if (string.find(d.type, "Gearbox")) then
            gearbox = d

            break
        end
    end
end
local function onUpdate()
   
    if (SafetySwitch) then
        if(not firstEngine) then
            guihooks.message("There's no combustion engine in your vehicle.\nExpected type: combustionEngine\nCurrent type: "..(firstEngine and firstEngine.type or "Nothing"), 5, "error", "error")
            M.updateGFX = nop
           return
            
        end
   
        if( firstEngine) then
            if (debugmode) then
                local str =
                    "Gearbox type: " ..
                    gearbox.type ..
                        "\nParent type:" ..
                            gearbox.parent.type .. "\nStarter allowed: " .. (gearbox.parent.type == "frictionClutch" and tostring(electrics.values.clutch > triggerpoint) or tostring(electrics.values.gear == "N" or electrics.values.gear == "P"))
                            guihooks.message(str, 5, "debug", "debug")
            end
            if(gearbox.parent.type ~= "centrifugalClutch") then
        if (gearbox.parent.type == "frictionClutch") then -- Search for first manual gearbox, it usually has frictionClutch attached between itself and the engine
            -- if the clutch is held down, allow enabling the starter, otherwise disallow it

            if (firstEngine.starterEngagedCoef > 0 and (electrics.values.clutch <= triggerpoint)) then
                firstEngine:deactivateStarter()
            end
        else
            local allowStarterAutomatic = (electrics.values.gear == "N" or electrics.values.gear == "P")
            if (firstEngine.starterEngagedCoef > 0 and not allowStarterAutomatic) then
                firstEngine:deactivateStarter()
            end
        end
         else
            guihooks.message("There's no need of neutral safety switch with centrifugal clutch, since it's not fully engaged when engine is idle.", 5, "info", "info")
            M.updateGFX = nop
           return
        end
    end
end
end

M.onInit = onInit
M.onReset = onInit
M.updateGFX = onUpdate

return M

AddStateBagChangeHandler("deformation", nil, function(bagName, _, value, _, replicated)
    if (replicated) then return end -- Disable double triggers from the initial setter

    local netId = bagName:gsub("entity:", "")
    netId = tonumber(netId)
    if (not netId) then return end

    local veh = NetToVeh(netId)
    if (not veh or veh == 0) then return end

    local newDeformation = value
    ApplyDeformation(veh, newDeformation)
end)
if (not Config.Settings.debug) then return end

CreateThread(function()
    local sphereSize = 0.2
    while (true) do
        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsIn(playerPed, false)
        local offsets = GetModelOffsets(GetEntityModel(veh))

        if (offsets ~= nil and veh ~= nil) then
            local deformation = GetDeformation(veh)
            if (deformation and #deformation > 0) then
                for i = 1, #deformation do
                    local pos = deformation[i]
                    local worldPos = GetOffsetFromEntityInWorldCoords(veh, pos[1], pos[2], pos[3])

                    local maxDamageForColor = 0.3
                    local damage = deformation[i][4]
                    local red = math.floor(255 * damage / maxDamageForColor)
                    local green = math.floor(255 * (1 - damage / maxDamageForColor))

                    DrawMarker(28, worldPos.x, worldPos.y, worldPos.z, 0, 0, 0, 0, 0, 0, sphereSize, sphereSize, sphereSize, red, green, 0, 200, false, false, 2, nil, nil, false)

                    local formatted = deformation[i][1] .. ", " .. deformation[i][2] .. ", " .. deformation[i][3] .. "\n" .. deformation[i][4]
                    Draw3DText(worldPos + vec3(0, 0, 0.05), tostring(formatted), 0.3, {r = 255, g = 255, b = 255, a = 255})
                end
            end
        end

        Wait(5)
    end
end)

RegisterCommand("get_def", function()
    local firstVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    local deformation = GetDeformation(firstVeh)

    local pos = GetOffsetFromEntityInWorldCoords(firstVeh, 6.0, 0, 0)
    local currModel = GetEntityModel(firstVeh)
    RequestModel(currModel)
    while not HasModelLoaded(currModel) do Wait(1) end

    local newVeh = CreateVehicle(currModel, pos.x, pos.y, pos.z, GetEntityHeading(firstVeh), true, false)
    SetVehicleOnGroundProperly(newVeh)
    SetPedIntoVehicle(PlayerPedId(), newVeh, -1)

    SetDeformation(newVeh, deformation)
end, false)

RegisterCommand("reset_def", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetVehicleDeformationFixed(veh)
    print("Reset deformation")
end, false)

RegisterCommand("force", function(source, args)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local force = tonumber(args[1]) or 100.0

    local entity = veh
    local forceTypes = {
        MinForce = 0,
        MaxForceRot = 1,
        MinForce2 = 2,
        MaxForceRot2 = 3,
        ForceNoRot = 4,
        ForceRotPlusForce = 5
    }
    local forceType = forceTypes.MaxForceRot2
    -- sends the entity straight up into the sky:
    local direction = vector3(0.0, force, 0.0)
    local rotation = vector3(0.0, 0.0, 0.0)
    local boneIndex = 0
    local isDirectionRel = true
    local ignoreUpVec = true
    local isForceRel = true
    local p12 = false
    local p13 = true

    ApplyForceToEntity(
        entity,
        forceType,
        direction,
        rotation,
        boneIndex,
        isDirectionRel,
        ignoreUpVec,
        isForceRel,
        p12,
        p13
    )
end, false)

function Draw3DText(coords, text, scale, rgba)
    local _, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)

    rgba = rgba or {}

    SetTextScale(scale or 0.3, scale or 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(rgba.r or 255, rgba.g or 255, rgba.b or 255, rgba.a or 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(x, y)
end
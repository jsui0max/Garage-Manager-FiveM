Citizen.CreateThread(function()
    local inZone = false 
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            local plate = GetVehicleNumberPlateText(veh)
            local x, y, z = table.unpack(GetEntityCoords(veh))
            local distance = #(vector3(x, y, z) - vector3(539.868164, -179.485718, 54.47033))

            if distance <= 10 then
                if not inZone then
                    inZone = true
                    TriggerServerEvent('checkVehicleZone', plate, x, y, z)
                end
            else
                if inZone then
                    inZone = false
                    -- print("Sortie de la zone") 
                end
            end
        end
    end
end)
RegisterNetEvent('notifyMecano')
AddEventHandler('notifyMecano', function(plate, nom_joueur)
    lib.notify({
        title = 'Garage',
        description = 'Le rendez vous avec la plaque ' .. plate .. ' de Mr ' .. nom_joueur .. ' viens d arriver au garage !',
        type = 'inform', 
        duration = 10000,
        position = 'top',
    })
end)



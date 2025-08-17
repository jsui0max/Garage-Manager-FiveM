ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterUsableItem('diag', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getInventoryItem('diag').count > 0 then
        TriggerClientEvent('useDiag', source)
    else
        xPlayer.showNotification('Vous n\'avez pas l\'item diag.')
    end
end)
local currentPannes = {} 

RegisterNetEvent('diag:launch', function()
    local src = source
    if currentPannes[src] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Diagnostique déjà effectué',
            description = 'Panne détectée : ' .. (currentPannes[src] and currentPannes[src].label or 'Inconnue'),
            type = 'info',
        position = 'top'
        })
        return
    end

    local pannes_possible = {
        { label = "Vanne EGR", item = "vanne_egr"},
        { label = "Batterie", item = "batterie_voiture"},
        { label = "Alternateur", item = "alternateur"},
        { label = "Bougies", item = "bougies"},
        { label = "Débitmètre", item = "debimetre"},
        { label = "Injecteurs", item = "injecteurs"},
    }

    local panne = pannes_possible[math.random(#pannes_possible)]
    currentPannes[src] = panne

    TriggerClientEvent('diag:showResult', src, panne.label)
end)

RegisterNetEvent('diag:repairSuccess', function()
    local src = source
    local panne = currentPannes[src]

    if not panne then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Erreur',
            description = 'Aucune panne détectée.',
            type = 'error',
            position = 'top'
        })
        return
    end

    if exports.ox_inventory:Search(src, 'count', panne.item) > 0 then
        exports.ox_inventory:RemoveItem(src, panne.item, 1)
        currentPannes[src] = nil 

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Réparation terminée',
            description = panne.label .. ' a été réparée avec succès.',
            type = 'success',
            position = 'top'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Pièce manquante',
            description = 'Vous avez besoin de : ' .. panne.label,
            type = 'error',
            position = 'top'
        })
    end
end)
ESX.RegisterUsableItem('vanne_egr', function(source)
    handleItemUse(source, 'vanne_egr')

    -- TriggerClientEvent('diag:repairSuccess', source)
end)

ESX.RegisterUsableItem('batterie_voiture', function(source)
    handleItemUse(source, 'batterie_voiture')
    -- TriggerClientEvent('startRepairAnimation', source)

    -- TriggerClientEvent('diag:repairSuccess', source)
end)

ESX.RegisterUsableItem('alternateur', function(source)
    handleItemUse(source, 'alternateur')
    -- TriggerClientEvent('startRepairAnimation', source)

    -- TriggerClientEvent('diag:repairSuccess', source)
end)

ESX.RegisterUsableItem('bougies', function(source)
    handleItemUse(source, 'bougies')
    -- TriggerClientEvent('startRepairAnimation', source)

    -- TriggerClientEvent('diag:repairSuccess', source)
end)

ESX.RegisterUsableItem('debimetre', function(source)
    handleItemUse(source, 'debimetre')
    -- TriggerClientEvent('startRepairAnimation', source)

    -- TriggerClientEvent('diag:repairSuccess', source)
end)

ESX.RegisterUsableItem('injecteurs', function(source)
    handleItemUse(source, 'injecteurs')
    -- TriggerClientEvent('startRepairAnimation', source)

    -- TriggerClientEvent('diag:repairSuccess', source)
end)
local vehicles = {}

RegisterNetEvent('resetVehicleState')
AddEventHandler('resetVehicleState', function(vehiclePlate)
    local src = source

    local normalizedVehiclePlate = string.gsub(vehiclePlate, "%s+", "")

    if not vehicles[normalizedVehiclePlate] then
        vehicles[normalizedVehiclePlate] = {
            distanceTraveled = 0,
            isEngineLightOn = false,
            distanceAfterLight = 0,
            engineOff = false,
            engineFailureTriggered = false
        }
    end

    vehicles[normalizedVehiclePlate].distanceTraveled = 0
    vehicles[normalizedVehiclePlate].isEngineLightOn = false
    vehicles[normalizedVehiclePlate].distanceAfterLight = 0
    vehicles[normalizedVehiclePlate].engineOff = false
    vehicles[normalizedVehiclePlate].engineFailureTriggered = false
    TriggerClientEvent('repairVehicle', src, normalizedVehiclePlate)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Réparation réussie',
        description = 'Le véhicule a été réparé.',
        type = 'success',
        position = 'top'
    })
end)

function handleItemUse(source, itemName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local panne = currentPannes[src]
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(src), true)
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)

    
    if not panne then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Aucune panne détectée',
            description = 'Ce véhicule semble en bon état.',
            type = 'info',
            position = 'top'
        })
        return 
    end

    if panne.item == itemName then
        xPlayer.removeInventoryItem(itemName, 1) 
        currentPannes[src] = nil 
        
    TriggerClientEvent('startRepairAnimation', src)
    -- TriggerEvent('resetVehicleState1', src)
    TriggerClientEvent('resetVehicleState0', src, vehiclePlate)


        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Réparation réussie',
            description = panne.label .. ' a été réparée avec succès.',
            type = 'success',
            position = 'top'
        })

    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Pièce incorrecte',
            description = 'Cet item ne correspond pas à la panne détectée.',
            type = 'error',
            position = 'top'
        })
        return 
    end
end


RegisterNetEvent('diag:reparer', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local panne = currentPannes[src]

    if not panne then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Erreur',
            description = 'Aucune panne enregistrée.',
            type = 'error',
        position = 'top'
        })
        return
    end

    if exports.ox_inventory:Search(src, 'count', panne.item) > 0 then
        exports.ox_inventory:RemoveItem(src, panne.item, 1)

        currentPannes[src] = nil

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Réparation',
            description = (panne and panne.label or 'Inconnue') .. ' a été réparée !',
            type = 'success',
        position = 'top'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Pièce manquante',
            description = 'Vous avez besoin de : ' .. (panne and panne.label or 'Inconnue'),
            type = 'error',
        position = 'top'
        })
    end
end)



RegisterServerEvent('server:useDiag')
AddEventHandler('server:useDiag', function(vehiclePlate)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    TriggerClientEvent('openDiagMenu', _source, vehiclePlate)
end)

RegisterServerEvent('server:resetVehicleState')
AddEventHandler('server:resetVehicleState', function(vehiclePlate)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    TriggerClientEvent('resetVehicleState', _source, vehiclePlate)
end)
AddEventHandler('playerChangedVehicle', function(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent('pneus:loadUsure', plate) 
end)

RegisterNetEvent('pneus:loadUsure', function(plate)
    if not plate or plate == '' then
        -- print("Erreur : La plaque est invalide ou nulle lors du chargement.")
        return
    end

    -- print("Chargement de l'usure des pneus pour la plaque : " .. plate)
    local result = MySQL.single('SELECT usure FROM vehicule_usure_pneus WHERE plate = ?', {plate})
    if result then
        -- print("Usure trouvée pour " .. plate .. ": " .. result.usure)
        TriggerClientEvent('pneus:setUsure', source, result.usure)
    else
    end
end)



lib.callback.register('pneus:getUsure', function(source, plate)
    if not plate then
        -- print("[ERREUR] La plaque reçue est nil. Impossible de récupérer l'usure.")
        return nil
    end
    plate = string.gsub(plate, "%s+", "") 

    local usure = MySQL.Sync.fetchScalar("SELECT usure FROM vehicule_usure_pneus WHERE plate = @plate", {
        ['@plate'] = plate
    })

    if usure then
        -- print("Usure récupérée pour la plaque " .. plate .. " : " .. usure)
        return tonumber(usure) -- Toujours retourner un nombre
    else
        -- print("Aucune donnée trouvée pour la plaque " .. plate .. ". Création d'une nouvelle entrée avec usure = 100.")

        MySQL.Async.execute("INSERT INTO vehicule_usure_pneus (plate, usure) VALUES (@plate, @usure)", {
            ['@plate'] = plate,
            ['@usure'] = 100 
        })

        return 100 
    end
end)

AddEventHandler('playerEnteredVehicle', function(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)

    TriggerEvent('pneus:loadUsure', plate)
end)

RegisterNetEvent('pneus:saveUsure')
AddEventHandler('pneus:saveUsure', function(plate, usure)
    MySQL.Async.execute("INSERT INTO vehicule_usure_pneus (plate, usure) VALUES (@plate, @usure) ON DUPLICATE KEY UPDATE usure = @usure", {
        ['@plate'] = plate,
        ['@usure'] = usure
    })
    -- print("Usure sauvegardée pour " .. plate .. " : " .. usure)
end)

RegisterServerEvent('pneus:updateUsure')
AddEventHandler('pneus:updateUsure', function(plate, speed, rot, surface)
    local usure = MySQL.Sync.fetchScalar("SELECT usure FROM vehicule_usure_pneus WHERE plate = @plate", {
        ['@plate'] = plate
    })

    if usure then
        if speed > 80 then
            usure = usure - math.random(0, 1)
        elseif speed > 50 then
            usure = usure - 0.5
        end

        if math.abs(rot.z) > 10.0 then
            usure = usure - 4
        end

        if surface ~= 4 then
            usure = usure - 0.5
        end

        usure = math.max(0, math.min(100, usure))

        MySQL.Async.execute("UPDATE vehicule_usure_pneus SET usure = @usure WHERE plate = @plate", {
            ['@plate'] = plate,
            ['@usure'] = usure
        })
        if usure < 30 then
            TriggerClientEvent('lib:notify', source, {
                title = 'Pneus usés',
                description = "Vos pneus sont fortement usés, attention à l'adhérence !",
                type = 'error'
            })
        end
    end
end)
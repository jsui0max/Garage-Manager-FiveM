local mecanoCooldowns = {}
local cooldownTime = 5 * 60 



RegisterServerEvent('rendezvous_server')
AddEventHandler('rendezvous_server', function(shop, model, price, name, motif, date_rdv)
    local src = source
    local identifier = GetPlayerIdentifier(src)

    if not date_rdv or date_rdv == "" then
        date_rdv = os.date("%Y-%m-%d %H:%M:%S")  
    end

    MySQL.Async.execute("INSERT INTO rendezvous_mecano (identifier, nom_joueur, garage, vehicule, plaque, numero_tel, motif, date_rdv, numero_or) VALUES (@identifier, @nom_joueur, @garage, @vehicule, @plaque, @numero_tel, @motif, @date_rdv, @numero_or)", {
        ['@identifier'] = identifier,
        ['@nom_joueur'] = GetPlayerName(src),
        ['@garage'] = shop,
        ['@vehicule'] = model,
        ['@plaque'] = price,
        ['@numero_tel'] = name,
        ['@motif'] = motif,
        ['@date_rdv'] = date_rdv,
        ['@numero_or'] = "OR-" .. math.random(100000, 999999)
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('lib.notify', src, {
                title = 'Succès',
                description = 'Votre rendez-vous a été pris avec succès !',
                type = 'success'
            })

            local webhookUrl = Config.WebhookRDV

            local message = {
                username = "📅 RDV Mécano",
                embeds = {{
                    title = "📋 Nouvelle demande de Rendez-vous",
                    color = 65353,
                    fields = {
                        { name = "👤 Joueur", value = GetPlayerName(src), inline = true },
                        { name = "🚗 Véhicule", value = model, inline = true },
                        { name = "📄 Motif", value = motif, inline = false },
                        { name = "🕒 Date & Heure", value = date_rdv, inline = true },
                        { name = "📞 Téléphone", value = name, inline = true },
                        { name = "🔢 Immatriculation", value = price, inline = true },
                    },
                    footer = { text = os.date("🗓️ %d/%m/%Y à %H:%M:%S") }
                }}
            }

            PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(message), {
                ['Content-Type'] = 'application/json'
            })
        else
            TriggerClientEvent('lib.notify', src, {
                title = 'Erreur',
                description = 'Un problème est survenu lors de la prise de rendez-vous.',
                type = 'error'
            })
        end
    end)
end)



RegisterServerEvent("rdv:demanderListe")
AddEventHandler("rdv:demanderListe", function()
    local src = source
    MySQL.Async.fetchAll("SELECT nom_joueur, garage, vehicule, plaque, numero_tel, motif, date_rdv, numero_or FROM rendezvous_mecano", {}, function(resultats)
        TriggerClientEvent("rdv:afficherListe", src, resultats)
    end)
end)
RegisterServerEvent('supprimer_rdv_or')
AddEventHandler('supprimer_rdv_or', function(numero_or)
    local src = source
    local player = ESX.GetPlayerFromId(src)

    if player and player.job.name == "mechanic" and (player.job.grade_name == "chef" or player.job.grade_name == "boss") then
        MySQL.Async.execute("DELETE FROM rendezvous_mecano WHERE numero_or = @numero_or", {
            ['@numero_or'] = numero_or
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('lib.notify', src, {
                    title = 'Succès',
                    description = 'Le RDV a été supprimé avec succès.',
                    type = 'success'
                })
            else
                TriggerClientEvent('lib.notify', src, {
                    title = 'Erreur',
                    description = 'Aucun RDV trouvé avec ce numéro OR.',
                    type = 'error'
                })
            end
        end)
    else
        TriggerClientEvent('lib.notify', src, {
            title = 'Accès refusé',
            description = 'Vous n\'êtes pas autorisé à supprimer des RDV.',
            type = 'error'
        })
    end
end)
RegisterNetEvent('mecano:alerte')
AddEventHandler('mecano:alerte', function()
    local sourcePlayer = source

    if mecanoCooldowns[sourcePlayer] and mecanoCooldowns[sourcePlayer] > os.time() then
        local remaining = mecanoCooldowns[sourcePlayer] - os.time()
        TriggerClientEvent('ox_lib:notify', sourcePlayer, {
            title = 'Cooldown',
            description = 'Tu dois attendre encore ' .. math.ceil(remaining / 60) .. ' minute(s) avant de rappeler.',
            type = 'error'
        })
        return 
    end

    mecanoCooldowns[sourcePlayer] = os.time() + cooldownTime

    local xPlayer = ESX.GetPlayerFromId(sourcePlayer)
    local name = xPlayer.getName()

    for _, xP in pairs(ESX.GetExtendedPlayers()) do
        if xP.getJob().name == 'mechanic' then
            TriggerClientEvent('ox_lib:notify', xP.source, {
                title = 'Appel client',
                description = 'Quelqu\'un a besoin d\'un mécano !',
                type = 'info',
                duration = 10000,
                position = 'top'
            })
        end
    end

    local webhook = Config.WebhookAlerte
    local message = {
        username = "Garage",
        embeds = {{
            title = "🚨 Alerte Mécano",
            description = "**Un client a demandé un mécano.**",
            color = 16753920,
            fields = {
                { name = "Joueur", value = name, inline = true },
                { name = "ID", value = tostring(sourcePlayer), inline = true },
            },
            footer = { text = "Service Mécanique - Logs" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    PerformHttpRequest(webhook, function() end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('checkVehicleZone')
AddEventHandler('checkVehicleZone', function(plate, x, y, z)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer and xPlayer.job.name == 'mechanic' then
        plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")

        local zoneX, zoneY, zoneZ, rayon = 539.868164, -179.485718, 54.47033, 10
        local distance = math.sqrt((x - zoneX)^2 + (y - zoneY)^2 + (z - zoneZ)^2)

        if distance <= rayon then
            MySQL.Async.fetchAll('SELECT * FROM rendezvous_mecano WHERE UPPER(plaque) = UPPER(@plate)', {
                ['@plate'] = plate
            }, function(result)
                if result and #result > 0 then
                    local nom_joueur = result[1].nom_joueur 
                    -- print('OKK')
                    TriggerClientEvent('notifyMecano', _source, plate, nom_joueur) 
                else
                end
            end)
        else
        end
    else
    end
end)

lib.callback.register('nettoyage:supprimer', function(source, item, metadata, target)
    
	local Player = source
    exports.ox_inventory:RemoveItem(Player, 'kit_nettoyage', 1)
    exports.ox_inventory:RemoveItem(Player, 'eponge', 1) 
    

end)

lib.callback.register('nettoyage:epongesale', function(source, item, metadata, target)

	local Player = source 
    exports.ox_inventory:AddItem(Player, 'eponge_sale', 1)

end)

lib.callback.register('nettoyage:ajouteponge', function(source, item, metadata, target)

	local Player = source 
    exports.ox_inventory:RemoveItem(Player, 'eponge_sale', 1) 
    exports.ox_inventory:AddItem(Player, 'eponge', 1)

end)

lib.callback.register('deverouillage:voiture', function(source, item, metadata, target)

	local Player = source 
    exports.ox_inventory:RemoveItem(Player, 'kit_deverouillage', 1)  

end) 

RegisterServerEvent('garage:demarrerChangementPneus')
AddEventHandler('garage:demarrerChangementPneus', function(netVeh)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netVeh)

    FreezeEntityPosition(veh, true)

    TriggerClientEvent('garage:creverPneusProgressivement', -1, netVeh)

end)

local pneusPoses = {}
RegisterServerEvent('garage:poserPneu')
AddEventHandler('garage:poserPneu', function(netVeh, plate)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if not veh then return end
    if not plate or plate == "" then
        -- print("[Erreur] Plaque invalide lors de l'appel à garage:poserPneu")
        return
    end
    -- print("[Info] Plaque transmise :", plate)

    if not pneusPoses[src] then pneusPoses[src] = 0 end

    pneusPoses[src] += 1
    TriggerClientEvent('garage:installerPneuAnim', src, pneusPoses[src], netVeh)

    -- for i = 0, 3 do
    --     if IsVehicleTyreBurst(veh, i, false) then
    --         SetVehicleTyreFixed(veh, i)
    --         break
    --     end
    -- end

    Wait(5000)
    if pneusPoses[src] == 4 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Équilibrage des roues...",
            type = "inform",
            position = 'top'
        })

        Wait(5000)
        TriggerClientEvent('garage:remettreVehicule', -1, netVeh)

        TriggerEvent('J0M_pneua100:remettrePneusA100', plate)

        pneusPoses[src] = nil
    end
end)

RegisterServerEvent('J0M_pneua100:remettrePneusA100')
AddEventHandler('J0M_pneua100:remettrePneusA100', function(plate)
    if not plate or plate == "" then
        return
    end

    plate = string.gsub(plate, "%s+", "") 

    MySQL.update('UPDATE vehicule_usure_pneus SET usure = 100 WHERE plate = ?', {plate})
end)

Citizen.CreateThread(function()
    if GetCurrentResourceName() ~= 'J0M_mecano' then
        while true do 
            print("[^4J0M_mecano^7] Merci de ne renommer la ressource, et de la laisser nommé 'J0M_mecano' !")
            Wait(5000)
        end
    else
        print("--------------------[^4J0M_mecano^7]--------------------")
        print("----------------- ^4Jsui0Max^7 ------------------")
    end
end)


-- CreateThread(function()
--     while true do
--         Wait(5000) -- 5 secondes

--         MySQL.Async.fetchAll('SELECT * FROM vehicule_usure_pneus', {}, function(result)
--             if result then
--                 for k, v in pairs(result) do
--                     print(('Plaque : %s | Usure pneus : %.1f%%'):format(v.plate, v.usure))
--                 end
--             end
--         end)
--     end
-- end)



RegisterNetEvent('pneus:verifierUsure')
AddEventHandler('pneus:verifierUsure', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 then
        local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))

        lib.callback('pneus:getUsure', false, function(usure)
            if usure then
                ESX.ShowNotification('État des pneus : ' .. usure .. ' %')
            else
                ESX.ShowNotification('Erreur : Impossible de récupérer l\'usure des pneus.')
            end
        end, plate)
    else
        ESX.ShowNotification('Erreur : Vous n\'êtes pas dans un véhicule.')
    end
end)




RegisterServerEvent('garage:preparerChangementPneus')
AddEventHandler('garage:preparerChangementPneus', function(netVeh, plate)
    -- print('mise a jour 1')
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    local src = source
    FreezeEntityPosition(veh, true)
    TriggerClientEvent('garage:creverPneus', src, netVeh)
    TriggerEvent('garage:updateUsure', plate, 100)
    -- print('Mis a jour 2')
end)

RegisterServerEvent('garage:poserPneu')
AddEventHandler('garage:poserPneu', function(netVeh)
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if not veh then return end

    -- for i = 0, 3 do
    --     if IsVehicleTyreBurst(veh, i, false) then
    --         SetVehicleTyreFixed(veh, i)
    --         break
    --     end
    -- end

    -- local tousOk = true
    -- for i = 0, 3 do
    --     if IsVehicleTyreBurst(veh, i, false) then
    --         tousOk = false
    --         break
    --     end
    -- end

    -- if tousOk then
        local src = source
        TriggerClientEvent('garage:equilibrage', src, netVeh)
    -- end
end)

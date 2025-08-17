

local lastUpdateTime = 0
local updateInterval = 20000 
local usureRate = 0.01 
local lastNotify = 0
local lastSaved = 100
local ox_inventory = exports.ox_inventory
local vehicles = {}
local currentVehicle = nil
local initialDistance = 0
local plaqueVeh = nil

RegisterNetEvent('pneus:voirEtat')
AddEventHandler('pneus:voirEtat', function()
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

RegisterNetEvent('pneus:mettreAJour')
AddEventHandler('pneus:mettreAJour', function(plate, usure)

    local veh = GetVehiclePedIsIn(cache.ped, false)
    local currentPlate = GetVehicleNumberPlateText(veh)
    if ESX.Math.Trim(currentPlate) == plate then
        lib.callback('pneus:getUsure', false, function(serverUsure)
            if serverUsure then
                ESX.ShowNotification('Usure des pneus mise à jour : ' .. serverUsure .. ' %')
            else
                ESX.ShowNotification('Erreur : Impossible de récupérer l\'usure des pneus.')
            end
        end, plate)
    end
end)



Citizen.CreateThread(function()
    while true do
        local Sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(Config.PositionAccueil, playerCoords, false)

        if distance < 2 then
            Sleep = 0
            lib.showTextUI('[E] - Accueil du Garage', {
                position = "right-center",
                icon = 'calendar-days',
                style = {
                    borderRadius = 7,
                    color = 'white'
                }
            })

            if IsControlJustPressed(0, 51) then
                RendezvousMecano()
            end
        else 
            lib.hideTextUI()
        end
        Wait(Sleep)
    end
end)
function RendezvousMecano()
    local options = {}
    table.insert(options, {
        title = "Prendre RDV",
        description = " \n Votre demande sera validée par un chef mécanicien ",
        icon = 'calendar-days',
        iconeColor = 'brown',
        onSelect = function ()
            local default_shop = Config.NomDuGarage
            local result = lib.inputDialog("Vos informations véhicule", {
                { type = "input", name="shop", label = "Garage", placeholder = "Entrez le nom de votre concession", default = default_shop, disabled = true},
                { type = "input", name="model", label = "Votre véhicule", placeholder = "Entrez le modèle du véhicule"},
                { type = "input", name="price", label = "Immatriculation", description = 'Il est très important de respecter le Format de la plaque d\'immatriculation', placeholder = "Immat (MAJUSCULE & ESPACE)"},
                { type = "input", name="name", label = "Numéro", description = 'Entrez votre numéro de téléphone', placeholder = "Sans numéro = pas de RDV"},
                { type = 'input', name="motif", label = 'Motif du RDV', placeholder = "Pourquoi souhaitez-vous un RDV ?"},
                { type = 'input', label = 'Date souhaitée (confirmation après validation)', icon = {'far', 'calendar'}, placeholder = "JJ/MM/AAAA"},
                { type = 'input', name = 'hour', label = 'Heure souhaitée (format 24h)', placeholder = 'HH:MM'},
                { type = 'checkbox', label = 'Vérifiez que tous les champs sont remplis correctement' },
            })

            if result and result[1] and result[2] and result[3] and result[4] and result[5] and result[6] and result[7] then
                local date_rdv = result[6]
                local hour_rdv = result[7]
                local day, month, year = date_rdv:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
                local hour, minute = hour_rdv:match("^(%d%d):(%d%d)$")

                if day and month and year and hour and minute then
                    date_rdv = string.format("%d-%02d-%02d %02d:%02d:00", year, month, day, hour, minute)
                    TriggerServerEvent('rendezvous_server', result[1], result[2], result[3], result[4], result[5], date_rdv)
                else
                    lib.notify({ title = 'Erreur', description = 'La date ou l\'heure saisie est invalide. Veuillez respecter le format DD/MM/YYYY pour la date et HH:MM pour l\'heure.', type = 'error' })
                end
            else
                lib.notify({ title = 'Erreur', description = 'Merci de remplir tous les champs !', type = 'error' ,position = 'top'})
            end
        end
})

table.insert(options, {
    title = 'Appeler un mécano',
    description = " \n Un mécanicien sera notifié ",
    icon = 'calendar-days',
    onSelect = function()
        TriggerServerEvent('mecano:alerte', function(success)
            if success then
                lib.notify({
                    title = 'Appel envoyé',
                    description = 'Un mécanicien a été notifié !',
                    type = 'inform',
                    position = 'top'
                })
            else
                -- lib.notify({
                --     title = 'Erreur',
                --     description = 'Vous devez attendre avant de rappeler un mécano.',
                --     type = 'error'
                -- })
            end
        end)
    end
})



    lib.registerContext({
        id = "menu_rdv",
        title = 'Accueil',
        options = options
    })
    lib.showContext("menu_rdv")
end


exports.ox_target:addBoxZone ({
    coords = Config.GestionRDV,
    size = vec3(1, 1, 1),
    rotation = 45,
    debug = drawZones,
    options = {
        name = 'box',
        event = 'Menu_Mecano_Job',
        label = 'Menu de gestion des rdv',
        -- icon = "fa-solid fa-shirt",
    }
})
RegisterNetEvent('Menu_Mecano_Job')
AddEventHandler('Menu_Mecano_Job', function()
    -- local source = source

    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mechanic' then
        lib.showContext('Menu_Mecano_Job')
        -- print ('OK')
    else 
        ESX.ShowNotification('Vous ne travaillez ici!')
    end  
end)

lib.registerContext({
    
    id = 'Menu_Mecano_Job',
    title = ' Gestion du Garage',
    options = {
        {
            title = 'Supprimer un RDV',
            description = 'Supprimer un RDV passé ou annulé.',
            metadata = {
                {label = 'Grade', value = 'Chef'},
            },
            onSelect = function()
                local input = lib.inputDialog("Suppression d'un RDV", {
                    { type = 'input', label = 'Numéro OR à supprimer', placeholder = 'Ex: OR-123456' }
                })

                if input and input[1] ~= '' then
                    TriggerServerEvent('supprimer_rdv_or', input[1])
                else
                    lib.notify({
                        title = 'Erreur',
                        description = 'Veuillez entrer un numéro OR valide.',
                        type = 'error'
                    })
                end
            end,
        },
        {
            title = 'Menu du boss',
            onSelect = function()
                    local input = lib.inputDialog('Mot de passe requis', {'Entrez le mot de passe'})
                    local player = ESX.GetPlayerData()
                    local mdp = '123456'
                    if player.job.grade_name == 'boss' then
                    
                    if input and input[1] == mdp then 
                        TriggerEvent('esx_society:openBossMenu', 'mechanic', function(data, menu)
                        end)
                    else
                        lib.notify({
                            title = 'Accès refusé',
                            description = 'Mot de passe incorrect',
                            type = 'error',
                            position = 'top',
                        })
                    end
                else
                    lib.notify({
                        title = 'Accès refusé',
                        description = 'Vous n\'êtes pas le boss de cette société',
                        type = 'error',
                        position = 'top',
                    })
                end
            end
        }
        
        
    }
})




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if GetPedInVehicleSeat(vehicle, -1) == playerPed then 
                local speed = GetEntitySpeed(vehicle) * 3.6 
                if speed > 10 then 
                    local currentTime = GetGameTimer()
                    if currentTime - lastUpdateTime > updateInterval then
                        lastUpdateTime = currentTime

                        local plate = GetVehicleNumberPlateText(vehicle)
                        plate = string.gsub(plate, "%s+", "") 
                        
                        lib.callback('pneus:getUsure', false, function(usure)
                            if usure then
                                local newUsure = usure - usureRate
                                if newUsure < 0 then newUsure = 0 end
                                
                                TriggerServerEvent('pneus:saveUsure', plate, newUsure)
                            end
                        end, plate)
                    end
                end
            end
        end
    end
end)


CreateThread(function()
    while true do
        Wait(5000)

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
            local speed = GetEntitySpeed(veh)
            local plaque = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
            
            if speed > 1 then
                if plaqueVeh ~= plaque then
                    plaqueVeh = plaque

                    lib.callback('pneus:getUsure', false, function(usure)
                        usure = tonumber(usure) 
                    
                        if usure then
                            -- lib.notify({
                            --     title = 'État de vos pneus : ' .. usure .. '%',
                            --     type = 'inform',
                            --     position = 'top',
                            --     duration = 5000
                            -- })
                    
                            if usure <= 0 then
                                SetVehicleReduceGrip(veh, true)
                            end
                        else
                            lib.notify({
                                title = 'Erreur',
                                description = "Impossible de récupérer l'usure des pneus.",
                                type = 'error',
                                position = 'top'
                            })
                        end
                    end, plaqueVeh)
                end

                TriggerServerEvent('pneus:updateUsure', plaqueVeh, speed, GetEntityRotation(veh, 2), GetVehicleWheelSurfaceMaterial(veh, 0))
            end
        else
            plaqueVeh = nil
            Wait(1000)
        end
    end
end)




Citizen.CreateThread(function()
    while true do
        local Sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(Config.VoirRDV, playerCoords, false)

        if distance < 2 then
            local playerData = ESX.GetPlayerData()
            local isMechanic = playerData and playerData.job and playerData.job.name == 'mechanic' 

            if isMechanic then
                Sleep = 0
                lib.showTextUI('[E] - Voir les Rendez vous', {
                    position = "right-center",
                    icon = 'calendar-days',
                    style = {
                        borderRadius = 7,
                        color = 'white'
                    }
                })

                if IsControlJustPressed(0, 51) then
                    VoirLesRendezvousMecano()
                end
            else
                lib.hideTextUI()
            end
        else 
            lib.hideTextUI()
        end
        Wait(Sleep)
    end
end)
local nbPneusInstalles = 0
local HasPneuInInventory = false
local vehEnCours = nil

exports.ox_target:addBoxZone({
    coords = Config.PrendrePneus,
    size = vec3(1, 1, 1),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'prendre_pneu',
            icon = 'fa-solid fa-circle',
            label = 'Prendre un pneu',
            canInteract = function()
                local playerData = ESX.GetPlayerData() 
                local isMechanic = playerData and playerData.job and playerData.job.name == 'mechanic' 

                return isMechanic and not IsPedInAnyVehicle(PlayerPedId(), false) and nbPneusInstalles < 4 and not HasPneuInInventory
            end,
            onSelect = function()
                HasPneuInInventory = true
                lib.notify({ title = "Garage", description = "Tu as pris un pneu", type = "inform" , position = 'top'})
                AttacherPneuProp()
            end,
        }
    }
})
local propPneu = nil

function AttacherPneuProp()
    local playerPed = PlayerPedId()
    local model = `prop_wheel_01` 
    local playerCoords = GetEntityCoords(playerPed)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

     propPneu = CreateObject(GetHashKey(Parametres.PositionRoue.ModeldeProps), playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)

    local EndroitBras = Parametres.PositionRoue.ModeldeRoue.bras
    local offsetCoords = Parametres.PositionRoue.ModeldeRoue.loc
    local offsetRot = Parametres.PositionRoue.ModeldeRoue.rot
    local BrasduPed = GetPedBoneIndex(playerPed, EndroitBras)
    AttachEntityToEntity(propPneu, playerPed, BrasduPed, offsetCoords.x, offsetCoords.y, offsetCoords.z, offsetRot.x, offsetRot.y, offsetRot.z, true, false, false, false, 2, true)

    PlayAnimFree('anim@heists@box_carry@', 'idle')

    return propPneu
end

function PlayAnimFree(dict, anim)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 5.0, 1.0, 5000.0, 49, 0.0, false, false, false)
    RemoveAnimDict(dict)
end


CreateThread(function()
    while true do
        Wait(2000)
        if vehEnCours ~= nil then
            exports.ox_target:addLocalEntity(vehEnCours, {
                {
                    name = 'poser_pneu',
                    icon = 'fa-solid fa-wrench',
                    label = 'Poser le pneu',
                    distance = 2.0,
                    onSelect = function()
                        if not HasPneuInInventory then
                            lib.notify({ title = "Garage", description = "Tu n’as pas de pneu !", type = "error" , position = 'top'})
                            return
                        end

                        HasPneuInInventory = false
                        nbPneusInstalles += 1
                        local plate = GetVehicleNumberPlateText(vehEnCours)
                            plate = string.gsub(plate, "%s+", "") 
                            if not plate or plate == "" then
                                print("[Erreur] Impossible de récupérer la plaque du véhicule.")
                                return
                            end
                            TriggerServerEvent('garage:poserPneu', VehToNet(vehEnCours), plate)
                            -- print("[Info] Plaque :", plate)

                        if propPneu and DoesEntityExist(propPneu) then
                            Citizen.Wait(500)
                            DeleteEntity(propPneu)
                            propPneu = nil
                        end

                        if nbPneusInstalles >= 4 then
                            exports.ox_target:removeLocalEntity(vehEnCours, 'poser_pneu')
                            vehEnCours = nil
                        end
                    end,
                    canInteract = function()
                        TriggerServerEvent('J0M_pneua100:remettrePneusA100')
                        return HasPneuInInventory and nbPneusInstalles < 4
                    end
                }
            })
            break
        end
    end
end)

RegisterNetEvent('garage:creverPneusProgressivement', function(netVeh)
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if DoesEntityExist(veh) then
        local ped = PlayerPedId()
        for i = 0, 3 do
            -- SetVehicleTyreBurst(veh, i, true, 1000.0)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_HAMMERING', 0, true)
            Wait(3000)
            ClearPedTasks(ped)
        end
    end
end)
RegisterNetEvent('garage:installerPneuAnim', function(numero, netVeh)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 0, true)
    Wait(3000)
    ClearPedTasks(ped)

    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if DoesEntityExist(veh) then
        SetVehicleTyreFixed(veh, numero - 1) 
    end
end)
RegisterNetEvent('garage:remettreVehicule', function(netVeh)
    local veh = NetworkGetEntityFromNetworkId(netVeh)
    if DoesEntityExist(veh) then
        FreezeEntityPosition(veh, false)
    end
end)


function VoirLesRendezvousMecano()
    TriggerServerEvent("rdv:demanderListe")
end

RegisterNetEvent("rdv:afficherListe")
AddEventHandler("rdv:afficherListe", function(listeRDV)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openRDV",
        data = listeRDV
    })
end)

RegisterNUICallback("fermerRDV", function(data, cb)
    SetNuiFocus(false, false)
    cb({})
end)

local options = {
    {
        name = 'mechanic',
        event = 'mechanic_menu',
        icon = 'fa-solid fa-wrench',
        label = 'Mécano',
        groups = {["mechanic"] = 0},
        distance = 1,
    } 
  }

exports.ox_target:addGlobalVehicle(options)

RegisterNetEvent('mechanic_menu', function()
  lib.registerContext({
    id = 'mechanic_menulib',
    title = 'Menu du mécano', 
    options = {
      {
        title = 'Réparer',
        description = 'kit de réparation X1', 
        onSelect =  reparerlavoiture,
      },
      {
        title = 'Nettoyez le véhicule',
        description = 'kit de nettoyage X1', 
        onSelect =  nettoyagedelavoiture,
      },
      {
        title = 'Déverrouiller le véhicule',
        description = 'outil de soudure x1', 
        onSelect =  deverouillagedelavoiture,
      }, 
      {
        title = 'Connecter/Placer',
        description = 'Attacher/placer le véhicule', 
        onSelect =  attachervoiture,
      },
      {
        title = 'Changer les pneus',
        icon = 'fas fa-tools',
        description = 'Changer les pneus',
        onSelect = function()
            EnleverlaRoue()
        end
      },
      {
        title = 'Diagnostique',
        description = 'Diagnostiquer le véhicule', 
        onSelect =  function ()
            lib.notify({
                title = 'Vous devez être dans le véhicule et utiliser le Diag', 
                type = 'error',
                position = 'top',
                duration = 5000
            }) 
        end,
      },
      {
        title = 'Voir l\'état des pneus',
        description = 'Afficher l\'usure des pneus du véhicule',
        onSelect = function()
            
            local veh = GetVehiclePedIsIn(cache.ped, true)
            if not veh or veh == 0 then
                lib.notify({ title = "Erreur", description = "Vous n'êtes pas dans un véhicule.", type = "error" })
                return
            end
            
            local plate = GetVehicleNumberPlateText(veh)
            if not plate then
                lib.notify({ title = "Erreur", description = "La plaque du véhicule est introuvable.", type = "error" })
                return
            end
            
            plate = ESX.Math.Trim(plate)
            
            lib.callback('pneus:getUsure', false, function(usure)
                -- print("Usure reçue : " .. tostring(usure))
                if usure then
                    -- ESX.ShowNotification('État des pneus : ' .. usure .. ' %')
                    lib.notify({
                                title = 'État des pneus : ' .. usure .. '%',
                                type = 'inform',
                                position = 'top',
                                duration = 5000
                            })
                    
                else
                    ESX.ShowNotification('Erreur: L\'état des pneus n\'a pas pu être récupéré.')
                end
            end, plate)
            
        end,
      },
    }
  })

  lib.showContext('mechanic_menulib')
 
end)
function EnleverlaRoue()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71) 

    if not DoesEntityExist(vehicle) then
        lib.notify({ title = "Garage", description = "Aucun véhicule à proximité", type = "error", position = 'top' })
        return
    end

    nbPneusInstalles = 0
    HasPneuInInventory = false
    vehEnCours = vehicle

    TriggerServerEvent('garage:preparerChangementPneus', VehToNet(vehicle))

    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do Wait(0) end
    TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_player', 8.0, -8.0, 5000, 1, 0, false, false, false)

    Wait(5000)
    ClearPedTasks(playerPed)
    lib.notify({ title = "Garage", description = "Les pneus sont à plat, va chercher les neufs", type = "inform", position = 'top' })
end



function reparerlavoiture()
    lib.notify({
        title = 'Sa arrive patience...', 
        type = 'error',
        position = 'top',
        duration = 5000
    }) 
end

RegisterNetEvent('garage:creverPneus')
AddEventHandler('garage:creverPneus', function(netVeh)
    local veh = NetToVeh(netVeh)
    if not veh then return end

    FreezeEntityPosition(veh, true)

    for i = 0, 3 do
        Wait(1000)
        -- SetVehicleTyreBurst(veh, i, true, 1000.0)
    end
end)

function nettoyagedelavoiture()

    lib.hideContext()
    local playerPed = PlayerPedId()
    local vehicle = ESX.Game.GetVehicleInDirection(playerPed)
    local washtool = ox_inventory:Search('count', 'kit_nettoyage') 
    
    local sponge = ox_inventory:Search('count', 'eponge') 
    if  washtool >= 1  and sponge >= 1 and DoesEntityExist(vehicle)  then 
      FreezeEntityPosition(vehicle, true) 
  
      lib.callback('nettoyage:supprimer', false, function(Player)end)
      if DoesEntityExist(vehicle) then
        if lib.progressBar({
          duration = 5000,
          label = 'Nettoyage',
          useWhileDead = false,
          canCancel = false,
          disable = {
              car = true,
              move = true,
              combat = true,
              mouse = false,
          },
          anim = {
              dict = 'gestures@f@standing@casual',
              clip = 'gesture_point'
          },
          prop = {
              model = `v_serv_bs_spray`,
              bone = 4170,
              pos = vec3(0.00, -0.02, -0.10),
              rot = vec3(1.50, -1.20, -1.00)
          },
      }) then   
         washtwo()
        else   
   
        end
      end 
    else
      lib.notify({
        title = 'Vous avez besoin d’un outil de nettoyage & d\'une éponge', 
        type = 'error',
        position = 'top'
    })   
    end
  
  end
  
  function washtwo()
  
    local playerPed = PlayerPedId()
    local vehicle = ESX.Game.GetVehicleInDirection(playerPed)
        if lib.progressBar({
                duration = 5000,
                label = 'Nettoyage',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    mouse = false,
                },
                anim = {
                    dict = 'timetable@floyd@clean_kitchen@base',
                    clip = 'base'
                },
                prop = {
                    model = `prop_sponge_01`,
                    bone = 28422,
                    pos = vec3(0.0, 0.0, -0.01),
                    rot = vec3(90.0, 0.0, 0.0)
                },
            }) then    
            SetVehicleDirtLevel(vehicle, 0)
            FreezeEntityPosition(vehicle, false)
            lib.callback('nettoyage:epongesale', false, function(Player)end)
        else   
        
    end
  
  end

  
exports.ox_target:addBoxZone({
    coords = Config.Lavabo,
    size = vec3(1, 2, 1),
    rotation = 275.8271,
    distance = 2,
    debug = false,
  
    options = {
        {
            name = 'washsponge',
            event = 'nettoyerepongesale',
            icon = 'fa-solid fa-hands-bubbles',
            label = 'Lavabo', 
            groups = {["mechanic"] = 0},
  
        }
    }
  })
  
  RegisterNetEvent('nettoyerepongesale', function()
  
   
    local nettoyereponge = ox_inventory:Search('count', 'eponge_sale') 
     
    if  nettoyereponge >= 1    then 
  
  
      if lib.progressBar({
        duration = 5000,
        label = 'Laver l\'eponge',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
          dict = 'anim@heists@prison_heistig1_p1_guard_checks_bus',
          clip = 'loop'
        },
        prop = {
            model = `prop_sponge_01`,
            bone = 28422,
            pos = vec3(0.03, 0.05, -0.01),
            rot = vec3(90.0, 0.0, 0.0)
        },
      }) then     
      
      lib.callback('nettoyage:ajouteponge', false, function(Player)end)
  
      else   
      
      end
  
  
  
   
    else
      lib.notify({
        title = 'Vous avez besoin d’une éponge sale', 
        type = 'error',
        position = 'top'
    })  
    end  
  
  end)
  

function deverouillagedelavoiture()
        lib.hideContext()
        
        local playerPed = PlayerPedId()
        local vehicle = ESX.Game.GetVehicleInDirection(playerPed)
        local weldingtorch = ox_inventory:Search('count', 'kit_deverouillage') 
    
        
            if IsPedSittingInAnyVehicle(playerPed) then
            lib.notify({
                title = 'Il y a des joueurs dans le véhicule', 
                type = 'error',
                position ='top'
            })
              return
            end
        
                if  weldingtorch >= 1  and DoesEntityExist(vehicle)  then 
                lib.callback('deverouillage:voiture', false, function(Player)end)
                if DoesEntityExist(vehicle) then
                    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
            
                    if lib.progressBar({
                    duration = 10000,
                    label = 'Déverrouillage',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                        mouse = false,
                    },
                    
                }) then    
                    SetVehicleDoorsLocked(vehicle, 1)
                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    ClearPedTasksImmediately(playerPed)
            
                    else   
                    end
            
                
            
                end 
            else
            lib.notify({
                title = 'Vous avez besoin d\'un kit de deverouillage', 
                type = 'error',
                position ='top'
            })    
        end
  end

  function attachervoiture() 
    lib.hideContext()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, true)
  
    local towmodel = `flatbed`
    local isVehicleTow = IsVehicleModel(vehicle, towmodel)
  
  
    if isVehicleTow then
      local targetVehicle = ESX.Game.GetVehicleInDirection()
  
      if CurrentlyTowedVehicle == nil then
        if targetVehicle ~= 0 then
          if not IsPedInAnyVehicle(playerPed, true) then
            if vehicle ~= targetVehicle then
              AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
              CurrentlyTowedVehicle = targetVehicle 
              lib.notify({
                title = 'Le véhicule est connecté avec succès', 
                type = 'inform',
                position = 'top'
            })
  
         
            else 
              lib.notify({
                title = 'Vous ne pouvez pas attacher votre propre remorque', 
                type = 'error',
                position = 'top'
            })
            end
          end
        else 
          
          lib.notify({
            title = 'Il n’y a pas de véhicules à attacher', 
            type = 'error',
            position = 'top'
        })
        end
      else
        AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
        DetachEntity(CurrentlyTowedVehicle, true, true)
  
      
         
        CurrentlyTowedVehicle = nil 
        
        lib.notify({
          title = 'Le véhicule a été séparé avec succès !', 
          type = 'inform',
          position = 'top'
      })
      end
    else 
      lib.notify({
        title = 'L’action est impossible ! Vous aurez besoin d’un plateau pour charger le véhicule', 
        type = 'inform',
        position = 'top'
    })
    end
  end
  

  

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            currentVehicle = GetVehiclePedIsIn(playerPed, false)
            local vehiclePlate = GetVehicleNumberPlateText(currentVehicle)
            vitesse = Config.Distance_avant_stop
            stop = Config.Stop_Moteur
            
            if not vehicles[vehiclePlate] then
                vehicles[vehiclePlate] = {
                    distanceTraveled = 0,
                    isEngineLightOn = false,
                    randomDistance = vitesse, 
                    distanceAfterLight = 0, 
                    engineOff = false, 
                    engineFailureTriggered = false, 
                    randomFailureDistance = stop
                }
            end
            
            local vehicleData = vehicles[vehiclePlate]
            local currentDistance = GetEntityCoords(currentVehicle)
            
            if initialDistance == 0 then
                initialDistance = currentDistance
            else
                local distanceDelta = #(initialDistance - currentDistance)
                vehicleData.distanceTraveled = vehicleData.distanceTraveled + distanceDelta
                if vehicleData.isEngineLightOn then
                    vehicleData.distanceAfterLight = vehicleData.distanceAfterLight + distanceDelta
                end
                initialDistance = currentDistance
            end
            
            if vehicleData.distanceTraveled >= vehicleData.randomDistance and not vehicleData.isEngineLightOn then
                local vmax = Config.VMax
                -- TriggerEvent('showEngineLight')
                TriggerEvent('limitVehicleSpeed', currentVehicle, vmax)
                TriggerEvent('reduceVehicleAcceleration', currentVehicle, 0.1)
                SetVehicleEngineHealth(currentVehicle, 10.0)
                ESX.ShowNotification('Panne moteur, allez voir le garagiste au plus vite!')
                vehicleData.isEngineLightOn = true
            end
            
            if vehicleData.isEngineLightOn and not vehicleData.engineFailureTriggered and vehicleData.distanceAfterLight >= vehicleData.randomFailureDistance then
                TriggerEvent('engineFailure', currentVehicle)
                ESX.ShowNotification('Le moteur de votre véhicule s\'est éteint après avoir parcouru une longue distance avec le voyant allumé!')
                vehicleData.engineOff = true 
                vehicleData.engineFailureTriggered = true 
            end

            if vehicleData.engineOff then
                SetVehicleEngineOn(currentVehicle, false, true, true)
            end
        else
            if currentVehicle then
                local vehiclePlate = GetVehicleNumberPlateText(currentVehicle)
                local vehicleData = vehicles[vehiclePlate]
                if vehicleData and vehicleData.isEngineLightOn then
                    TriggerEvent('hideEngineLight')
                    TriggerEvent('stopExhaustSparks', currentVehicle)
                end
            end
            
            currentVehicle = nil
            initialDistance = 0
        end
    end
end)


RegisterNetEvent('hideEngineLight')
AddEventHandler('hideEngineLight', function()
    SendNUIMessage({
        action = 'hideEngineLight'
    })
end)

RegisterNetEvent('limitVehicleSpeed')
AddEventHandler('limitVehicleSpeed', function(vehicle, speed)
    SetVehicleMaxSpeed(vehicle, speed / 3.6)
end)

RegisterNetEvent('reduceVehicleAcceleration')
AddEventHandler('reduceVehicleAcceleration', function(vehicle, powerMultiplier)
    SetVehicleEnginePowerMultiplier(vehicle, powerMultiplier * 100.0) 
end)

RegisterNetEvent('engineFailure')
AddEventHandler('engineFailure', function(vehicle)
    SetVehicleEngineOn(vehicle, false, true, true) 
end)
RegisterNetEvent('checkAndResetVehicle')
AddEventHandler('checkAndResetVehicle', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71) 
    if vehicle == 0 then
        ESX.ShowNotification('Aucun véhicule à proximité.')
        return
    end

    local vehiclePlate = string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", "") 
    -- TriggerServerEvent('resetVehicleState', vehiclePlate)
end)
RegisterNetEvent('resetVehicleState0')
AddEventHandler('resetVehicleState0', function(vehiclePlate)

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    if not vehiclePlate then
        return
    end
    
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)
    
    if DoesEntityExist(vehicle) then
        local currentVehiclePlate = GetVehicleNumberPlateText(vehicle)
        if currentVehiclePlate == vehiclePlate then
            if vehicles[vehiclePlate] then
                vehicles[vehiclePlate].distanceTraveled = 0
                vehicles[vehiclePlate].isEngineLightOn = false
                vehicles[vehiclePlate].distanceAfterLight = 0
                vehicles[vehiclePlate].engineOff = false
                vehicles[vehiclePlate].engineFailureTriggered = false
                SetVehicleEngineOn(vehicle, true, true, false) 
                SetVehicleMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")) 
                SetVehicleEnginePowerMultiplier(vehicle, 1.0) 
                SetVehicleEngineHealth(vehicle, 1000.0)
                -- ESX.ShowNotification('Le véhicule a été diagnostiqué et réparé.')
                TriggerEvent('hideEngineLight')
                TriggerEvent('stopExhaustSparks', vehicle)
                
            end
        else
        end
    else
    end
end)


local lastVehicle = nil

RegisterNetEvent('useDiag')
AddEventHandler('useDiag', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('server:useDiag', vehiclePlate)
    else
        ESX.ShowNotification('Vous devez être dans un véhicule pouvoir diagnostiquer.')
    end
end)

Citizen.CreateThread(function ()
    print('########################################################')
    print('#                                                      #')
    print('#                  Créé par jsui0max                   #')
    print('#           Merci d\'utiliser mon script !             #')
    print('#                                                      #')
    print('########################################################')
end)

RegisterNetEvent('openDiagMenu')
AddEventHandler('openDiagMenu', function(vehiclePlate)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local currentVehiclePlate = GetVehicleNumberPlateText(vehicle)
        if currentVehiclePlate == vehiclePlate then
            lib.registerContext({
                id = 'diag_menu',
                title = 'Diagnostique du Véhicule',
                options = {
                    -- {
                    --     title = 'Diagnostiquer le véhicule',
                    --     description = 'Valise pour verifier les erreurs',
                    --     onSelect = function()
                    --         lib.progressCircle({
                    --             duration = 5000, 
                    --             position = 'middle',
                    --             useWhileDead = false,
                    --             canCancel = false,
                    --             disable = {
                    --                 move = true,
                    --                 car = true,
                    --                 combat = true,
                    --             },
                    --             anim = {
                    --                 dict = 'mini@repair',
                    --                 clip = 'fixing_a_ped'
                    --             },
                    --         })
                    --         if vehicles[vehiclePlate] and vehicles[vehiclePlate].isEngineLightOn then
                    --             lib.registerContext({
                    --                 id = 'diag_menu_after_loading',
                    --                 title = 'Diagnostic du Véhicule',
                    --                 options = {
                    --                     {
                    --                         title = 'Effacer les erreurs',
                    --                         onSelect = function()
                    --                             lib.progressCircle({
                    --                                 duration = 5000, 
                    --                                 position = 'middle',
                    --                                 useWhileDead = false,
                    --                                 canCancel = false,
                    --                                 disable = {
                    --                                     move = true,
                    --                                     car = true,
                    --                                     combat = true,
                    --                                 },
                    --                                 anim = {
                    --                                     dict = 'mini@repair',
                    --                                     clip = 'fixing_a_ped'
                    --                                 },
                    --                             })
                    --                             TriggerServerEvent('server:resetVehicleState', vehiclePlate)
                    --                         end
                    --                     },
                    --                     -- {
                    --                     --     title = 'Annuler',
                    --                     --     onSelect = function()
                    --                     --         lib.closeContext()
                    --                     --     end
                    --                     -- }
                    --                 }
                    --             })
                    --             lib.showContext('diag_menu_after_loading')
                    --         else
                    --             ESX.ShowNotification('Aucune erreur détectée.')
                    --         end
                    --     end
                    -- },
                    {
                        title = 'Diagnostiquer le véhicule',
                        description = 'Valise pour verifier les erreurs',
                        onSelect = function()
                            lib.progressCircle({
                                duration = 10000, 
                                position = 'middle',
                                useWhileDead = false,
                                canCancel = false,
                                disable = {
                                    move = true,
                                    car = true,
                                    combat = true,
                                },
                                anim = {
                                    dict = 'mini@repair',
                                    clip = 'fixing_a_ped'
                                },
                            
                        })
                        if vehicles[vehiclePlate] and vehicles[vehiclePlate].isEngineLightOn then
                                        lib.registerContext({
                                            id = 'diag_menu_after_loading',
                                            title = 'Diagnostic du Véhicule',
                                            options = {
                                                {
                                                    title = 'Voir les details',
                                                    description = 'Vous devez remplacer la pieces defectueuse',
                                                    onSelect = function()
                                                        lib.progressCircle({
                                                            duration = 5000, 
                                                            position = 'middle',
                                                            useWhileDead = false,
                                                            canCancel = false,
                                                            disable = {
                                                                move = true,
                                                                car = true,
                                                                combat = true,
                                                            },
                                                            anim = {
                                                                dict = 'mini@repair',
                                                                clip = 'fixing_a_ped'
                                                            },
                                                        })
                                                        
                                                        -- Citizen.Wait(5000)
                                                        DiagnostiqueAppro()
                                                    end
                                                },
                                                {
                                                    title = 'Annuler',
                                                    onSelect = function()
                                                        lib.closeContext()
                                                    end
                                                }
                                            }
                                        })
                                        lib.showContext('diag_menu_after_loading')
                                    else
                                        ESX.ShowNotification('Aucune erreur détectée.')
                                    end
                                -- end
                            -- end
                        end
                    }
                }
            })
            lib.showContext('diag_menu')
        end
    end
end)
RegisterNetEvent('Annimation:mecanique')
AddEventHandler('Annimation:mecanique', function()
    local playerPed = PlayerPedId()
    
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BBQ", 0, true)
    
    Citizen.Wait(5000)
    ClearPedTasksImmediately(playerPed)
end)


function DiagnostiqueAppro()
    TriggerServerEvent('diag:launch')
end

RegisterNetEvent('startRepairAnimation')
AddEventHandler('startRepairAnimation', function()
    local playerPed = PlayerPedId()

    RequestAnimDict("amb@world_human_welding@male@base")
    while not HasAnimDictLoaded("amb@world_human_welding@male@base") do
        Wait(100)
    end
    TaskPlayAnim(playerPed, "amb@world_human_welding@male@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)

    Citizen.Wait(5000) 
    ClearPedTasks(playerPed)
end)

RegisterNetEvent('diag:showResult', function(panneLabel)
    lib.notify({
        title = 'Résultat du diagnostique',
        description = 'Problème détecté : ' .. (panneLabel or 'Inconnu'),
        type = 'error',
        position = 'top'
    })
end)

RegisterNetEvent('diag:checkVehicleState', function(expectedItem, usedItem)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Impossible',
            description = 'Sors du véhicule pour effectuer la réparation.',
            type = 'error',
        position = 'top'
        })
        return
    end

    if expectedItem ~= usedItem then
        TriggerServerEvent('diag:reparer')
        lib.notify({
            title = 'Pièce incorrecte',
            description = 'Cette pièce ne correspond pas à la panne détectée.',
            type = 'error',
        position = 'top'
        })
        return
    end

    TriggerServerEvent('diag:repairSuccess')
end)



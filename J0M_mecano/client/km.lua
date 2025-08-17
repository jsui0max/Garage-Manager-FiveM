local PlayerData = {}
local inVeh = false
local distance = 0
local vehPlate

local x = -0.301135
local y = -0.009
hasKM = 0
showKM = 0


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    SetTextColour(0, 0, 0, a) 
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText((x - 0.1+w) + 0.001, (y - 0.02+h) + 0.001) 

    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end



Citizen.CreateThread(function()
  while true do
	Citizen.Wait(250)
			if IsPedInAnyVehicle(PlayerPedId(), false) and not inVeh then
			Citizen.Wait(50)
			local veh = GetVehiclePedIsIn(PlayerPedId(),false)
			local driver = GetPedInVehicleSeat(veh, -1)
			if driver == PlayerPedId() and GetVehicleClass(veh) ~= 13 and GetVehicleClass(veh) ~= 14 and GetVehicleClass(veh) ~= 15 and GetVehicleClass(veh) ~= 16 and GetVehicleClass(veh) ~= 17 and GetVehicleClass(veh) ~= 21 then
			inVeh = true
			Citizen.Wait(50)
			vehPlate = GetVehicleNumberPlateText(veh)
			Citizen.Wait(1)
			ESX.TriggerServerCallback('esx_carmileage:getMileage', function(hasKM,entretien)
				
				showKM = math.floor(hasKM*1.33)/1000
				voitureEntretenue = entretien == 1
			local oldPos = GetEntityCoords(PlayerPedId())
			Citizen.Wait(1000)
			local curPos = GetEntityCoords(PlayerPedId())
			if IsVehicleOnAllWheels(veh) then
                local speedFactor = 5 
                dist = GetDistanceBetweenCoords(oldPos.x, oldPos.y, oldPos.z, curPos.x, curPos.y, curPos.z, true) * speedFactor
			else
			dist = 0
			end
			hasKM = hasKM + dist
			TriggerServerEvent('esx_carmileage:addMileage', vehPlate, hasKM)
			inVeh = false
			end, GetVehicleNumberPlateText(veh))
			else
			end
		end
	end
end)

displayHud = true

	Citizen.CreateThread(function()
		while true do
			if IsPedInAnyVehicle(PlayerPedId(), false) then
						local veh = GetVehiclePedIsIn(PlayerPedId(),false)
					local driver = GetPedInVehicleSeat(veh, -1)
					if driver == PlayerPedId() and GetVehicleClass(veh) ~= 13 and GetVehicleClass(veh) ~= 14 and GetVehicleClass(veh) ~= 15 and GetVehicleClass(veh) ~= 16 and GetVehicleClass(veh) ~= 17 and GetVehicleClass(veh) ~= 21 then
				DrawAdvancedText(0.270 - x, 0.97 - y, -0.385, 0.0028, 0.4, round(showKM, 2), 255, 255, 255, 255, 6, 1)
                -- DrawAdvancedText(0.270 - x, 0.97 - y, -0.385, 0.0028, 0.4, string.format("%06d", math.floor(round(showKM, 2) * 10)), 255, 255, 255, 255, 6, 1)

                DrawAdvancedText(0.325 - x, 0.97 - y, -0.405, 0.0028, 0.4, "kms", 255, 255, 255, 255, 6, 1)

				end
			else
				Citizen.Wait(750)
			end

			Citizen.Wait(0)
		end
	end)


Citizen.CreateThread(function()
	while true do
	Citizen.Wait(250)
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			local veh = GetVehiclePedIsIn(PlayerPedId(),false)
				local driver = GetPedInVehicleSeat(veh, -1)
				if showKM >= 5000 and not voitureEntretenue then
					if math.random(1, 100) <= 50 then
						SetVehicleEngineOn(veh, false, true, true)
						ESX.ShowNotification("Votre moteur refuse de démarrer...")
						Citizen.Wait(2000)
						SetVehicleEngineOn(veh, true, true, true)
					end
				end
			else
				Citizen.Wait(15000)
			end
		Citizen.Wait(1)
	end
end)
	
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
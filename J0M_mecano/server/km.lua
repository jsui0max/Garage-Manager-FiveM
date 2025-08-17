RegisterServerEvent('esx_carmileage:addMileage')
AddEventHandler('esx_carmileage:addMileage', function(vehPlate, km)
    local src = source
    local identifier = ESX.GetPlayerFromId(src).identifier
	local plate = vehPlate
	local newKM = km
    MySQL.Async.execute('UPDATE veh_km SET km = @kms WHERE carplate = @plate', {['@plate'] = plate, ['@kms'] = newKM})
end)

ESX.RegisterServerCallback('esx_carmileage:getMileage', function(source, cb, plate)
    local vehPlate = plate

    MySQL.Async.fetchAll('SELECT * FROM veh_km WHERE carplate = @plate', {
        ['@plate'] = vehPlate
    }, function(result)
        if result[1] then
            local mileage = result[1].mileage or result[1].km or 0
            local entretien = result[1].entretien or 1
            cb(mileage, entretien)
        else
            MySQL.Async.execute('INSERT INTO veh_km (carplate, km, entretien) VALUES (@plate, 0, 1)', {
                ['@plate'] = vehPlate
            }, function()
                cb(0, 1)
            end)
        end
    end)
end)
window.addEventListener('message', function(event) {
    if (event.data.action === 'showVehiclesList') {
        console.log("Données reçues pour les véhicules :", event.data.vehiclesList);
        const vehicleList = event.data.vehiclesList;
        const dropdown = document.getElementById('vehicle-dropdown');
        dropdown.innerHTML = '';  

        const defaultOption = document.createElement('option');
        defaultOption.textContent = "Sélectionner un véhicule...";
        defaultOption.value = ""; 
        dropdown.appendChild(defaultOption);

        if (vehicleList.length > 0) {
            vehicleList.forEach(vehicle => {
                const option = document.createElement('option');
                option.textContent = `${vehicle.vehicle} (Plaque: ${vehicle.plate})`;
                option.value = vehicle.plate;  
                dropdown.appendChild(option);
            });
        } else {
            const option = document.createElement('option');
            option.textContent = "Aucun véhicule trouvé.";
            dropdown.appendChild(option);
        }
    }

    if (event.data.action === "open") {
        document.body.style.display = "block";
    }

    if (event.data.action === "close") {
        document.body.style.display = "none";
    }
});



document.getElementById('submit').addEventListener('click', () => {
    const plate = document.getElementById('vehicle-dropdown').value;
    const date = document.getElementById('date').value;
    const service = document.getElementById('service').value;

    if (plate && date && service) {
        fetch(`https://${GetParentResourceName()}/sendRdv`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({ plate, date, service })
        });
    } else {
        alert("Veuillez remplir tous les champs.");
    }
});


document.getElementById('close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST'
        });
        document.body.style.display = "none";
    }
});

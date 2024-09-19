local isDead = false

AddEventHandler("onResourceStart", function(JobInfo)
    SetupEyeTarget()
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    SetupEyeTarget()
end)

local function SetupEyeTarget()

	exports['qtarget']:Player({

        options = {
			{
                event = "xJoww_Billing:client:sendBill",
                icon = "fas fa-scroll",
                label = "[POLICE] Kirim Billing",
                job = "police",
				society = "society_police",
				jobLabel = PlayerData.job.label
            },
			{
                event = "xJoww_Billing:client:sendBill",
                icon = "fas fa-scroll",
                label = "[MEDIC] Kirim Billing",
                job = "ambulance",
				society = "society_ambulance",
				jobLabel = PlayerData.job.label
            },
			{
                event = "xJoww_Billing:client:sendBill",
                icon = "fas fa-scroll",
                label = "[RESTO] Kirim Billing",
                job = "restaurant",
				society = "society_restaurant",
				jobLabel = PlayerData.job.label
            },
			{
                event = "xJoww_Billing:client:sendBill",
                icon = "fas fa-scroll",
                label = "[MECH] Kirim Billing",
                job = "mechanic",
				society = "society_mechanic",
				jobLabel = PlayerData.job.label
            },
			{
                event = "xJoww_Billing:client:sendBill",
                icon = "fas fa-scroll",
                label = "[TAXI] Kirim Billing",
                job = "taxi",
				society = "society_taxi",
				jobLabel = PlayerData.job.label
            },
            {
                event = "xJoww_Billing:client:checkBill",
                icon = "fas fa-scroll",
                label = "[POLICE] Cek Billing",
                job = "police"
            },
            {
                event = "xJoww_Billing:client:checkBill",
                icon = "fas fa-scroll",
                label = "[MEDIC] Cek Billing",
                job = "ambulance"
            },
            {
                event = "xJoww_Billing:client:checkBill",
                icon = "fas fa-scroll",
                label = "[RESTO] Cek Billing",
                job = "restaurant"
            },
            {
                event = "xJoww_Billing:client:checkBill",
                icon = "fas fa-scroll",
                label = "[MECH] Cek Billing",
                job = "mechanic"
            },
            {
                event = "xJoww_Billing:client:checkBill",
                icon = "fas fa-scroll",
                label = "[TAXI] Cek Billing",
                job = "taxi"
            },
        },
        distance = 3.0
    })
end

local function ShowMyBills()
    
    if isDead then
        lib.notify({
            title = 'My Billings',
            description = 'Kamu saat ini sedang pingsan!',
            type = 'error'
        })
        return
    end

	ESX.TriggerServerCallback('xJoww_Billing:server:getBills', function(bills)

		if #bills <= 0 then
            lib.notify({
                title = 'My Billings',
                description = 'Kamu tidak memiliki catatan billing!',
                type = 'error'
            })
            return
        end

		local elements = {}

		for _, v in ipairs(bills) do
			table.insert(elements, {
                title = v.label .." : ".. v.reason,
                description = 'Cost : $' .. ESX.Math.GroupDigits(v.amount) .. ' | Date : '.. v.date,
				icon = 'fas fa-scroll',
                event = 'xJoww_Billing:client:selectBill',
                args = { billId = v.id }
			})
		end

        lib.registerContext({
            id = 'myBills',
            title = 'My Billings (' .. #bills .. ')',
            options = elements
        })
        lib.showContext('myBills')
	end)
end

RegisterNetEvent("xJoww_Billing:client:selectBill")
AddEventHandler("xJoww_Billing:client:selectBill", function(data)
    
    local billId = data.billId
    
    ESX.TriggerServerCallback('xJoww_Billing:server:payBill', function(amount)
        
        if not amount then return end

        lib.notify({
            title = "My Billings",
            description = "Billing sebesar $".. ESX.Math.GroupDigits(amount) .." dilunaskan!",
            type = "success"
        })
        ShowMyBills()
        
    end, billId)
end)

RegisterNetEvent("xJoww_Billing:client:sendBill")
AddEventHandler("xJoww_Billing:client:sendBill", function(data)

    local input = lib.inputDialog('Kirim billing', {
        {type = 'input', label = 'Catatan', required = true, min = 3, max = 16, icon = 'fas fa-scroll'},
        {type = 'number', label = 'Nominal', required = true, min = 1, max = 1000, icon = 'fas fa-dollar-sign'},
    })
    if not input then return end

    local society = data.society
    local jobLabel = data.jobLabel
    local entity = data.entity
    local reason, amount = input[1], input[2]

    ESX.TriggerServerCallback("xJoww_Billing:server:queryInsert", function(res, targetName)
    
        if not res and not targetName then
            return lib.notify({ title = "Send Billing", description = "Terjadi kesalahan saat mengeksekusi data!", type = "error" })
        end

        lib.notify({

            title = "Send Billing",
            description = "Billing terkirim kepada " .. targetName,
            type = "success"
        })

    end, job, society, jobLabel, GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), reason, amount)
end)

RegisterNetEvent("xJoww_Billing:client:checkBill")
AddEventHandler("xJoww_Billing:client:checkBill", function(data)

    local target = data.entity

    ESX.TriggerServerCallback("xJoww_Billing:server:getUserBill", function(result)
    
        if #result <= 0 then
            return lib.notify({ title = "Check Billing", description = "Tidak ada riwayat billing!", type = "error" })
        end

        local elements = {}

		for _, v in ipairs(result) do
			table.insert(elements, {
                title = v.label .." : ".. v.reason,
                description = 'Cost : $' .. ESX.Math.GroupDigits(v.amount) .. ' | Date : '.. v.date,
				icon = 'fas fa-scroll'
			})
		end

        lib.registerContext({
            id = 'checkBills',
            title = 'Check Billings (' .. #bills .. ')',
            options = elements
        })
        lib.showContext('checkBills')
    
    end, target)
end)

lib.addKeybind({
    
    name = 'mybills',
    description = 'Open pending billings',
    defaultKey = Config.BillKeybind,
    onPressed = function()
        ShowMyBills()
    end
})

AddEventHandler("xJoww_Billing:client:ShowMyBills", ShowMyBills)
AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function() isDead = false end)
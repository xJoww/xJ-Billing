ESX.RegisterServerCallback('xJoww_Billing:server:getBills', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)
	local result = MySQL.query.await('SELECT id, date, label, reason, amount FROM billing WHERE identifier = ?', { xPlayer.identifier })
	cb(result)
end)

ESX.RegisterServerCallback('xJoww_Billing:server:getUserBill', function(source, cb, target)

	local xTarget = ESX.GetPlayerFromId(target)
	local result = MySQL.query.await('SELECT id, date, label, reason, amount FROM billing WHERE identifier = ?', { xTarget.identifier })
	cb(result)
end)

ESX.RegisterServerCallback("xJoww_Billing:server:queryInsert", function(source, cb, society, jobLabel, target, reason, amount)

	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(target)

	local timestamp = os.time()
    local dateTime = os.date("%Y/%m/%d, %H:%M", timestamp)

	local resultCb = false
	local targetName

	if xTarget then

		local rowId = MySQL.insert.await('INSERT INTO billing (identifier, sender, date, society, label, reason, amount) VALUES (?, ?, ?, ?, ?, ?, ?)', {
			xTarget.identifier, xPlayer.identifier, dateTime, society, jobLabel, reason, amount
		})
		if rowId == 1 then

			TriggerClientEvent("ox_lib:notify", target, {

				title = "My Billings",
				description = "Billing sebesar $".. ESX.Math.GroupDigits(amount) .." diterima dari ".. xPlayer.name,
				type = "inform"
			})
			TriggerClientEvent("ox_lib:notify", target, {

				title = "My Billings",
				description = "Ketik '".. Config.BillCommand .."' atau ".. Config.BillKeybind .." untuk membuka riwayat billing!",
				type = "inform"
			})
			resultCb, targetName = true, xTarget.name
		end
	end

	cb(resultCb, targetName)
end)

ESX.RegisterServerCallback("xJoww_Billing:server:payBill", function(source, cb, billId)

	local xPlayer = ESX.GetPlayerFromId(source)
	local row = MySQL.single.await('SELECT * FROM billing WHERE identifier = ? AND id = ? LIMIT 1', {
		xPlayer.identifier, billId
	})
	if not row then return end
	
	TriggerEvent('esx_addonaccount:getSharedAccount', row.society, function(account)
		
		if xPlayer.getAccount('bank').money < row.amount then
			TriggerClientEvent("ox_lib:notify", source, { title = "My Billings", description = "Kamu tidak memiliki cukup uang untuk membayar!", type = "error" })
			return
		end

		local rowsChanged = MySQL.update.await('DELETE FROM billing WHERE id = ?', { billId })
		if rowsChanged ~= 1 then return cb() end

		xPlayer.removeAccountMoney(paymentAccount, amount)
		account.addMoney(amount)

		cb(amount)
	end)
end)

lib.addCommand(Config.BillCommand, {

    help = Config.BillDescription,
    restricted = false

}, function(source, args, raw)

    TriggerClientEvent("xJoww_Billing:client:ShowMyBills", source)
end)
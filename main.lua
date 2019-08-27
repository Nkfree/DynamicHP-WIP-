local DynamicHP = {}

DynamicHP.scriptName = "DynamicHP"

DynamicHP.defaultData = {Actors = {}}

DynamicHP.data = DataManager.loadData(DynamicHP.scriptName, DynamicHP.defaultData)



DynamicHP.SaveData = function()

	DataManager.saveData(DynamicHP.scriptName, DynamicHP.data)
	
end


DynamicHP.GetVisitorCount = function(cellDescription)

local count = LoadedCells[cellDescription]:GetVisitorCount()

if count < 1 then
	count = 1
end

return count

end



DynamicHP.OnPlayerCellChangeHandler = function(eventStatus, pid)

if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	local cellDescription = Players[pid].data.location.cell
	local name = Players[pid].name
	local previousCell
	
	if LoadedCells[cellDescription] ~= nil then
		LoadedCells[cellDescription]:SaveActorStatsDynamic()
	
		previousCell = Players[pid].data.customVariables.previousCell 
		
		if previousCell then
			for _, uniqueIndex in pairs(LoadedCells[previousCell].data.packets.actorList) do
				DynamicHP.ActuallyChangeHealth(previousCell, uniqueIndex)
			end
		end
		
		for _, uniqueIndex in pairs(LoadedCells[cellDescription].data.packets.actorList) do
			DynamicHP.ActuallyChangeHealth(cellDescription, uniqueIndex)
		end
		
		if previousCell then
			DynamicHP.LoadActorStatsDynamic(previousCell)
		else
			DynamicHP.LoadActorStatsDynamic(cellDescription)
		end
		
		Players[pid].data.customVariables.previousCell = cellDescription
		Players[pid]:QuicksaveToDrive()
	end
end	

end


DynamicHP.OnActorCellChange = function(eventStatus, pid, cellDescription)

if LoadedCells[cellDescription] ~= nil then
	LoadedCells[cellDescription]:SaveActorStatsDynamic()
	
	for _, uniqueIndex in pairs(LoadedCells[cellDescription].data.packets.cellChangeFrom) do

		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
			DynamicHP.ActuallyChangeHealth(cellDescription, uniqueIndex)
		end

	end

	DynamicHP.LoadActorStatsDynamic(cellDescription)
end
end


DynamicHP.OnCellUnload = function(eventStatus, pid, cellDescription)

if cellDescription ~= nil and cellDescription ~= "" and LoadedCells[cellDescription] ~= nil then
	
	for _, uniqueIndex in pairs(LoadedCells[cellDescription].data.packets.actorList) do
		DynamicHP.ActuallyChangeHealth(cellDescription, uniqueIndex)
	end


	DynamicHP.LoadActorStatsDynamic(cellDescription)
	LoadedCells[cellDescription]:SaveActorStatsDynamic()
end
end

DynamicHP.DoLog = function(message)

tes3mp.LogMessage(1, "[DynamicHP] " .. message)

end



DynamicHP.CreateValidateDataEntry = function(cellDescription, uniqueIndex)

local refId = LoadedCells[cellDescription].data.objectData[uniqueIndex].refId

if refId then
	if not DynamicHP.data.Actors[refId] then 
		DynamicHP.data.Actors[refId] = LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthBase
		DynamicHP.DoLog("Succesfully created data entry for refId: " .. refId)
		DynamicHP.SaveData()
		return true
	else
		DynamicHP.DoLog(refId .. " already has data entry")
		return true
	end
else
	DynamicHP.DoLog("Unable to create data entry for refId: " .. refId)
end
end



DynamicHP.ActuallyChangeHealth = function(cellDescription, uniqueIndex)

local uniqueIndex = uniqueIndex
local visitorsCount = DynamicHP.GetVisitorCount(cellDescription)

if LoadedCells[cellDescription].data.objectData[uniqueIndex].stats ~= nil then
	local baseHP = LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthBase
	local currentHP = LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthCurrent
	local refId = LoadedCells[cellDescription].data.objectData[uniqueIndex].refId
	DynamicHP.DoLog("-------------------")
	DynamicHP.DoLog("refId: " .. refId)
	DynamicHP.DoLog("current HP: " .. currentHP)
	DynamicHP.DoLog("base HP: " .. baseHP)
	
	
	if DynamicHP.CreateValidateDataEntry(cellDescription, uniqueIndex) then
		local modifier = baseHP / DynamicHP.data.Actors[refId]
		DynamicHP.DoLog("modifier: " .. modifier .. " and visitorsCount: " .. visitorsCount)
		if modifier ~= visitorsCount then
			LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthBase = baseHP / modifier * visitorsCount
			LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthCurrent = currentHP / modifier * visitorsCount
			DynamicHP.DoLog("Change hp for uniqueIndex: " .. uniqueIndex .. " refId: " .. refId .. " " .. currentHP .. "/" .. baseHP .. " to " .. LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthCurrent .. "/" .. LoadedCells[cellDescription].data.objectData[uniqueIndex].stats.healthBase)
		end
	
	else
		DynamicHP.DoLog("Unable to change HP for " .. uniqueIndex)
	end
	DynamicHP.DoLog("-------------------")
end

end


DynamicHP.LoadActorStatsDynamic = function(cellDescription)

if LoadedCells[cellDescription] ~= nil then
	for pid in pairs(LoadedCells[cellDescription].visitors) do
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
			LoadedCells[cellDescription]:LoadActorStatsDynamic(pid, LoadedCells[cellDescription].data.objectData, LoadedCells[cellDescription].data.packets.actorList)
		end
	end
	
end
end





customEventHooks.registerHandler("OnPlayerCellChange", DynamicHP.OnPlayerCellChangeHandler)
customEventHooks.registerHandler("OnActorCellChange", DynamicHP.OnActorCellChange)
customEventHooks.registerHandler("OnCellUnload", DynamicHP.OnCellUnload)




return DynamicHP



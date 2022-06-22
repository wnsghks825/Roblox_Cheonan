local times = {
	-- Wesley1041 = {lastTime = 0, bestTime = 0, laps = 0, lapValid = true}, {name = "Player2", lastTime = 0, bestTime = 0}
}

local replicatedStorage = game:GetService("ReplicatedStorage")
local setLapTimeEvent = Instance.new("RemoteEvent", replicatedStorage)
setLapTimeEvent.Name = "SetLapTimeEvent"
local showLapsEvent = Instance.new("RemoteEvent", replicatedStorage)
showLapsEvent.Name = "ShowLapsEvent"
local cornerCutEvent = Instance.new("RemoteEvent", replicatedStorage)
cornerCutEvent.Name = "CornerCutEvent"
local ScoreEvent = Instance.new("RemoteEvent", replicatedStorage)
ScoreEvent.Name = "ScoreEvent"
local timeCheck = Instance.new("RemoteEvent", replicatedStorage)
timeCheck.Name = "TimeCheck"
local failed = Instance.new("RemoteEvent", replicatedStorage)
failed.Name = "Failed"
local ended = Instance.new("RemoteEvent", replicatedStorage)
ended.Name = "Ended"
local countdown = Instance.new("RemoteEvent", replicatedStorage)
countdown.Name = "Countdown"
local teleport = Instance.new("RemoteEvent", replicatedStorage)
teleport.Name = "Teleport"
local offGui = Instance.new("RemoteEvent", replicatedStorage)
offGui.Name = "OffGui"


local board = script.Parent.Board
local timesFrame = board.TimingGui.LapTimes

local converter = require(workspace.TimingModule)

local playerLastUpdated = {}
local playerLastUpdatedSector = {}

function NumberToTime(number)
	
	return converter:NumberToTime(number)
	
end

function SortTimes()
	
	return converter:SortTimes(times)
	
end

function DisplayLapTimes()
	
	local sortedTimes = SortTimes()
	
	showLapsEvent:FireAllClients(sortedTimes)
	
	for _, item in pairs(timesFrame:GetChildren()) do
		if item.Name ~= "Temp" then
			item:Destroy()
		end
	end
	
	local pos = 0
	
	for pos, item in pairs(sortedTimes) do
		local frame = timesFrame.Temp:Clone()
		frame.Parent = timesFrame
		frame.PlayerName.Text = item["player"]
		frame.Name = item["player"]
		frame.LastLap.Text = NumberToTime(item["lastTime"])
		if item["lapValid"] then
			frame.LastLap.TextColor3 = Color3.fromRGB(255, 246, 147)
		else
			frame.LastLap.TextColor3 = Color3.fromRGB(255, 150, 150)
		end
		frame.BestLap.Text = NumberToTime(item["bestTime"])
		frame.Pos.Text = pos
		frame.Position = UDim2.new(0, 0, 0, 50 * (pos - 1))
		frame.Visible = true
	end
	
	timesFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedTimes)
	
end

-- Inside a script (perhaps in ServerScriptService):
local replicatedStorage = game:GetService("ReplicatedStorage")

function SetLapTime(plr, lapTime, lapValid)
--[[
	if lapValid then
		times[plr.Name]["laps"] = times[plr.Name]["laps"] + 1
		--UpdateLapCount(plr, times[plr.Name]["laps"])	
	end
]]
	times[plr.Name]["lastTime"] = lapTime
	
	times[plr.Name]["lapValid"] = lapValid
	
	if lapValid and (times[plr.Name]["bestTime"] > lapTime or times[plr.Name]["bestTime"] == 0) then
		times[plr.Name]["bestTime"] = lapTime
	end
	
	print(plr.Character)
	
	setLapTimeEvent:FireAllClients(plr.Name, lapTime, lapValid)
	
	DisplayLapTimes()
	
end

-- Update lap count to leaderboard
function UpdateLapCount(plr, newLapCount)
	
	if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Laps") then
		plr.leaderstats.Laps.Value = newLapCount
	end
	--렙 카운트 증가. 
end

function UpdateScore(plr)
	if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Quiz") then
		plr.leaderstats.Quiz.Value = plr.leaderstats.Quiz.Value + 1
	end

end

function AddCornerCut(plr)
	
	if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("CornerCuts") then
		plr.leaderstats.CornerCuts.Value = plr.leaderstats.CornerCuts.Value + 1
	end
	
end


-- create leaderstats
function CreateLeaderstats(plr)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderboard"
	leaderstats.Parent = plr
	
	local laps = Instance.new("IntValue", leaderstats)
	laps.Name = "Laps"
	
	local cc = Instance.new("IntValue", leaderstats)
	cc.Name = "CornerCuts"
	
	local quiz = Instance.new("IntValue", leaderstats)
	quiz.Name = "Quiz"
	
end

local endline = replicatedStorage:WaitForChild("Endline")

game.Players.PlayerAdded:Connect(function(plr)
	
	local clone = script.TimerGui:Clone()
	clone.Parent = plr.PlayerGui
	
	times[plr.Name] = {lastTime = 0, bestTime = 0, laps = 0, lapValid = true, isFalied = false}

	--들어와 있다면 각 차들의 좌표를 비교. 
	DisplayLapTimes()
	CreateLeaderstats(plr)

	local r = game.Workspace.WesTutorialTimer.TimerServerScript.TimerGui:Clone()
	r.Parent = plr.PlayerGui
end)

game.Players.PlayerRemoving:Connect(function(plr)
	
	times[plr.Name] = nil
	
	DisplayLapTimes()
	
end)

local checkpoint1 = game.Workspace.Map1.S1
local checkpoint2 = game.Workspace.Map1.S2
local checkpoint3 = game.Workspace.Map1.S3
local start = game.Workspace.Map1.Start
local startingTime = 0
local deltaTime = 0

function StartTimer()
	startingTime = time()
end

function clearCheckpoint(checkPoint)
	for _, object in pairs(checkPoint:GetChildren()) do
		if object.Name ~= "TouchInterest" then
			object:Destroy()
		end
	end
end

Lap = 0

local m_CurrentScore = 0
local newScore = 0

local Players = game:GetService("Players")
local usersDiagnostic = game.Workspace.Lobby["LobbySpawn"..math.random(1, #game.Workspace.Lobby:GetChildren()-1)]
function startHit(otherPart)	
	if otherPart ~= nil and otherPart.Parent ~= nil and	 otherPart.Parent:FindFirstChild("Humanoid") then


		if checkpoint3:FindFirstChild(otherPart.Parent.Name) then
			local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
			local d = player.Character:FindFirstChild("Humanoid")
			endline.OnServerEvent:Connect(function(plr, kart)		
				
				local num = Instance.new("StringValue")
				num.Parent = start
				num.Name = otherPart.Parent.Name
				
				teleport.OnServerEvent:Connect(function(plr, kart)
					
					kart:SetPrimaryPartCFrame(CFrame.new(usersDiagnostic.Position.X, usersDiagnostic.Position.Y + 2, usersDiagnostic.Position.Z))
					wait(1)
					kart:Destroy()
					d.JumpPower = 50
					
					--별 재소환하기
					if game.Workspace.Star then
						game.Workspace.Star:Destroy()
						
						local spawn = replicatedStorage.Star:Clone()
						spawn.Parent = game.Workspace
					end
					
					
				end)				
			end)
			
		clearCheckpoint(checkpoint1)
		clearCheckpoint(checkpoint2)
		clearCheckpoint(checkpoint3)			
			
		end
	end
end



function checkpoint1Hit(otherPart)
	if otherPart ~= nil and otherPart.Parent ~= nil and otherPart.Parent:FindFirstChild("Humanoid") then
		if not checkpoint1:FindFirstChild(otherPart.Parent.Name) then
			local playerTag = Instance.new("StringValue")
			playerTag.Parent = checkpoint1
			playerTag.Name = otherPart.Parent.Name
			
		end
	end
end

function checkpoint2Hit(otherPart)
	if otherPart ~= nil and otherPart.Parent ~= nil and otherPart.Parent:FindFirstChild("Humanoid") then
		if not checkpoint2:FindFirstChild(otherPart.Parent.Name) then
			local playerTag = Instance.new("StringValue")
			playerTag.Parent = checkpoint2
			playerTag.Name = otherPart.Parent.Name

		end
	end
end

function checkpoint3Hit(otherPart)
	if otherPart ~= nil and otherPart.Parent ~= nil and otherPart.Parent:FindFirstChild("Humanoid") then
		if not checkpoint3:FindFirstChild(otherPart.Parent.Name) then
			local playerTag = Instance.new("StringValue")
			playerTag.Parent = checkpoint3
			playerTag.Name = otherPart.Parent.Name

		end
	end
end

start.Touched:Connect(startHit)

checkpoint1.Touched:Connect(checkpoint1Hit)

checkpoint2.Touched:Connect(checkpoint2Hit)

checkpoint3.Touched:Connect(checkpoint3Hit)

--start.Touched:Connect(finishHit)

setLapTimeEvent.OnServerEvent:Connect(SetLapTime)

cornerCutEvent.OnServerEvent:Connect(AddCornerCut)

ScoreEvent.OnServerEvent:Connect(UpdateScore)


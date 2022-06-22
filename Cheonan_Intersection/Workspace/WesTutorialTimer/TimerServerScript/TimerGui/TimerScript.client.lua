local plr = game.Players.LocalPlayer

local frame = script.Parent.TimeKeeper
local popup = script.Parent.Popup
local timesFrame = script.Parent.LapTimes

local converter = require(workspace.TimingModule)

local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local setLapTimeEvent = replicatedStorage:WaitForChild("SetLapTimeEvent")
local showLapsEvent = replicatedStorage:WaitForChild("ShowLapsEvent")
local cornerCutEvent = replicatedStorage:WaitForChild("CornerCutEvent")
local scoreEvent = replicatedStorage:WaitForChild("ScoreEvent")
local disable = replicatedStorage:WaitForChild("DisableGui")
local failed = replicatedStorage:WaitForChild("Failed")
local teleport = replicatedStorage:WaitForChild("Teleport")
local ended = replicatedStorage:WaitForChild("Ended")
local countdown = replicatedStorage:WaitForChild("Countdown")
local offGui = replicatedStorage:WaitForChild("OffGui")
local restart = replicatedStorage:WaitForChild("Restart")

local startingTime = 0
local stoppingTime = 0
local deltaTime = 0

local lastLapTime = 0
local bestLapTime = 0

local lastPopup = 0

local enabled = false
local boardVisible = false
local lapValid = true
local lastCCAt = 0

local sector = 0

local score = 0

local s1 = 0
local s2 = 0
local s3 = 0


function NumberToTime(number)
	
	return converter:NumberToTime(number)
	
end

function PopupTime(name, lapTime, isValid)
	
	local thisPopup = time()
	if isValid then
		popup.BackgroundColor3 = Color3.new(0, 0, 0)
	else
		popup.BackgroundColor3 = Color3.new(0.2, 0, 0)
	end
	lastPopup = thisPopup
	--popup.Visible = true
	--popup.Text = " " .. name .. " has set a " .. NumberToTime(lapTime)
	wait(5)
	if lastPopup == thisPopup then
		popup.Visible = false
	end
	
end

function DisplayTimes(times)
	
	for _, item in pairs(timesFrame:GetChildren()) do
		if item.Name ~= "Temp" then
			item:Destroy()
		end
	end
	
	for pos, item in pairs(times) do
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
		frame.Position = UDim2.new(0, 0, 0, 30 * (pos - 1))
		frame.Visible = true
	end
	
	timesFrame.CanvasSize = UDim2.new(0, 0, 0, #times)
	
end

function HandleInput(input, _)
	
	if input.UserInputState == Enum.UserInputState.Begin then
		
		if input.KeyCode == Enum.KeyCode.Q then
			ShowTimingBoard(true)
		end
		
	elseif input.UserInputState == Enum.UserInputState.End then
		
		if input.KeyCode == Enum.KeyCode.Q then
			ShowTimingBoard(false)
		end
		
	end
	
end

function ShowTimingBoard(show)
	
	local fadeTime = 0.5 -- fading time in seconds
	
	local x = (0.5 - timesFrame.Position.X.Scale) ^ 0.5
	if show then
		timesFrame.Visible = true
		boardVisible = true	
		while boardVisible and x > 0 do
			x = math.max(0, x - 1/(60 * fadeTime))
			timesFrame.Position = UDim2.new(0.5 - x^2, -300, 0.5, -200)
			runService.RenderStepped:Wait()
		end
	else
		boardVisible = false
		while not boardVisible and x < 1 do
			x = math.min(1, x + 1/(60 * fadeTime))
			timesFrame.Position = UDim2.new(0.5 - x^2, -300, 0.5, -200)
			runService.RenderStepped:Wait()
		end
		if not boardVisible then
			timesFrame.Visible = false
		end
	end
	
end


local currentZoom = (workspace.CurrentCamera.CFrame.Position - workspace.CurrentCamera.Focus.Position).Magnitude

local LastMaxZoom = plr.CameraMaxZoomDistance -- save the current settings
local LastMinZoom = plr.CameraMinZoomDistance  -- ^
local isDisabled = false

function StartTimer()
	
	enabled = true
	frame.Start.Text = "Stop"
	startingTime = time()
	lapValid = true
	
	isDisabled = true
	
	game.Workspace.Camera.CameraType = Enum.CameraType.Custom
	plr.CameraMaxZoomDistance = 15
	plr.CameraMinZoomDistance = 15
	
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local endline = replicatedStorage:WaitForChild("Endline")

local UserInputService = game:GetService("UserInputService")

local usersDiagnostic = game.Workspace.Lobby["LobbySpawn"..math.random(1, #game.Workspace.Lobby:GetChildren()-1)]

function StopTimer()
	
local car = plr.Character.Humanoid.SeatPart
local Kart = car.Parent
	
	plr.PlayerGui.Countdown.Enabled = false
	
	enabled = false
	frame.Start.Text = "Start"
	stoppingTime = time()
	
	-- lap times
	lastLapTime = stoppingTime - startingTime
	if lapValid and (bestLapTime == 0 or lastLapTime < bestLapTime) then
		bestLapTime = lastLapTime
	end
	
	plr.PlayerGui.FinishScreen.Finish.Visible = true
	plr.PlayerGui.FinishScreen.Finish.ImageLabel.TextLabel.Text = NumberToTime(lastLapTime - score)
	
	endline:FireServer(Kart)
	
	setLapTimeEvent:FireServer(lastLapTime, lapValid)
	
	isDisabled = false
	plr.CameraMaxZoomDistance = LastMaxZoom
	plr.CameraMinZoomDistance = LastMinZoom
	
	plr.PlayerGui["A-Chassis Interface"].Enabled = false
	
	local starting = plr.PlayerGui["A-Chassis Interface"]:WaitForChild("IsOn")
	starting.Value = false		
	
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function ShowTime()
	
	if enabled then
		if lapValid then
			deltaTime = time() - startingTime
			frame.Current.Text = NumberToTime(deltaTime)
		else
			frame.Current.Text = "-.---"
		end
	end
	
	frame.LastLap.Text = NumberToTime(lastLapTime)
	frame.BestLap.Text = NumberToTime(bestLapTime)
	
end

function Reset()
	
	StopTimer()
	startingTime = 0
	stoppingTime = 0
	lastLapTime = 0
	
end

disable.OnClientEvent:Connect(StartTimer)

local function displayLapTime(lap)
	local label = script.Parent.TimeDisplay.Label
	label.Text = lap
	label.Visible = true
	
	wait(5)
	
	label.Visible = false
	
end


function TouchSector()

	if sector < 4 then

		if sector == 1 then

		elseif sector == 2 then

		elseif sector == 3 then

		end

	else

		if sector == 4 then
			frame.Current.Text = "-.---"
			StopTimer()

			startingTime = 0
			stoppingTime = 0
			lastLapTime = 0
		end
		
	end 	

end
local lobby = game.Workspace.Lobby
local player = game.Players
local isFinished = false

function Ended()	
	plr.PlayerGui.Games.Button.Change.Visible = true	
end

offGui.OnClientEvent:Connect(Ended)
countdown.OnClientEvent:Connect(function(name)
	
	plr.PlayerGui.Countdown.Enabled = true
	plr.PlayerGui.Countdown.TextLabel.Text = name
	
end)

function TouchedSomething(part)
	
	if not plr.Character.Humanoid.Sit then
		return
	end
	
	if part.Name == "Start" then
		
		print(sector)
		
		if sector == 4 then
			
			local car = plr.Character.Humanoid.SeatPart
			local Kart = car.Parent
			plr.PlayerGui.Countdown.TextLabel.Visible = false		
			plr.PlayerGui.Fail.Enabled = false
			
			TouchSector()
			
			--Kart:Destroy()
		end
		sector = 1
		
	elseif part.Name == "S1" and sector == 1 then

		TouchSector()
		sector = 2

	elseif part.Name == "S2" and sector == 2 then

		TouchSector()
		sector = 3
	elseif part.Name == "S3" and sector == 3 then

		TouchSector()
		sector = 4
	elseif part.Name == "CornerCut" then
		
		local range = 100
		local closest

		for _, enemy in ipairs(game.Workspace.SpawnPoint:GetChildren()) do
			local distance = (plr.Character.HumanoidRootPart.Position - enemy.Position).Magnitude
			if distance < range then
				closest = enemy
			end
		end
		
		--코스 이탈 시 리스폰 지역으로 이동
		local car = plr.Character.Humanoid.SeatPart
		local Kart = car.Parent

		plr.RespawnLocation = closest	
		Kart:SetPrimaryPartCFrame(CFrame.new(closest.Position.X, closest.Position.Y + 2, closest.Position.Z))

		displayLapTime("Warning: Track Extending", 0)
		
	elseif part.Name == "Star" then
		
		scoreEvent:FireServer()
		part:Destroy()
		
		score += 1
	
	end			
end


-- Events
-- Buttons
--frame.Start.MouseButton1Click:Connect(ToggleTimer)
frame.Reset.MouseButton1Click:Connect(Reset)

setLapTimeEvent.OnClientEvent:Connect(PopupTime)
showLapsEvent.OnClientEvent:Connect(DisplayTimes)
inputService.InputBegan:Connect(HandleInput)
inputService.InputChanged:Connect(HandleInput)
inputService.InputEnded:Connect(HandleInput)

while not plr.Character do
	wait()
end

plr.Character:WaitForChild("Head").Touched:Connect(TouchedSomething)

-- Loop
while true do
	
	ShowTime()
	wait()
	
end

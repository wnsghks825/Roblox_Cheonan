-- Script

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local createPartRequest = Instance.new("RemoteFunction")
createPartRequest.Parent = ReplicatedStorage
createPartRequest.Name = "CreatePartRequest"

local posa = game.Workspace.Lobby["LobbySpawn"..math.random(1, #game.Workspace.Lobby:GetChildren()-1)]
game.ReplicatedStorage:WaitForChild("SpawnCar").OnServerInvoke = function(player,NameOfCar)
	local car = game.ServerStorage.Cars:FindFirstChild(NameOfCar):Clone()
	car:SetPrimaryPartCFrame((player.Character.HumanoidRootPart.CFrame  + Vector3.new(0, 3, 0)))
	
	--local angleOffset = (car:GetPrimaryPartCFrame() * CFrame.Angles(0,math.rad(script.Parent.H.Orientation.X + 2),0))
	
	--local newpart = Instance.new("Part") -- this is the only thing that fixes it and i have heard that it only happens to this specific block
	--car.CFrame = CFrame.fromOrientation(math.rad(newpart.Orientation.X),math.rad(newpart.Orientation.Y),math.rad(newpart.Orientation.Z))
	--newpart:Destroy()
	
	car.Parent = workspace.Car
	car:MakeJoints()
	car.Name = NameOfCar
	return car.DriveSeat
end	

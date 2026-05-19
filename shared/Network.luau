--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local REMOTES_FOLDER_NAME = "Remotes"

local remotesFolder: Folder? = nil

local function getRemotesFolder(): Folder
	if remotesFolder then
		return remotesFolder
	end

	local existingFolder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
	if existingFolder and existingFolder:IsA("Folder") then
		remotesFolder = existingFolder
		return existingFolder
	end

	if RunService:IsServer() then
		local folder = Instance.new("Folder")
		folder.Name = REMOTES_FOLDER_NAME
		folder.Parent = ReplicatedStorage
		remotesFolder = folder
		return folder
	end

	local folder = ReplicatedStorage:WaitForChild(REMOTES_FOLDER_NAME)
	assert(folder:IsA("Folder"), `[Network] Expected {REMOTES_FOLDER_NAME} to be a Folder`)
	remotesFolder = folder
	return folder
end

local function getRemoteEvent(name: string): RemoteEvent
	local folder = getRemotesFolder()

	if RunService:IsServer() then
		local existingRemote = folder:FindFirstChild(name)
		if existingRemote and existingRemote:IsA("RemoteEvent") then
			return existingRemote
		end

		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		return remote
	end

	local remote = folder:WaitForChild(name)
	assert(remote:IsA("RemoteEvent"), `[Network] Expected {name} to be a RemoteEvent`)
	return remote
end

local Network = {
	Events = {
		TurnStarted = "TurnStarted",
		MatchStateUpdated = "MatchStateUpdated",
		ActionRequested = "ActionRequested",
	},
	GetRemoteEvent = getRemoteEvent,
}

return Network

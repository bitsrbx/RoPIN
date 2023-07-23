-- Official RoPIN ModuleScript by @bitsNbytez. v1.0
local RoPIN = {}

-- Settings
local PIN_LENGTH = 4 -- The PIN should be exactly 4 digits long.

-- Get variables
local pinDatastore = game:GetService("DataStoreService"):GetDataStore("PINDatastore")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Local module functions
function setupEvents(shouldCallDefault)
	local folder = Instance.new("Folder")
	folder.Name = "RoPINEvents"
	folder.Parent = replicatedStorage
	
	local verifyEvent = Instance.new("RemoteFunction")
	verifyEvent.Name = "Verify"
	verifyEvent.Parent = folder
	
	local createEvent = Instance.new("RemoteFunction")
	createEvent.Name = "Create"
	createEvent.Parent = folder
	
	return createEvent, verifyEvent
end

-- Server-sided functions
function RoPIN.init() -- Returns null
	local verify, create = setupEvents()
	return verify, create
end

function RoPIN.verify(player, pin, callback) -- Returns success, err
	if player and pin then
		local success, PIN = pcall(function()
			return pinDatastore:GetAsync(player.UserId)
		end)

		if success then
			if tonumber(pin) == tonumber(PIN) then
				if callback then
					task.delay(0, callback)
				end
				return true, ""
			else
				return false, "PIN does not match"
			end
		else
			return false, "Could not get PIN"
		end
	end
end

function RoPIN.create(player, pin, callback) -- Returns success, err
	if player and pin then
		local strPIN = tostring(pin) -- For checking count
		pin = tonumber(pin) -- Convert to number just in case
		
		local userHasPIN, PIN = pcall(function() -- Check to see if PIN exists
			return pinDatastore:GetAsync(player.UserId)
		end)
		
		if string.len(strPIN) == PIN_LENGTH then
			if userHasPIN and PIN ~= nil then -- PIN exists already
				return false, "User already has PIN"
			else
				local success, err = pcall(function() -- Check to see if PIN exists
					pinDatastore:SetAsync(player.UserId, pin)
				end)
				
				if success then
					if callback then
						task.delay(0, callback)
					end
					return true, "" -- Saved successfully!
				else
					return false, err -- PIN could not be saved
				end
			end
		else
			return false, "Invalid PIN length"
		end
	end
end

return RoPIN

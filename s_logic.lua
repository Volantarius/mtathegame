local playerSkins = {
0, 7, 17, 30, 33, 34, 50, 68, 70, 71, 83, 100, 101, 102, 106,
112, 125, 147, 153, 156, 165, 166, 179, 181, 206, 241, 247,
249, 255, 265, 270, 271, 280, 282, 284, 285, 286, 287, 288,
292, 294, 295, 299
}

function setStats(player)
	setPedStat(player, 69, 980) -- pistol
	setPedStat(player, 70, 999) -- silenced
	setPedStat(player, 71, 999) -- deagle
	setPedStat(player, 72, 999) -- shotgun
	setPedStat(player, 73, 980) -- sawnoff
	setPedStat(player, 74, 999) -- spas12
	setPedStat(player, 75, 980) -- uzi
	setPedStat(player, 76, 980) -- mp5
	setPedStat(player, 77, 999) -- ak47
	setPedStat(player, 78, 999) -- m4
	setPedStat(player, 79, 999) -- sniper
	setPedStat(player, 160, 999) -- Driving
	setPedStat(player, 229, 999) -- Bike
	setPedStat(player, 230, 999) -- Cycle
end

local randWeapons = {
	-- [slot] = {{weapon id}, ammo} 0 weapon id will give no weapon
	[0] = {{22, 23, 24}, 300}, -- pistols
	[1] = {{25, 27, 0}, 100}, -- shotguns
	[2] = {{28, 29}, 300}, -- smgs
	[3] = {{30, 31}, 500}, -- assault rifles
	[4] = {{34, 0}, 100}, -- rifles
	[5] = {{39}, 10} -- satchels
}

local quarryBlips = {  }
local poisonTimers = {  }

-- DONT CHANGE THESE VARIABLES! THESE ARE NOT SETTINGS!!!
local gameStarted = false -- Game state if a game is in progress (true), or in the lobby (false)
local playersReady = 0 -- Players that are ready to play
local forceStartTimer = false

function giveRandomWeapons(player)
	
	for slotKey,weapons in pairs(randWeapons) do
		local randomID = math.random(1, #weapons[1])
		
		giveWeapon(player, weapons[1][randomID], weapons[2])
	end
	
end

function spawnPlayer(player, skin, spawnpoint)
	if not(isElement(player)) then return end
	exports.spawnmanager:spawnPlayerAtSpawnpoint(player, spawnpoint)
	
	setPlayerHudComponentVisible(player, "all", true)
	
	setStats(player)
	giveRandomWeapons(player)
	
	setElementModel(player, skin)
	fadeCamera(player, true)
	setCameraTarget(player, player)
	showChat(player, true)
end

function setCameraToLobby(player)
	if (isElement(player)) then
		triggerClientEvent(player, "tgSpectateOff", resourceRoot)
		
		setCameraMatrix(player, 2496.2934570313, -1687.767578125, 14.192299842834, 2497.05859375, -1687.1256103516, 14.14232063293)
		
		setPlayerHudComponentVisible(player, "all", false)
		
		fadeCamera(player, true)
		
		triggerClientEvent(player, "tgLobbyGui", resourceRoot)
	end
end

function startLobby() -- Use this to stop the game and bring all the players to the lobby to await next round
	gameStarted = false
	local players = getElementsByType("player")
	
	for bkey,blip in ipairs(quarryBlips) do
		destroyElement(blip)
		quarryBlips[tostring(bkey)] = false
	end
	
	for pkey,timer in pairs(poisonTimers) do
		if (timer ~= false) then
			killTimer(timer)
		end
		poisonTimers[tostring(pkey)] = false
	end
	
	-- I could respawn all cars with respawnVehicle, and also remove the ones before it? not sure if it will remove the old ones.
	
	for key,player in pairs(players) do
		fadeCamera(player, false)
		if (isPedDead == false) then
			setTimer(killPed, 2000, 1, player)
		end
		setTimer(setCameraToLobby, 3000, 1, player)
	end
	
	if (forceStartTimer == false) then
		forceStartTimer = setTimer(checkReadys, 120000, 1, true)
	end
	
end

addEvent("tgReady", true)
function readyStart()
	if (gameStarted == false) then
		local playerCount = getElementsByType("player")
		playersReady = playersReady + 1
		
		triggerClientEvent("tgPlayersReady", resourceRoot, playersReady)
		
		if ((playersReady / tonumber(#playerCount)) >= 0.7) then
			triggerClientEvent("tgLobbyGuiHide", resourceRoot)
			
			startGame()
		end
		
	else
		local ptrigger = getPlayerName(client)
		outputServerLog("Player: " ..ptrigger.. ". Has triggered their ready while a game is in progress.")
		-- Any player that has somehow triggered a ready while a game has started
		-- This should NOT happen since they shouldn't be at the lobby
		-- Possible cheater if triggered!
	end
end
addEventHandler("tgReady", root, readyStart)

function checkReadys(forceStart)
	if (gameStarted == false) then
		local playerCount = getElementsByType("player")
		playersReady = playersReady + 1
		
		triggerClientEvent("tgPlayersReady", resourceRoot, playersReady)
		
		if ((playersReady / tonumber(#playerCount)) >= 0.7) or (forceStart == true) then
			triggerClientEvent("tgLobbyGuiHide", resourceRoot)
			
			startGame()
		end
	
	else
		
	end
end

function startGame()
	gameStarted = true
	playersReady = 0
	triggerClientEvent("tgPlayersReady", resourceRoot, playersReady)
	local spawnpoints = getElementsByType("spawnpoint")
	local players = getElementsByType("player")
	
	for key,player in pairs(players) do
		local skin = math.random(1,#playerSkins)
		local randSP = math.random(1,#spawnpoints)
		
		local pName = getPlayerName(player)
		quarryBlips[pName] = createBlipAttachedTo(player)
		
		setElementData(player, "tg.quarry", false) -- Removes previous quarries
		setElementVisibleTo(quarryBlips[pName], root, false)
		
		poisonTimers[pName] = setTimer(poison, 60000, 0, player)
		
		spawnPlayer(player, playerSkins[skin], spawnpoints[randSP])
		
		table.remove(spawnpoints, randSP) -- Removes used spawnpoint locally, so this should work
	end
	
	killTimer(forceStartTimer)
	forceStartTimer = false
	
	-- AFTER EVERYONE SPAWNS then assign quarries not during spawning
	local qplayers = getAlivePlayers()
	
	for pkey,quarry in pairs(qplayers) do
		assignQuarry(quarry)
	end
	
end

function poison(player)
	local pHealth = getElementHealth(player)
	local poisonStrength = 10 -- Change this to change how much health the player drains from the poison
	
	if (pHealth > poisonStrength) then
		setElementHealth(player, (pHealth - poisonStrength))
	else
		killPed(player)
	end
end

function assignQuarry(player)
	local players = getAlivePlayers()
	local myKey = 0
	local pName = "ERROR NAME IS WRONG"
	local myName = getPlayerName(player)
	
	setElementHealth(player, 100)
	resetTimer(poisonTimers[myName])
	
	if (#players > 1) then
		local quarry = getElementData(player, "tg.quarry")
		if (quarry ~= false) then
			setElementVisibleTo(quarryBlips[quarry], player, false)
			outputChatBox("Your Quarry has been killed!", player, 192, 0, 0, false)
		end
		
		for key,playerQuarry in pairs(players) do
			if (playerQuarry == player) then
				myKey = key
				break
			end
		end
		
		local randPlayer = math.random(1, #players)
		
		if (randPlayer == myKey) then
			if ((randPlayer + 1) > #players) then
				local pName = getPlayerName(players[randPlayer - 1])
				setElementData(player, "tg.quarry", pName)
				setElementVisibleTo(quarryBlips[pName], player, true)
				
				outputChatBox("Your Quarry is: " ..pName, player, 192, 0, 0, false)
			else
				local pName = getPlayerName(players[randPlayer + 1])
				setElementData(player, "tg.quarry", pName)
				setElementVisibleTo(quarryBlips[pName], player, true)
				
				outputChatBox("Your Quarry is: " ..pName, player, 192, 0, 0, false)
			end
		else
			local pName = getPlayerName(players[randPlayer])
			setElementData(player, "tg.quarry", pName)
			setElementVisibleTo(quarryBlips[pName], player, true)
			
			outputChatBox("Your Quarry is: " ..pName, player, 192, 0, 0, false)
		end
	else
		-- This is the WIN state!
		-- If the player is the last one standing then yes they do win infact!
		
		-- Give them a congrats screen with their stats (If i make them)
		-- And then goto the lobby screen for a new round
		
		-- This will take the winner to the lobby for now (CHANGE THIS!!!) I want to give each player a end screen showing stats and stuff
		local quarry = getElementData(player, "tg.quarry")
		if (quarry ~= false) then
			setElementVisibleTo(quarryBlips[quarry], player, false)
			outputChatBox("You WIN!", player, 192, 0, 0, false)
		end
		setTimer(startLobby, 30000, 1)
		-- Make a new lobby thats before the real one that shows stats and stuff
		-- Or simply show the stats over the screen and then wait until the lobby starts to stop showing it.
	end
	
end

function wastedHandler(totalAmmo, killer, killerWeapon, bodypart, stealth)
	local players = getAlivePlayers()
	local myName = getPlayerName(source)
	
	killTimer(poisonTimers[myName])
	
	for pkey,player in pairs(players) do
		local quarry = getElementData(player, "tg.quarry")
		
		if (quarry == myName) then
			setTimer(assignQuarry, 500, 1, player)
		end
	end
	
	setTimer(triggerClientEvent, 1000, 1, source, "tgSpectate", resourceRoot)
	
end

function joinHandler()
	if (gameStarted == false) then
		fadeCamera(source, false)
		setTimer(setCameraToLobby, 3000, 1, source)
	else
		setTimer(fadeCamera, 2000, 1, source, true)
		setTimer(triggerClientEvent, 1000, 1, source, "tgSpectate", resourceRoot)
	end
end

function quitHandler()
	if (gameStarted == false) then
		setTimer(checkReadys, 500, 1)
	else
		local players = getAlivePlayers()
		local myName = getPlayerName(source)
		
		if (isPedDead(source) == false) then
			killTimer(poisonTimers[myName])
		end
		
		for pkey,player in pairs(players) do
			local quarry = getElementData(player, "tg.quarry")
			
			if (quarry == myName) then
				setTimer(assignQuarry, 500, 1, player)
			end
		end
		
	end
end

function resourceStart()
	setMinuteDuration(6000)
end

addCommandHandler("forceLobby", startLobby)

addEventHandler("onResourceStart", root, resourceStart)

addEventHandler("onGamemodeMapStart", root, startLobby)

addEventHandler("onPlayerJoin", root, joinHandler)

addEventHandler("onPlayerQuit", root, quitHandler)

addEventHandler("onPlayerWasted", root, wastedHandler)
function createLobbyGUI()
	readyButton = guiCreateButton( (0.5 - 0.075), 0.80, 0.15, 0.05, "READY", true )
	
	headerText = guiCreateLabel( 0, 0.35, 1, 0.25, "Not Ready", true )
	guiSetFont(headerText, "sa-gothic")
	guiLabelSetColor(headerText, 192, 0, 0)
	guiLabelSetHorizontalAlign(headerText, "center")
	
	readyText = guiCreateLabel( 0, 0.45, 1, 0.25, "Players Ready: 0", true )
	guiSetFont(readyText, "sa-header")
	guiLabelSetColor(readyText, 0, 192, 0)
	guiLabelSetHorizontalAlign(readyText, "center")
	
	specText = guiCreateLabel( 0, 0.85, 1, 0.10, "Spectating: i dont know", true )
	guiSetFont(specText, "sa-header")
	guiLabelSetColor(specText, 0, 192, 0)
	guiLabelSetHorizontalAlign(specText, "center")
	
	addEventHandler("onClientGUIClick", readyButton, readyGUI, false)
	
	guiSetVisible(specText, false)
	guiSetVisible(readyText, false)
	guiSetVisible(headerText, false)
	guiSetVisible(readyButton, false)
end
addEventHandler("onClientResourceStart", resourceRoot, createLobbyGUI)

function readyGUI()
	guiLabelSetColor(headerText, 0, 192, 0)
	guiSetText(headerText, "Ready")
	
	guiSetVisible(readyButton, false)
	showCursor(false)
	
	triggerServerEvent("tgReady", resourceRoot)
end

addEvent("tgPlayersReady", true)
function refreshPReady(readyCount)
	guiSetText(readyText, "Players Ready: " ..readyCount)
	
end
addEventHandler("tgPlayersReady", resourceRoot, refreshPReady)

addEvent("tgLobbyGuiHide", true)
function hideLobbyGUI()
	guiSetVisible(readyText, false)
	guiSetVisible(headerText, false)
	guiSetVisible(readyButton, false)
	showCursor(false)
end
addEventHandler("tgLobbyGuiHide", resourceRoot, hideLobbyGUI)

addEvent("tgLobbyGui", true)
function showLobbyGUI()
	guiLabelSetColor(headerText, 192, 0, 0)
	guiSetText(headerText, "Not Ready")
	
	guiSetVisible(specText, false)
	guiSetVisible(readyText, true)
	guiSetVisible(headerText, true)
	guiSetVisible(readyButton, true)
	showCursor(true)
end
addEventHandler("tgLobbyGui", resourceRoot, showLobbyGUI)

addEvent("tgSync", true)
function syncYourself(hour, minute)
	setTime(hour, minute)
end
addEventHandler("tgSync", resourceRoot, syncYourself)

-- Spectator Mode

spec_Players = false
currentSpec = 1

function specNext()
	if (currentSpec == #spec_Players) then
		currentSpec = 1
	else
		currentSpec = currentSpec + 1
	end
	
	if (isPedDead(spec_Players[currentSpec]) == true) or (spec_Players[currentSpec] == localPlayer) then
		specNext()
	else
		local specName = getPlayerName(spec_Players[currentSpec])
		guiSetText(specText, "Spectating: " ..specName)
		setCameraTarget(spec_Players[currentSpec])
	end
end

function specPrev()
	if (currentSpec == 1) then
		currentSpec = #spec_Players
	else
		currentSpec = currentSpec - 1
	end
	
	if (isPedDead(spec_Players[currentSpec]) == true) or (spec_Players[currentSpec] == localPlayer) then
		specPrev()
	else
		local specName = getPlayerName(spec_Players[currentSpec])
		guiSetText(specText, "Spectating: " ..specName)
		setCameraTarget(spec_Players[currentSpec])
	end
end

addEvent("tgSpectate", true)
function startSpectating()
	spec_Players = getElementsByType("player")
	currentSpec = 1
	
	setPlayerHudComponentVisible(player, "all", false)
	guiSetVisible(specText, true)
	
	bindKey("mouse1", "down", specNext)
	bindKey("mouse2", "down", specPrev)
	
	if (isPedDead(spec_Players[currentSpec]) == true) or (spec_Players[currentSpec] == localPlayer) then
		specNext()
	else
		local specName = getPlayerName(spec_Players[currentSpec])
		guiSetText(specText, "Spectating: " ..specName)
		setCameraTarget(spec_Players[currentSpec])
	end
end
addEventHandler("tgSpectate", resourceRoot, startSpectating)

addEvent("tgSpectateOff", true)
function stopSpectating()
	guiSetVisible(specText, false)
	
	unbindKey("mouse1", "down", specNext)
	unbindKey("mouse2", "down", specPrev)
end
addEventHandler("tgSpectateOff", resourceRoot, stopSpectating)
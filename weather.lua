-- Данный модуль отслеживает изменения погоды, касающихся моровых бурь, и вызывает уведомления из config

local config = require("BlightStormInfection.config")

local wasBlight = false -- Храним состояние: была ли буря в прошлый раз, когда мы проверяли

-- Функция для проверки состояния и вывода сообщения
local function blightNotification(event)
    if not config.showWeatherNotifications then return end

	--weatherTransitionStarted only
	if (event.eventType == "weatherTransitionStarted") then
		local nextBlight = (event.to.index == tes3.weather.blight)
		
		if not wasBlight and nextBlight then -- Погода меняется на бурю
			tes3.messageBox(config.blightStormStartNotificationText)
			return
		end
	end

	local isBlight = (tes3.getCurrentWeather().index == tes3.weather.blight)

	if wasBlight and not isBlight then -- Погода сменилась с бури на что-то другое
		tes3.messageBox(config.blightStormEndNotificationText)
		wasBlight = false		
		return
	end
	
	--weatherTransitionFinished only
	if (event.eventType == "weatherTransitionFinished") then
		if not wasBlight and isBlight then -- Погода сменилась на бурю
			wasBlight = true
			return
		end
	end
	
	--cellChanged only
	if (event.eventType == "cellChanged") then
		if not wasBlight and isBlight then -- В новой ячейке появилась буря
			tes3.messageBox(config.blightStormStartNotificationText)
			wasBlight = true
			return
		end
	end
end

-- 1. При смене погоды
local function onWeatherTransition(event)
	blightNotification(event)
end
event.register(tes3.event.weatherTransitionStarted, onWeatherTransition)
event.register(tes3.event.weatherTransitionFinished, onWeatherTransition)

-- 2. При смене ячейки: загрузка сохранения, телепортация, переход между локациями
local function onCellChanged(event)
    blightNotification(event)
end
event.register(tes3.event.cellChanged, onCellChanged)

-- 3. При каждой загрузке сохранения - обнуляем состояние прошлой бури
local function onLoaded(event)
	wasBlight = false
end
event.register(tes3.event.load, onLoaded)
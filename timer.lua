local config = require("BlightStormInfection.config")
local blight = require("BlightStormInfection.blight")
require("BlightStormInfection.mcm")

local infectionTimer = nil

-- Функция для (пере)запуска таймера
local function startInfectionTimer()
    -- Если таймер уже запущен, останавливаем его
    if infectionTimer then
        infectionTimer:cancel()
		infectionTimer = nil
    end

    -- Запускаем новый таймер с актуальным значением из конфига
    infectionTimer = timer.start({
        duration = config.base.duration,
        iterations = -1, -- бесконечно
        callback = blight.checkBlightInfection
    })
end

-- При загрузке сохранения запускаем таймер
event.register("loaded", startInfectionTimer)

-- Обновляем таймер по запросу из MCM после сохранения настроек
event.register("BlightStormInfection:UpdateTimer", startInfectionTimer)
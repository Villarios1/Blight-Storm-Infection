local config = require("BlightStormInfection.config")
-- Включаем модуль оповещения о погоде, если он есть
local isWeatherModuleAvailable, weatherModule = pcall(require, "BlightStormInfection.weather")

local function registerModConfig()
    local template = mwse.mcm.createTemplate("Blight Storm Infection")

	-- При закрытии сохраняем файл JSON и кидаем сигнал чтобы timer.lua обновил таймер
    template.onClose = function()
		mwse.saveConfig("BlightStormInfection", config)
        event.trigger("BlightStormInfection:UpdateTimer")
    end

    local basePage = template:createSideBarPage({ label = "Базовые настройки" })
    local baseCategory = basePage:createCategory("Параметры")

    -- 1. Базовый шанс
    baseCategory:createSlider({
        label = "Базовый шанс заражения (0-100%)",
		description = "Базовый шанс заражения персонажа моровой болезнью во время нахождения в моровой буре.",
        min = 0,
        max = 100,
        step = 1,
        jump = 5,
        variable = mwse.mcm.createTableVariable{ id = "baseChance", table = config.base }
    })

    -- 2. Множитель шлема
    baseCategory:createSlider({
        label = "Множитель закрытого шлема",
        description = "Шанс будет умножен на это значение, если надет закрытый шлем (полностью заменяющий часть тела head). Множитель 1.00 - шанс заражения остается базовый.",
		min = 0,
        max = 1,
        step = 0.01,
        jump = 0.05, -- Кнопки будут менять значение на 0.05 при зажатом Shift или по клику
        decimalPlaces = 2,
        variable = mwse.mcm.createTableVariable{ id = "helmetMultiplier", table = config.base }
    })

	-- 3. Интервал проверки
    baseCategory:createSlider({
        label = "Интервал проверки в секундах",
        description = "Как часто скрипт проверяет шанс заражения.",
        min = 1,
        max = 120,
        step = 1,
        jump = 5,
        variable = mwse.mcm.createTableVariable{ id = "duration", table = config.base }
    })

	-- 4. Включение/выключение попыток заражения
    baseCategory:createOnOffButton({
        label = "Отображение попыток заражения",
        description = "Отображать шанс и результат проверки на заражение при каждой попытке заразить персонажа.",
        variable = mwse.mcm.createTableVariable{ id = "displayInfectionAttempts", table = config.base }
    })

	-- 5. Кнопка сброса настроек
	baseCategory:createButton({
        label = "Восстановить базовые настройки по умолчанию",
        buttonText = "Сбросить",
		description = "Чтобы увидеть изменения потребуется перезапустить это меню.",
        callback = function()
            for key, value in pairs(config.defaultConfig.base) do
                config.base[key] = value
            end
            tes3.messageBox("Настройки сброшены. Перезапустите это меню для отображения изменений.")
        end
    })

    local weatherPage = template:createSideBarPage({ label = "Настройки погоды" })
    local weatherCategory = weatherPage:createCategory("Параметры")

    -- 1. Оповещения о погоде
    if not isWeatherModuleAvailable then
        weatherCategory:createInfo{
            label = "Модуль погоды не найден",
            description = "Настройки, связанные с оповещениями о погоде недоступны."
        }
    else
        -- 1.1 Включение/выключение оповещений
        weatherCategory:createYesNoButton({
            label = "Включить оповещения о моровой буре",
            description = "Показывать оповещение в нижней части экрана о начале и окончании моровой бури.",
            variable = mwse.mcm.createTableVariable{ id = "showWeatherNotifications", table = config.weather },
            callback = function()
                if config.weather.showWeatherNotifications then
                    weatherModule.enable()
                else
                    weatherModule.disable()
                end
            end
        })

        -- 1.2 Текст оповещения о начале моровой бури
        weatherCategory:createTextField({
            label = "Текст оповещения о начале моровой бури:",
            description = "Введите текст, который будет отображаться при начале моровой бури.",
            variable = mwse.mcm.createTableVariable{ id = "blightStormStartNotificationText", table = config.weather }
        })

	    -- 1.3 Текст оповещения об окончании моровой бури
	    weatherCategory:createTextField({
            label = "Текст завершения бури:",
		    description = "Введите текст, который будет отображаться при завершении моровой бури.",
            variable = mwse.mcm.createTableVariable{ id = "blightStormEndNotificationText", table = config.weather }
        })

        -- 1.4 Кнопка сброса настроек
	    weatherCategory:createButton({
        label = "Восстановить настройки погоды по умолчанию",
        buttonText = "Сбросить",
		description = "Чтобы увидеть изменения потребуется перезапустить это меню.",
        callback = function()
            for key, value in pairs(config.defaultConfig.weather) do
                config.weather[key] = value
            end
            tes3.messageBox("Настройки сброшены. Перезапустите это меню для отображения изменений.")
        end
    })
    end

    mwse.mcm.register(template)
end

event.register("modConfigReady", registerModConfig)
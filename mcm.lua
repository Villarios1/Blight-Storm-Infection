local config = require("BlightStormInfection.config")

local function registerModConfig()
    local template = mwse.mcm.createTemplate("Blight Storm Infection")
	
	-- При закрытии сохраняем файл JSON и кидаем сигнал чтобы main.lua обновил таймер
    template.onClose = function()
		mwse.saveConfig("BlightStormInfection", config)
        event.trigger("BlightStormInfection:UpdateTimer")
    end

    local page = template:createSideBarPage({ label = "Настройки" })
    local category = page:createCategory("Основные параметры")

    -- 1. Базовый шанс
    category:createSlider({
        label = "Базовый шанс заражения (0-100%)",
		description = "Базовый шанс заражения персонажа моровой болезнью во время нахождения в моровой буре.",
        min = 0,
        max = 100,
        step = 1,
        jump = 5,
        variable = mwse.mcm.createTableVariable{ id = "baseChance", table = config }
    })

    -- 2. Множитель шлема
    category:createSlider({
        label = "Множитель закрытого шлема",
        description = "Шанс будет умножен на это значение, если надет закрытый шлем (полностью заменяющий часть тела head).",
		min = 0,
        max = 1,
        step = 0.01,
        jump = 0.05, -- Кнопки будут менять значение на 0.05 при зажатом Shift или по клику
        decimalPlaces = 2,
        variable = mwse.mcm.createTableVariable{ id = "helmetMultiplier", table = config }
    })

	-- 3. Интервал проверки
    category:createSlider({
        label = "Интервал проверки в секундах",
        description = "Как часто скрипт проверяет шанс заражения.",
        min = 1,
        max = 180,
        step = 1,
        jump = 5,
        variable = mwse.mcm.createTableVariable{ id = "duration", table = config }
    })
	
	-- 4. Включение/выключение оповещений
    category:createYesNoButton({
        label = "Включить оповещения о буре",
        description = "Показывать оповещение в нижней части экрана о начале и окончании моровой бури.",
        variable = mwse.mcm.createTableVariable{ id = "showWeatherNotifications", table = config }
    })

    -- 5. Текст оповещения о начале моровой бури
    category:createTextField({
        label = "Текст оповещения о начале моровой бури:",
        description = "Введите текст, который будет отображаться при начале моровой бури.",
        variable = mwse.mcm.createTableVariable{ id = "blightStormStartNotificationText", table = config }
    })
	
	-- 6. Текст оповещения об окончании моровой бури
	category:createTextField({
        label = "Текст завершения бури:",
		description = "Введите текст, который будет отображаться при завершении моровой бури.",
        variable = mwse.mcm.createTableVariable{ id = "blightStormEndNotificationText", table = config }
    })

	-- 7. Кнопка сброса настроек
	category:createButton({
        label = "Восстановить настройки по умолчанию",
        buttonText = "Сбросить",
		description = "Чтобы увидеть изменения потребуется перезапустить это меню.",
        callback = function()
            -- Циклом перезаписываем значения в текущей таблице config
            for key, value in pairs(config.defaultConfig) do
                config[key] = value
            end
			
            tes3.messageBox("Настройки сброшены. Перезапустите это меню для обновления изменений.")
        end
    })

    mwse.mcm.register(template)
end

event.register("modConfigReady", registerModConfig)
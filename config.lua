local configPath = "BlightStormInfection"

local defaultConfig = {
	baseChance = 10, -- базовый шанс заражения
	helmetMultiplier = 0.5, -- уменьшение базового шанса заражения от ношения закрытого шлема
	duration = 10, -- интервал в секундах между проверками
	showWeatherNotifications = true, -- оповещение о начале моровой бури
	blightStormStartNotificationText = "Воздух наполняется пеплом и заразой. Начинается моровая буря.",
	blightStormEndNotificationText = "Небо проясняется, и дышать становится легче. Моровая буря наконец утихла.",
	displayInfectionAttempts = false -- отображать попытки заражения
}

local config = mwse.loadConfig(configPath, defaultConfig)

-- Ссылка на стандартные настройки (из этого файла) в объекте конфига, чтобы к ним был доступ в MCM
config.defaultConfig = defaultConfig

-- Загрузка существующего конфига JSON, или использование стандартного
return config
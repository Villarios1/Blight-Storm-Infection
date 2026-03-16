local config = require("BlightStormInfection.config")
require("BlightStormInfection.weather")

-- Список ID моровых болезней
local blightDiseases = {
    "ash-chancre",
    "black-heart blight",
    "chanthrax blight",
    "ash woe blight"
}

local function checkBlightInfection()
    local player = tes3.player
	if not player then return end
	
    local mobile = tes3.mobilePlayer
	if not mobile then return end

    -- 1. Проверка: закончен ли мейнквест (Дагот Ур побежден)
    if tes3.getJournalIndex{id = "C3_DestroyDagoth"} >= 50 then return end

    -- 2. Проверка: находится ли игрок на улице
	local cell = tes3.getPlayerCell()
	if not cell or cell.isInterior then return end

	-- 3. Проверка погоды (ID 7 — Blight / Моровая буря)
	local weather = tes3.getCurrentWeather()
	if not (weather and weather.index == 7) then return end

    -- 4. Проверка на иммунитет
    local resist = mobile.resistBlightDisease
    if resist >= 100 then return end

    -- 5. Расчет шанса
    local baseChance = config.baseChance
    local helmetMultiplier = 1.0
	-- Проверка на шлем
	local equippedHelmet = tes3.getEquippedItem({ 
        actor = player, 
        objectType = tes3.objectType.armor, 
        slot = tes3.armorSlot.helmet 
    })
    
	if equippedHelmet then
        local armor = equippedHelmet.object
        -- Проверка на "закрытость". 
        -- Логика: если в шлеме прописана часть тела "Head", он считается закрытым.
        if armor.parts then
            for _, part in ipairs(armor.parts) do
                if part.type == tes3.activeBodyPart.head then 
                    helmetMultiplier = config.helmetMultiplier
                    break
                end
            end
        end
    end
    
    -- Расчет финальных значений 
    local finalChance = baseChance * (1 - (resist / 100)) * helmetMultiplier
    local roll = math.random() * 100

-- tes3.messageBox("Шанс: %.2f, Ролл: %d", finalChance, roll)

    if roll <= finalChance then
        -- 6. Если попали в шанс, выбираем одну из болезней
   
        -- собираем список болезней, которыми игрок еще не болен
        local availableDiseases = {}

		for _, id in ipairs(blightDiseases) do
			if not tes3.hasSpell({ reference = player, spell = id }) then
				table.insert(availableDiseases, id)
			end
		end

        -- если есть болезни, которыми игрок еще не заражен
        if #availableDiseases > 0 then
            local diseaseID = availableDiseases[math.random(#availableDiseases)]
			local diseaseObj = tes3.getObject(diseaseID)

            if diseaseObj then
                -- Применение болезни
                tes3.addSpell({ reference = player, spell = diseaseObj })
			
				tes3.messageBox(
				"Вы заразились моровой болезнью: %s",
				diseaseObj.name
				)
			end
        end
    end
end

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
        duration = config.duration,
        iterations = -1,
        callback = checkBlightInfection
    })
end

-- Событие при загрузке сохранения
event.register("loaded", startInfectionTimer)

-- Событие обновления из MCM
event.register("BlightStormInfection:UpdateTimer", startInfectionTimer)

-- Загружаем MCM в самом конце, когда все функции уже определены
require("BlightStormInfection.mcm")
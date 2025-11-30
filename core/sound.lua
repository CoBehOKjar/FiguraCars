local Sound = {}

-- Инициализация звуков (вызывается при старте)
function Sound.init()
    -- Здесь можно загрузить или подготовить звуки в будущем
end

-- Основной цикл обновления звуков (вызывается в tick)
function Sound.update(pos, isAccelerating, rpm)
    -- ЗАГЛУШКА: Логика изменения питча и громкости двигателя удалена
end

-- Воспроизведение звука переключения передачи / выстрела выхлопа
function Sound.playBackfire(pos)
    -- ЗАГЛУШКА: Звук прострела
end

-- Звук переключения вниз
function Sound.playDownshift(pos)
    -- ЗАГЛУШКА: Звук перегазовки
end

return Sound
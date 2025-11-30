local ActionWheel = {}

function ActionWheel.init()
    -- Создаем новую страницу
    local actionPage = action_wheel:newPage()
    action_wheel:setPage(actionPage)
    
    -- Место для добавления действий в будущем
    -- Например: actionPage:newAction():title("Reset")...
end

return ActionWheel
-- babyDebug
--  babyjeans
-- 
--  logging / asserting
---
local babyDebug = class('babyDebug')

function babyDebug:err(systemName, errorMsg)
    print(systemName .. ' - ' .. errorMsg)
end

function babyDebug:log(systemName, log)
    print(systemName .. ' - ' .. log)
end

function babyDebug:warn(systemName, warning)
    print(systemName .. ' - ' .. warning)
end

function babyDebug:assert(condition, systemname, errorMsg)
    if condition then
        return true
    end

    babyDebug:err(systemname, errorMsg)
end

return babyDebug()
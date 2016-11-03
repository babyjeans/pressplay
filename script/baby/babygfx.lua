-- babygfx
--  babyjeans
--
---
local babyGfx = class('babyGfx')

function babyGfx:setColor(r, g, b, a)
    if type(r) == 'table' then
        if r.r ~= nil then
            g=r.g
            b=r.b
            a=r.a or 255
            r=r.r
        elseif #r >= 3 then
            g=r[2]
            b=r[3]
            a=r[4] or 255
            r=r[1]
        else
            babyDebug:err('babyGfx:setColor', 'bad params: expect r,g,b,a or \
                                               { r=r,g=g,b=b,a=a } or { r,g,b,a }');
        end

    end

    --
    love.graphics.setColor(r, g, b, a)
end

function babyGfx:pushBlendMode(newBlendMode)
    if not babyDebug:assert(type(newBlendMode) == "string", "babyGfx:pushBlendMode", "expected blendModeName") then
        return
    end
        
    self.blendStack = self.blendStack or { }
    local blendMode = love.graphics.getBlendMode() or 'alphamultiplied'
   
    --
    love.graphics.setBlendMode('alpha', 'alphamultiply')
end

function babyGfx:popBlendMode()
    local num = #self.blendStack
    if num == 0 then
        return
    end

    local blendMode = self.blendStack[num]
    self.blendStack[num] = nil
    
    --
    love.graphics.setBlendMode('alpha', blendMode)
end

return babyGfx()
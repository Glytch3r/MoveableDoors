MoveableDoors = MoveableDoors or {}

MoveableDoors.str = ''

function MoveableDoors.getPointer()
    local pl = getPlayer()
    if not pl then return nil end
    local zPos = pl:getZ()
    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), zPos)
    return getCell():getGridSquare(math.floor(xx), math.floor(yy), zPos)
end

function MoveableDoors.isHaveKey(KeyId)
    return KeyId and getPlayer():getInventory():haveThisKeyId(KeyId) or false
end

function MoveableDoors.getDoor(sq)
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        if obj and (instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor())) then
            return obj
        end
    end
    return nil
end



function MoveableDoors.init()
    function MoveableDoors.draw()
        if SandboxVars.MoveableDoors.debug or MoveableDoors.active then
            if not  isAdmin() then return end

            local pl = getPlayer()
            if not pl then return end

            local xPos = (getCore():getScreenWidth() / 2) - 900
            local yPos = (getCore():getScreenHeight() / 2 - 20) - 225

            local sq = MoveableDoors.getPointer()
            if not sq then return end

            local obj =  MoveableDoors.getDoor(sq)

            if obj then
                local props = obj:getProperties()
                local md = obj:getModData()
                local isGarageDoor = false
                local isDoubleDoor = false
                local partsCount = 0

                if props then
                    isGarageDoor = props:Is("GarageDoor")
                    isDoubleDoor = props:Is("DoubleDoor")
                end

                local keyId = obj:getKeyId()
                local playerHasKey = MoveableDoors.isHaveKey(keyId)
                local isLocked = obj:isLocked()
                local isOpen = obj:IsOpen()
                local barricadeCount = obj:getBarricadeForCharacter(pl) and obj:getBarricadeForCharacter(pl):getNumPlanks() or 0

                if isGarageDoor then
                    partsCount = #buildUtil.getGarageDoorObjects(obj)
                elseif isDoubleDoor then
                    partsCount = #buildUtil.getDoubleDoorObjects(obj)
                end

                MoveableDoors.str = string.format(
                "Sprite: %s\nGarageDoor: %s\nDoubleDoor: %s\n\nKeyId: %s\nPlayerHasKey: %s\n\nIsLocked: %s\nIsOpen: %s\n\nBarricades: %d\nPartsCount: %d",
                    obj:getSprite() and obj:getSprite():getName() or "N/A",
                    tostring(isGarageDoor), tostring(isDoubleDoor),
                    tostring(keyId or "N/A"), tostring(playerHasKey),
                    tostring(isLocked), tostring(isOpen),
                    barricadeCount, partsCount
                )
                obj:setHighlighted(true, true)
            else
                MoveableDoors.str = ""
            end

            getTextManager():DrawStringCentre(UIFont.Medium, xPos, yPos + 120, MoveableDoors.str, 1, 1, 1, 1)
        end
    end
    Events.OnPostUIDraw.Remove(MoveableDoors.draw)
    Events.OnPostUIDraw.Add(MoveableDoors.draw)
end

Events.OnCreatePlayer.Add(function()
    MoveableDoors.active = false
    MoveableDoors.init()
end)

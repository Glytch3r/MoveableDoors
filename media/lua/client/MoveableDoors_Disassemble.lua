ISWorldMenuElements = ISWorldMenuElements or {}
local hook = ISWorldMenuElements.ContextDisassemble

function ISWorldMenuElements.ContextDisassemble()
    local self = ISMenuElement.new()

    function self.init()
    end

    function self.createMenu(_data)
        local validObjList = {}

        if getCore():getGameMode() == "Tutorial" then return end
        if _data.test then return true end

        for _, object in ipairs(_data.objects) do
            local square = object:getSquare()
            if square then
                local isDoor = instanceof(object, "IsoDoor") or (instanceof(object, "IsoThumpable") and object:isDoor())
                local props = object:getProperties()
                local isGarageDoor = isDoor and props and props:Is("GarageDoor")
                local isDoubleDoor = isDoor and props and props:Is("DoubleDoor")

                if isGarageDoor or isDoubleDoor then
                    table.insert(validObjList, { object = object, square = square, isGarageDoor = isGarageDoor, isDoubleDoor = isDoubleDoor })
                end
            end
        end

        if #validObjList == 0 then return end

        local disassembleMenu = _data.context:addOption(getText("ContextDisassemble_Objects"), _data.player, nil)
        local subMenu = _data.context:getNew(_data.context)
        _data.context:addSubMenu(disassembleMenu, subMenu)

        for _, v in ipairs(validObjList) do
            local caption = v.isGarageDoor and getText("ContextDisassemble_GarageDoor") or getText("ContextDisassemble_DoubleDoor")
            local option = subMenu:addOption(caption, _data, self.disassembleDoor, v)
            option.notAvailable = false
        end
    end

    function self.disassembleDoor(_data, v)
        if _data.player:isPerformingAnAction() then return end
        ISTimedActionQueue.add(ISDisassembleDoor:new(_data.player, v.square, v.object))
    end

    return hook(self)
end

ISDisassembleDoor = ISBaseTimedAction:derive("ISDisassembleDoor")

function ISDisassembleDoor:isValid()
    return self.square and self.object and self.square:getObjects():contains(self.object)
end

function ISDisassembleDoor:start()
    self:setActionAnim("Loot")
    self.sound = self.character:playSound("DismantleDoor")
end

function ISDisassembleDoor:stop()
    ISBaseTimedAction.stop(self)
    self.character:stopOrTriggerSound(self.sound)
end

function ISDisassembleDoor:perform()
    self.character:stopOrTriggerSound(self.sound)
    self.object:getSquare():transmitRemoveItemFromSquare(self.object)
    ISBaseTimedAction.perform(self)
end

function ISDisassembleDoor:new(character, square, object)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.square = square
    o.object = object
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = isClient() and 100 or 200
    return o
end

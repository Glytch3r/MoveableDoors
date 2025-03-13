require "TimedActions/ISBaseTimedAction"

ISMoveableDoorsAction = ISBaseTimedAction:derive("ISMoveableDoorsAction")

local function predicateNotBroken(item)
    return not item:isBroken()
end

function ISMoveableDoorsAction:isValid()
    self.spr = self.door:getSprite()
    self.sprName = self.spr:getName()
    self.props = self.spr:getProperties()
    return true

--[[
    self.isGarageDoor = props:Is("GarageDoor")
    self.isDoubleDoor = props:Is("DoubleDoor")
    local diffX = math.abs(self.door:getSquare():getX() + 0.5 - self.character:getX())
    local diffY = math.abs(self.door:getSquare():getY() + 0.5 - self.character:getY())

print("Valid check failed: GarageDoor:", self.isGarageDoor, "DoubleDoor:", self.isDoubleDoor,
      "Has Crowbar:", self.character:getInventory():containsTagEval("Crowbar", predicateNotBroken),
      "Has Screwdriver:", self.character:getInventory():containsTagEval("Screwdriver", predicateNotBroken),
      "Door exists:", self.door:getObjectIndex() ~= -1)

    return instanceof(self.door, "IsoDoor") and (self.isGarageDoor or self.isDoubleDoor) and
           self.character:getInventory():containsTagEval("Crowbar", predicateNotBroken) and
           self.character:getInventory():containsTagEval("Screwdriver", predicateNotBroken) and
           self.door:getObjectIndex() ~= -1 and
           (diffX <= 1.6 and diffY <= 1.6)
            ]]
end

function ISMoveableDoorsAction:waitToStart()
    self.character:faceThisObject(self.door)
    return self.character:shouldBeTurning()
end

--[[ function ISMoveableDoorsAction:update()
    self.character:PlayAnim("Idle")
    self.character:faceThisObject(self.door)
    self.character:setMetabolicTarget(Metabolics.UsingTools)
end ]]

function ISMoveableDoorsAction:start()
    self:setActionAnim("Loot")
    --self.character:SetVariable("LootPosition", "Low")
    --self:setOverrideHandModels("Crowbar", nil)
end

function ISMoveableDoorsAction:stop()
    ISBaseTimedAction.stop(self)
end
function ISMoveableDoorsAction:perform()
    print(self:doRoll())
    --[[
    if not self:doRoll() then
        self.character:Say(getText("IGUI_MoveableDoors_Fail"))
        ISBaseTimedAction.perform(self)
        return
    end
    local KeyId = ZombRand(100000000)
    local keyItem = self.character:getSquare():AddWorldInventoryItem("Base.Key1", 0.0, 0.0, 0.0)
    keyItem:setKeyId(KeyId);

    local doors = nil
    local toSpawn = nil
    if self.isGarageDoor then
        toSpawn = "Base.GarageDoorPackage"
        doors = buildUtil.garageDoorObjects(self.door)
    elseif self.isDoubleDoor then
        toSpawn = "Base.DoubleDoorPackage"
        doors = buildUtil.getDoubleDoorObjects(self.door)
    end
    if doors and toSpawn then
        for i=1, #doors do
            local obj = doors[i-1]
            local spr = obj:getSprite()
            if spr then
                local sprName = spr:getSpriteName()
                local doorItem = InventoryItemFactory.CreateItem(toSpawn)
                if sprName then
                    doorItem:getModData()['PackedSpr'] = sprName
                    doorItem:getModData()['KeyId'] = KeyId
                    self.character:getInventory():AddItem(doorItem)
                    if isClient() then
                        sledgeDestroy(obj)
                    else
                        obj:getSquare():transmitRemoveItemFromSquare(obj)
                    end
                    self.door:getSquare():AddWorldInventoryItem(doorItem, 0.0, 0.0, 0.0)
                end
            end
        end
    end ]]

--[[     for k, v in pairs(self.door:getModData()) do
        if luautils.stringStarts(k, "need:") then
            local type = luautils.split(k, ":")[2]
            local count = ZombRand(tonumber(v)) + 1
            for i = 1, count do
                self.door:getSquare():AddWorldInventoryItem(type, 0, 0, 0)
            end
        end
    end ]]

    ISInventoryPage.dirtyUI()
    ISBaseTimedAction.perform(self)
end

function ISMoveableDoorsAction:doRoll()
    local SuccessRate = SandboxVars.MoveableDoors.SuccessRate or 15
    local boost = SandboxVars.MoveableDoors.SuccessRateBonus or 3
    local roll = math.max(0, math.min(100, SuccessRate + (boost * self.LevelMult)))
    if roll >= 100 then return true end
    if roll <= 0 then return false end
    return roll >= ZombRand(1, 101)
end

function ISMoveableDoorsAction:new(character, door)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.door = door
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = MoveableDoors.getMaxTime()
	--if ISBuildMenu.cheat or character:isTimedActionInstant() then o.maxTime = 1 end
    o.caloriesModifier = 2
    return o
end

function MoveableDoors.getMaxTime()
    local pl = getPlayer()
    local WoodworkLevel = pl:getPerkLevel(Perks.Woodwork)
    local MetalWeldingLevel = pl:getPerkLevel(Perks.MetalWelding)

    local requiredLevel1 = SandboxVars.MoveableDoors.WoodworkReqXP or 5
    local requiredLevel2 = SandboxVars.MoveableDoors.MetalWeldingReqXP or 3
    local dur            = SandboxVars.MoveableDoors.DismantleDuration or 200

    local LevelMult = (math.max(0, WoodworkLevel - requiredLevel1)) + (math.max(0, MetalWeldingLevel - requiredLevel2))
	local TimeReductionBonus = SandboxVars.MoveableDoors.TimeReductionBonus or 3
    dur = dur - (TimeReductionBonus * LevelMult)
	return  dur
end



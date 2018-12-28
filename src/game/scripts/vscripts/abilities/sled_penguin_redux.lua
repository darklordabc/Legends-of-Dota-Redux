
-- Lua Library Imports
LinkLuaModifier("modifier_sled_penguin_passive_redux","abilities/modifiers/modifier_sled_penguin_passive_redux.lua",LUA_MODIFIER_MOTION_NONE);
sled_penguin_redux = sled_penguin_redux or {}
sled_penguin_redux.__index = sled_penguin_redux
function sled_penguin_redux.new(construct, ...)
    local self = setmetatable({}, sled_penguin_redux)
    if construct and sled_penguin_redux.constructor then sled_penguin_redux.constructor(self, ...) end
    return self
end
function sled_penguin_redux.constructor(self)
end
function sled_penguin_redux.OnToggle(self)
    local caster = self:GetCaster();
    if self:GetToggleState() then
        self.modifier = caster:AddNewModifier(caster,self,"modifier_sled_penguin_passive_redux",{});
    else
        self.modifier:Destroy();
        local talentValue = 0;
        local talent = caster:FindAbilityByName("special_bonus_unique_sled_penguin_1");
        if talent then
            talentValue = talent:GetSpecialValueFor("value");
        end
        if talentValue==0 then
            self:StartCooldown(self:GetSpecialValueFor("cooldown")*(1+caster:GetCooldownReduction()));
        end
    end
end
function sled_penguin_redux.GetBehavior(self)
    local value = (DOTA_ABILITY_BEHAVIOR_TOGGLE+DOTA_ABILITY_BEHAVIOR_NO_TARGET)+DOTA_ABILITY_BEHAVIOR_IMMEDIATE;
    if self:GetCaster():HasModifier("modifier_sled_penguin_passive_redux") then
        value = (value+DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE);
    end
    return value
end
function sled_penguin_redux.GetCooldown(self,level)
    if IsClient() then
        return self:GetSpecialValueFor("cooldown")
    end
end

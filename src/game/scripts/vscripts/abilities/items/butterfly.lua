
-- Lua Library Imports
require("abilities/items/consumable_baseclass");
LinkLuaModifier("modifier_item_butterfly_consumable","abilities/items/butterfly.lua",LUA_MODIFIER_MOTION_NONE);
item_butterfly_consumable = item_butterfly_consumable or item_consumable_redux.new()
item_butterfly_consumable.__index = item_butterfly_consumable
item_butterfly_consumable.__base = item_consumable_redux
function item_butterfly_consumable.new(construct, ...)
    local self = setmetatable({}, item_butterfly_consumable)
    if construct and item_butterfly_consumable.constructor then item_butterfly_consumable.constructor(self, ...) end
    return self
end
function item_butterfly_consumable.constructor(self)
end
function item_butterfly_consumable.GetIntrinsicModifierName(self)
    return "modifier_item_butterfly_consumable"
end
modifier_item_butterfly_consumable = modifier_item_butterfly_consumable or {}
modifier_item_butterfly_consumable.__index = modifier_item_butterfly_consumable
function modifier_item_butterfly_consumable.new(construct, ...)
    local self = setmetatable({}, modifier_item_butterfly_consumable)
    if construct and modifier_item_butterfly_consumable.constructor then modifier_item_butterfly_consumable.constructor(self, ...) end
    return self
end
function modifier_item_butterfly_consumable.constructor(self)
end
function modifier_item_butterfly_consumable.IsHidden(self)
    if (not self:GetAbility()) then
        return false
    end
    return self:GetAbility():GetName()~="ability_consumable_item_container"
end
function modifier_item_butterfly_consumable.IsPermanent(self)
    return true
end
function modifier_item_butterfly_consumable.GetTexture(self)
    return "item_butterfly"
end
function modifier_item_butterfly_consumable.IsDebuff(self)
    return false
end
function modifier_item_butterfly_consumable.GetAttributes(self)
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_butterfly_consumable.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_EVASION_CONSTANT}
end
function modifier_item_butterfly_consumable.GetModifierBonusStats_Agility(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("butterfly_bonus_agility")
end
function modifier_item_butterfly_consumable.GetModifierAttackSpeedBonus_Constant(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("butterfly_bonus_attack_speed")
end
function modifier_item_butterfly_consumable.GetModifierEvasion_Constant(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("butterfly_bonus_evasion")
end
function modifier_item_butterfly_consumable.GetModifierPreAttack_BonusDamage(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("butterfly_bonus_damage")
end


-- Lua Library Imports
LinkLuaModifier("modifier_item_sange_kaya_yasha","abilities/items/sange_kaya_yasha.lua",LUA_MODIFIER_MOTION_NONE);
LinkLuaModifier("modifier_item_sange_kaya_yasha_buffs","abilities/items/sange_kaya_yasha.lua",LUA_MODIFIER_MOTION_NONE);
item_sange_kaya_yasha_consumable = item_sange_kaya_yasha_consumable or item_consumable_redux.new()
item_sange_kaya_yasha_consumable.__index = item_sange_kaya_yasha_consumable
item_sange_kaya_yasha_consumable.__base = item_consumable_redux
function item_sange_kaya_yasha_consumable.new(construct, ...)
    local self = setmetatable({}, item_sange_kaya_yasha_consumable)
    if construct and item_sange_kaya_yasha_consumable.constructor then item_sange_kaya_yasha_consumable.constructor(self, ...) end
    return self
end
function item_sange_kaya_yasha_consumable.constructor(self)
end
function item_sange_kaya_yasha_consumable.GetIntrinsicModifierName(self)
    return "modifier_item_sange_kaya_yasha"
end
modifier_item_sange_kaya_yasha_consumable = modifier_item_sange_kaya_yasha_consumable or {}
modifier_item_sange_kaya_yasha_consumable.__index = modifier_item_sange_kaya_yasha_consumable
function modifier_item_sange_kaya_yasha_consumable.new(construct, ...)
    local self = setmetatable({}, modifier_item_sange_kaya_yasha_consumable)
    if construct and modifier_item_sange_kaya_yasha_consumable.constructor then modifier_item_sange_kaya_yasha_consumable.constructor(self, ...) end
    return self
end
function modifier_item_sange_kaya_yasha_consumable.constructor(self)
end
function modifier_item_sange_kaya_yasha_consumable.IsHidden(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return false
    end
    return self:GetAbility().IsItem==nil
end
function modifier_item_sange_kaya_yasha_consumable.IsPermanent(self)
    return true
end
function modifier_item_sange_kaya_yasha_consumable.GetTexture(self)
    return "item_sange_kaya_yasha"
end
function modifier_item_sange_kaya_yasha_consumable.GetAttributes(self)
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_sange_kaya_yasha_consumable.OnCreated(self)
    if IsServer() then
        self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_sange_kaya_yasha_buffs",{});
    end
end
function modifier_item_sange_kaya_yasha_consumable.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end
function modifier_item_sange_kaya_yasha_consumable.GetModifierBonusStats_Intellect(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_bonus_intellect")
end
function modifier_item_sange_kaya_yasha_consumable.GetModifierBonusStats_Agility(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_bonus_agility")
end
function modifier_item_sange_kaya_yasha_consumable.GetModifierBonusStats_Strength(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_bonus_strength")
end
function modifier_item_sange_kaya_yasha_consumable.GetModifierPreAttack_BonusDamage(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_bonus_damage")
end
function modifier_item_sange_kaya_yasha_consumable.GetModifierAttackSpeedBonus_Constant(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_bonus_attack_speed")
end
modifier_item_sange_kaya_yasha_consumable_buffs = modifier_item_sange_kaya_yasha_consumable_buffs or {}
modifier_item_sange_kaya_yasha_consumable_buffs.__index = modifier_item_sange_kaya_yasha_consumable_buffs
function modifier_item_sange_kaya_yasha_consumable_buffs.new(construct, ...)
    local self = setmetatable({}, modifier_item_sange_kaya_yasha_consumable_buffs)
    if construct and modifier_item_sange_kaya_yasha_consumable_buffs.constructor then modifier_item_sange_kaya_yasha_consumable_buffs.constructor(self, ...) end
    return self
end
function modifier_item_sange_kaya_yasha_consumable_buffs.constructor(self)
end
function modifier_item_sange_kaya_yasha_consumable_buffs.IsPermanent(self)
    return true
end
function modifier_item_sange_kaya_yasha_consumable_buffs.IsHidden(self)
    return true
end
function modifier_item_sange_kaya_yasha_consumable_buffs.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
end
function modifier_item_sange_kaya_yasha_consumable_buffs.GetModifierStatusResistanceStacking(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_status_resistance")
end
function modifier_item_sange_kaya_yasha_consumable_buffs.GetModifierMoveSpeedBonus_Percentage(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_movement_speed_percent_bonus")
end
function modifier_item_sange_kaya_yasha_consumable_buffs.GetModifierSpellAmplify_Percentage(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_spell_amp")
end
function modifier_item_sange_kaya_yasha_consumable_buffs.GetModifierPercentageManacostStacking(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("sange_kaya_yasha_manacost_reduction")
end

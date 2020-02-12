
-- Lua Library Imports
require("abilities/items/consumable_baseclass");
LinkLuaModifier("modifier_item_holy_locket_consumable","abilities/items/holy_locket.lua",LUA_MODIFIER_MOTION_NONE);
item_holy_locket_consumable = item_holy_locket_consumable or item_consumable_redux.new()
item_holy_locket_consumable.__index = item_holy_locket_consumable
item_holy_locket_consumable.__base = item_consumable_redux
function item_holy_locket_consumable.new(construct, ...)
    local self = setmetatable({}, item_holy_locket_consumable)
    if construct and item_holy_locket_consumable.constructor then item_holy_locket_consumable.constructor(self, ...) end
    return self
end
function item_holy_locket_consumable.constructor(self)
end
function item_holy_locket_consumable.GetIntrinsicModifierName(self)
    return "modifier_item_holy_locket_consumable"
end
--function item_holy_locket_consumable:OnSpellStart(self)
--    local caster = self:GetCaster();
--    local stacks = ability:GetCurrentCharges();
--    local to_restore = stacks * self:GetSpecialValueFor("holy_locket_restore_per_charge");
--    caster:Heal(to_restore, self);
--    caster:SpendMana(to_restore, self);
--end
modifier_item_holy_locket_consumable = modifier_item_holy_locket_consumable or {}
modifier_item_holy_locket_consumable.__index = modifier_item_holy_locket_consumable
function modifier_item_holy_locket_consumable.new(construct, ...)
    local self = setmetatable({}, modifier_item_holy_locket_consumable)
    if construct and modifier_item_holy_locket_consumable.constructor then modifier_item_holy_locket_consumable.constructor(self, ...) end
    return self
end
function modifier_item_holy_locket_consumable.constructor(self)
end
function modifier_item_holy_locket_consumable.IsHidden(self)
    if (not self:GetAbility()) then
        return false
    end
    return self:GetAbility():GetName()~="ability_consumable_item_container"
end
function modifier_item_holy_locket_consumable.IsPermanent(self)
    return true
end
function modifier_item_holy_locket_consumable.GetTexture(self)
    return "item_holy_locket"
end
function modifier_item_holy_locket_consumable.IsDebuff(self)
    return false
end
function modifier_item_holy_locket_consumable.GetAttributes(self)
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_holy_locket_consumable.OnCreated(self)
end
function modifier_item_holy_locket_consumable.OnDestroy(self)
end
function modifier_item_holy_locket_consumable.DeclareFunctions(self)
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
end
function modifier_item_holy_locket_consumable.GetModifierHealthBonus(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("holy_locket_bonus_health")
end
function modifier_item_holy_locket_consumable.GetModifierManaBonus(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("holy_locket_bonus_mana")
end
function modifier_item_holy_locket_consumable.GetModifierConstantHealthRegen(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("holy_locket_health_regen")
end
function modifier_item_holy_locket_consumable.GetModifierHPRegenAmplify_Percentage(self)
    if (not self:GetAbility()) then
        self:Destroy();
        return 0
    end
    if IsServer() then
        local count = 0;
        local parent = self:GetParent();
        local i = 0
        while(i<parent:GetModifierCount()) do
            do
                local modifier = parent:GetModifierNameByIndex(i);
                if modifier=="modifier_item_holy_locket_consumable" then
                    count = (count+1);
                end
            end
            ::__continue0::
            i = (i+1)
        end
        if count>1 then
            self:SetStackCount(count);
        end
    end
    if self:GetStackCount()>1 then
        return self:GetAbility():GetSpecialValueFor("holy_locket_heal_increase")/(self:GetStackCount())
    else
        return self:GetAbility():GetSpecialValueFor("holy_locket_heal_increase")
    end
end
--function modifier_item_holy_locket_consumable:OnAbilityFullyCast(keys)
--    if (not self:GetAbility()) then
--        return
--    end
--    local ability = self:GetAbility()
--    local parent = self:GetParent()
--    local caster = keys:GetTeamNumber()
--    if caster ~= self:GetParent() and ((parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= ability:GetSpecialValueFor("holy_locket_charge_radius")) then
--        if ability:GetCurrentCharges() < ability:GetSpecialValueFor("holy_locket_max_charges") then
--            ability:SetCurrentCharges(ability:GetCurrentCharges()+1)
--        end
--    end
--end

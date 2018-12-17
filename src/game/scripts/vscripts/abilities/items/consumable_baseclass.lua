
-- Lua Library Imports
function __TS__Ternary(condition,cb1,cb2)
    if condition then
        return cb1()
    else
        return cb2()
    end
end

item_consumable_redux = item_consumable_redux or class({})
item_consumable_redux.__index = item_consumable_redux
function item_consumable_redux.new(construct, ...)
    return class(item_consumable_redux)
end
function item_consumable_redux.constructor(self)
end
--function item_consumable_redux.GetIntrinsicModifierName(self)
--    return ""
--end
function item_consumable_redux.OnSpellStart(self)
    self:ConsumeItem(self:GetCaster());
end
function item_consumable_redux.CastFilterResultTarget(self,target)
    if self.GetCaster(self)~=target then
        return UF_FAIL_CUSTOM
    end
    if IsServer() then
        local name = self:GetIntrinsicModifierName();
        local ab = nil;
        if (not self:GetCaster():HasAbility("ability_consumable_item_container")) then
            ab = self:GetCaster():AddAbility("ability_consumable_item_container");
            ab:SetLevel(1);
            ab:SetHidden(true);
        end
        ab = __TS__Ternary(ab, function() return ab end, function() return self:GetCaster():FindAbilityByName("ability_consumable_item_container") end);
        if (not ab) or ab[name] then
            return UF_FAIL_CUSTOM
        end
        return UF_SUCCESS
    end
    return UF_SUCCESS
end
function item_consumable_redux.GetCustomCastErrorTarget(self,target)
    if self:GetCaster()~=target then
        return "#consumable_items_only_self"
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container");
    if (not ab) then
        return "#consumable_items_no_available_slot"
    end
    local name = self:GetIntrinsicModifierName();
    if ab[name] then
        return "#consumable_items_already_consumed"
    end
end
function item_consumable_redux.ConsumeItem(self,caster)
    local name = self:GetIntrinsicModifierName();
    if (not self:GetCaster():HasAbility("ability_consumable_item_container")) then
        local ab = self:GetCaster():AddAbility("ability_consumable_item_container");
        ab:SetLevel(1);
        ab:SetHidden(true);
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container");
    if ab and (not ab[name]) then
        caster:RemoveItem(self);
        caster:RemoveModifierByName(name);
        local modifier = caster:AddNewModifier(caster,ab,name,{});
        ab[name] = true;
    end
end

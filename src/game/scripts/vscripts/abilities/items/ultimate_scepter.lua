LinkLuaModifier("modifier_item_ultimate_scepter_dummy","abilities/items/ultimate_scepter.lua",LUA_MODIFIER_MOTION_NONE)
modifier_item_ultimate_scepter_dummy = class({})

function modifier_item_ultimate_scepter_dummy:IsHidden() return true end

function modifier_item_ultimate_scepter_dummy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,

    }
end

function modifier_item_ultimate_scepter_dummy:GetModifierBonusStats_Strength()
    return self.bonus_all_stats
end
function modifier_item_ultimate_scepter_dummy:GetModifierBonusStats_Agility()
    return self.bonus_all_stats
end
function modifier_item_ultimate_scepter_dummy:GetModifierBonusStats_Intellect()
    return self.bonus_all_stats
end
function modifier_item_ultimate_scepter_dummy:GetModifierManaBonus()
    return self.bonus_mana
end
function modifier_item_ultimate_scepter_dummy:GetModifierHealthBonus()
    return self.bonus_health
end

function modifier_item_ultimate_scepter_dummy:OnCreated()

    self.bonus_all_stats = self:GetAbility():GetSpecialValueFor("ultimate_scepter_bonus_all_stats")
    self.bonus_health = self:GetAbility():GetSpecialValueFor("ultimate_scepter_bonus_all_stats")
    self.bonus_mana = self:GetAbility():GetSpecialValueFor("ultimate_scepter_bonus_all_stats")
    if IsServer() then
        self:GetAbility():SetDroppable(false)
        self:GetAbility():SetSellable(false)
        self:GetAbility():SetCanBeUsedOutOfInventory(false)

        self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_item_ultimate_scepter",{})
    end
end

function modifier_item_ultimate_scepter_dummy:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_item_ultimate_scepter")
    end
end


item_ultimate_scepter_consumable = class({})


function item_ultimate_scepter_consumable:GetIntrinsicModifierName()
  return "modifier_item_ultimate_scepter_dummy"
end

function item_ultimate_scepter_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_ultimate_scepter_consumable:CastFilterResultTarget(target)
  -- Check if its the caster thats targetted
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  -- Check if the ability exists/can be given
  if IsServer() then
    if self:GetCaster():FindModifierByName("modifier_item_ultimate_scepter_consumed") then
        return UF_FAIL_CUSTOM
    end
  end
  return UF_SUCCESS
end

function item_ultimate_scepter_consumable:GetCustomCastErrorTarget(target)
  if self:GetCaster() ~= target then
    return "#consumable_items_only_self"
  end
  
  if IsServer() and self:GetCaster():FindModifierByName("modifier_item_ultimate_scepter_consumed") then
    return "#consumable_items_already_consumed"
  end
end



function item_ultimate_scepter_consumable:ConsumeItem(hCaster)
    local t = {
    bonus_all_stats = self:GetSpecialValueFor("ultimate_scepter_bonus_all_stats"),
    bonus_health = self:GetSpecialValueFor("ultimate_scepter_bonus_all_stats"),
    bonus_mana = self:GetSpecialValueFor("ultimate_scepter_bonus_all_stats"),}
    self:GetCaster():AddNewModifier(hCaster,nil,"modifier_item_ultimate_scepter_consumed",t)
    hCaster:RemoveItem(self)

  
    --[[local name = self:GetIntrinsicModifierName()
    -- Learn the ability container if needed
    if not self:GetCaster():HasAbility("ability_consumable_item_container") then
        local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
        ab:SetLevel(1)
        ab:SetHidden(true)
    end
    -- Double check everything works, then remove the item and add the modifier from the container ability
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
    if ab and not ab[name] then
        hCaster:RemoveItem(self)
        hCaster:RemoveModifierByName(name)
        local modifier = hCaster:AddNewModifier(hCaster,ab,name,{})
        ab[name] = true
    end]]
end
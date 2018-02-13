LinkLuaModifier("modifier_item_kaya_consumable", "abilities/items/kaya.lua", LUA_MODIFIER_MOTION_NONE)

item_kaya_consumable = class({})

function item_kaya_consumable:GetIntrinsicModifierName()
  return "modifier_item_kaya_consumable"
end

function item_kaya_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_kaya_consumable:CastFilterResultTarget(target)
  -- Check if its the caster thats targetted
  if self:GetCaster() ~= target then
    return UF_FAIL_CUSTOM
  end
  -- Check if the ability exists/can be given
  if IsServer() then
    local name = self:GetIntrinsicModifierName()
    if not self:GetCaster():HasAbility("ability_consumable_item_container") then
      local ab = self:GetCaster():AddAbility("ability_consumable_item_container")
      ab:SetLevel(1)
      ab:SetHidden(true)
    end
    local ab = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
    if not ab or ab[name] then
      return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
  end
  return UF_SUCCESS
end

function item_kaya_consumable:GetCustomCastErrorTarget(target)
  if self:GetCaster() ~= target then
    return "#consumable_items_only_self"
  end
  local ab  = self:GetCaster():FindAbilityByName("ability_consumable_item_container")
  if not ab then
    return "#consumable_items_no_available_slot"
  end
  local name = self:GetIntrinsicModifierName()
  if ab[name] then
    return "#consumable_items_already_consumed"
  end
end

function item_kaya_consumable:ConsumeItem(hCaster)
  local name = self:GetIntrinsicModifierName()
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
  end
end


modifier_item_kaya_consumable = class({
	IsHidden = function(self)
		if not self:GetAbility() then
			self:Destroy()
			return
		end
		return self:GetAbility().IsItem
	end,
	DeclareFunctions = function() 
		return {
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
			MODIFIER_EVENT_ON_SPENT_MANA,
		}
	end,
	IsPurgable = function() return false end,
	IsPassive = function() return true end,
	RemoveOnDeath = function() return false end,
	GetTexture = function() return "item_kaya" end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	
	GetModifierBonusStats_Intellect = function(self)
		if not self:GetAbility() then
      		self:Destroy()
      		return
    	end
    	return self:GetAbility():GetSpecialValueFor("bonus_intellect_kaya")
    end,
	GetModifierSpellAmplify_Percentage = function(self)
		if not self:GetAbility() then
      		self:Destroy()
      		return
    	end
    	return self:GetAbility():GetSpecialValueFor("spell_amp")
    end,
	GetModifierPercentageManacost = function(self)
		if not self:GetAbility() then
      		self:Destroy()
      		return
    	end
    	return self:GetAbility():GetSpecialValueFor("manacost_reduction")
    end,
	--mana loss reduction eg. mana burn seems to be built into MODIFIER_PROPERTY_MANACOST_PERCENTAGE.
})
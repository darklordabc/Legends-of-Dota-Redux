LinkLuaModifier("modifier_item_aeon_disk_consumable", "abilities/items/aeon_disk.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_aeon_disk_consumable_buff", "abilities/items/aeon_disk.lua", LUA_MODIFIER_MOTION_NONE)

item_aeon_disk_consumable = class({})

function item_aeon_disk_consumable:GetIntrinsicModifierName()
  return "modifier_item_aeon_disk_consumable"
end

function item_aeon_disk_consumable:OnSpellStart()
    self:ConsumeItem(self:GetCaster())
end

function item_aeon_disk_consumable:CastFilterResultTarget(target)
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

function item_aeon_disk_consumable:GetCustomCastErrorTarget(target)
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

function item_aeon_disk_consumable:ConsumeItem(hCaster)
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

modifier_item_aeon_disk_consumable = class({
	IsHidden = function(self)
		if not self:GetAbility() then
			self:Destroy()
			return
		end
		return self:GetAbility().IsItem
	end,
	IsPurgable = function() return false end,
	IsPassive = function() return true end,
	IsPermanent = function() return true end,
	RemoveOnDeath = function() return false end,
	DestroyOnExpire = function() return false end,
	GetTexture = function() return "item_aeon_disk" end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	
	DeclareFunctions = function()
		return {
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
	end,

	GetModifierHealthBonus = function(self)
		if not self:GetAbility() then
	      self:Destroy()
	      return
	    end
		return self:GetAbility():GetSpecialValueFor("aeon_disk_bonus_health")
	end,
	GetModifierManaBonus = function(self)
		if not self:GetAbility() then
	      self:Destroy()
	      return
	    end
	    return self:GetAbility():GetSpecialValueFor("aeon_disk_bonus_mana")
	end,
	

	OnTakeDamage = function(self, keys)
		if not IsServer() or self:GetParent() ~= keys.unit then return end
		if keys.damage <= 0 then return end
		if keys.unit:IsIllusion() then return end
		if self:GetAbility():IsItem() and not self:GetAbility():IsCooldownReady() or not self:GetAbility():IsItem() and self:GetRemainingTime() >= 0 then return end
		if keys.attacker:IsControllableByAnyPlayer() then
			if self:GetParent():GetHealth() <= self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("aeon_disk_health_threshold_pct") * 0.01 then
				self:GetParent():SetHealth(self:GetParent():GetHealth()+keys.damage)
				if self:GetAbility():IsItem() then
					self:GetAbility():UseResources(false, false, true)
				else
					self:SetDuration(90 * (1-self:GetParent():GetCooldownReduction()), true)
				end

				local dir = (self:GetParent():GetAbsOrigin() - keys.attacker:GetAbsOrigin()):Normalized()
				local p = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				local f = ParticleManager:CreateParticle("particles/status_fx/status_effect_combo_breaker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(p, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", dir*50, true)
				ParticleManager:SetParticleControlEnt(p, 4, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", dir*50, true)

				EmitSoundOn("DOTA_Item.ComboBreaker", self:GetParent())

				self:GetParent():Purge(false, true, false, true, false)

				local mod = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_aeon_disk_consumable_buff", {duration = self:GetAbility():GetSpecialValueFor("aeon_disk_buff_duration")})
				if mod then
					mod:AddParticle(p, false, false, 100, true, false)
					mod:AddParticle(f, false, true, 100, false, false)
				end
			end
		end
	end,
})

modifier_item_aeon_disk_consumable_buff = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	GetTexture = function() return "item_aeon_disk" end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE} end,
	GetModifierIncomingDamage_Percentage = function() return -100 end,
	GetModifierTotalDamageOutgoing_Percentage = function() return -100 end,
	GetModifierStatusResistance = function(self) return self:GetAbility():GetSpecialValueFor("aeon_disk_status_resistance")
	end,
})

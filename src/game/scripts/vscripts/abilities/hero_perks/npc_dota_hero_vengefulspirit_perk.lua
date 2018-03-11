--------------------------------------------------------------------------------------------------------
--
--		Hero: Vengeful Spirit
--		Perk: Vengeful Spirit spawns a spirit of vengence on death that lasts until Vengeful Spirit has respawned.
--					this spirit can use all of her abilities but cannot use items
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_vengefulspirit_perk", "abilities/hero_perks/npc_dota_hero_vengefulspirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "modifier_npc_dota_hero_vengefulspirit_perk_debuff", "abilities/hero_perks/npc_dota_hero_vengefulspirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_vengefulspirit_perk ~= "" then npc_dota_hero_vengefulspirit_perk = class({}) end

modifier_npc_dota_hero_vengefulspirit_perk = {
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	IsPassive = function() return true end,
	IsPermanent = function() return true end,
	RemoveOnDeath = function() return false end,
	DeclareFunctions = function() return {} end,

	OnCreated = function(self, kv)
		if not IsServer() then return end
		self:StartIntervalThink(0.1)
	end,

	OnIntervalThink = function(self)
		if not IsServer() then return end
		if not self:GetParent():IsAlive() then
			if not self.illusion then
				self.illusion = true
				CreateUnitByNameAsync(self:GetParent():GetUnitName(), self:GetParent():GetAbsOrigin()+RandomVector(108), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber(), function(unit)
					self.illusion = unit
					unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_vengefulspirit_hybrid_special", {})
					unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_illusion", {
						outgoing_damage = 100,
    					incoming_damage = 150,
					})	

					for i = 0,23 do
						if i < self:GetParent():GetLevel()-1 then
							unit:HeroLevelUp(false)
						end
						local ab = self:GetParent():GetItemInSlot(i)
						if ab then
							local item = unit:AddItemByName(ab:GetName())
							if item then
								if ab:GetCurrentCharges() ~= 0 then
									item:SetCurrentCharges(ab:GetCurrentCharges())
								end
								item:SetDroppable(false)
							end
						end
						ab = self:GetParent():GetAbilityByIndex(i)
						if ab then
							local ability = unit:FindAbilityByName(ab:GetName())
							if ability then
								ability:SetLevel(ab:GetLevel())
							end
						end
					end
					unit:SetAbilityPoints(0)

					unit:SetControllableByPlayer(self:GetParent():GetPlayerID(), true)
					unit:SetOwner(self:GetParent())
					unit:SetCanSellItems(false)
					unit:SetHasInventory(false)
				end)
			end
		else
			if self.illusion then
				if not self.illusion:IsNull() then
					self.illusion:RemoveSelf()
				end
				self.illusion = nil
			end
		end
	end,
}

--[[
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_vengefulspirit_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_vengefulspirit_perk ~= "" then modifier_npc_dota_hero_vengefulspirit_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:OnCreated(keys)
	self.stealAmount = 2
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:DeclareFunctions()
	return { 
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS  
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:GetModifierBonusStats_Intellect(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:GetModifierBonusStats_Agility(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:GetModifierBonusStats_Strength(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:OnHeroKilled(keys)
	local caster = self:GetCaster()

	-- If Vengeful spirit is the killed hero, apply a debuff to the attacker
	if keys.target == caster and keys.target:IsRealHero() then
		if keys.attacker and keys.attacker:IsRealHero() and keys.attacker:IsAlive() then
			keys.attacker:AddNewModifier(caster, self, "modifier_npc_dota_hero_vengefulspirit_perk_debuff", {})
			keys.attacker:SetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk_debuff", caster, keys.attacker:GetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk_debuff", caster) + self.stealAmount)

			self:GetCaster():SetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk", caster, self:GetCaster():GetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk", caster) + self.stealAmount)
		end
	end
	return true
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_vengefulspirit_perk_debuff				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_vengefulspirit_perk_debuff ~= "" then modifier_npc_dota_hero_vengefulspirit_perk_debuff = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:GetTexture()
	return "vengefulspirit_command_aura"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:GetModifierBonusStats_Intellect(params)
	return -self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:GetModifierBonusStats_Agility(params)
	return -self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk_debuff:GetModifierBonusStats_Strength(params)
	return -self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
]]
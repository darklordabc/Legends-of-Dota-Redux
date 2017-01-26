--------------------------------------------------------------------------------------------------------
--
--		Hero: Vengeful Spirit
--		Perk: When Vengeful Spirit is slain by an enemy hero, she permanently reduces the hero's attributes by 2. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_vengefulspirit_perk", "abilities/hero_perks/npc_dota_hero_vengefulspirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_vengefulspirit_perk_debuff", "abilities/hero_perks/npc_dota_hero_vengefulspirit_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_vengefulspirit_perk ~= "" then npc_dota_hero_vengefulspirit_perk = class({}) end
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
	MODIFIER_EVENT_ON_HERO_KILLED
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:OnHeroKilled(keys)
	local caster = self:GetCaster()

	-- If Vengeful spirit is the killed hero, apply a debuff to the attacker
	if keys.target == caster and keys.target:IsRealHero() then
		if keys.attacker and keys.attacker:IsRealHero() and keys.attacker:IsAlive() then
			keys.attacker:AddNewModifier(caster, self, "modifier_npc_dota_hero_vengefulspirit_perk_debuff", {})
			keys.attacker:SetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk_debuff", self, keys.attacker:GetModifierStackCount("modifier_npc_dota_hero_vengefulspirit_perk_debuff", self) + self.stealAmount)
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
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS  
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

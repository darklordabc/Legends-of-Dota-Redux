--------------------------------------------------------------------------------------------------------
--
--		Hero: Dragon Knight
--		Perk: Dragon Form applies debuffs on damage and modifier application
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dragon_knight_perk", "abilities/hero_perks/npc_dota_hero_dragon_knight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_dragon_knight_perk == nil then npc_dota_hero_dragon_knight_perk = class({}) end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dragon_knight_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dragon_knight_perk == nil then modifier_npc_dota_hero_dragon_knight_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsHidden()
	return true
end

function modifier_npc_dota_hero_dragon_knight_perk:OnCreated()
	-- self.dragonform = self:GetParent():FindAbilityByName("dragon_knight_elder_dragon_form")
	print(self:GetParent():GetUnitName())
end

function modifier_npc_dota_hero_dragon_knight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }
  return funcs
end

function modifier_npc_dota_hero_dragon_knight_perk:OnTakeDamage(params)
	local dragonform = self:GetParent():FindAbilityByName("dragon_knight_elder_dragon_form")
	if self.dragonform or dragonform and params.attacker == self:GetParent() then
		local caster = params.attacker
		local parent = params.unit
		if caster and parent and caster == self:GetCaster() and params.inflictor ~= dragonform then
			if caster:HasModifier("modifier_dragon_knight_corrosive_breath") then
				local duration = dragonform:GetSpecialValueFor("corrosive_breath_duration")
			parent:AddNewModifier(caster, dragonform, "modifier_dragon_knight_corrosive_breath_dot", {duration = duration})
			end
			if caster:HasModifier("modifier_dragon_knight_frost_breath") then
				local duration = dragonform:GetSpecialValueFor("frost_duration")
				parent:AddNewModifier(caster, dragonform, "modifier_dragon_knight_frost_breath_slow", {duration = duration})
			end
		end
	end
end
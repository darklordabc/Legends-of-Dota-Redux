--------------------------------------------------------------------------------------------------------
--
--		Hero: Jakiro
--		Perk: Fire and Ice spells cast sequentially will refund 40% mana and have 20% reduced cooldowns.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_jakiro_perk", "abilities/hero_perks/npc_dota_hero_jakiro_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_jakiro_perk_fire", "abilities/hero_perks/npc_dota_hero_jakiro_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_jakiro_perk_ice", "abilities/hero_perks/npc_dota_hero_jakiro_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_jakiro_perk ~= "" then npc_dota_hero_jakiro_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_jakiro_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_jakiro_perk ~= "" then modifier_npc_dota_hero_jakiro_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:IsHidden()
	local caster = self:GetCaster()
	if caster:HasModifier(self.icePerk) then return true end
	if caster:HasModifier(self.firePerk) then return true end
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:OnCreated(keys)
	self.timeToCast = 13
	self.cooldownPercentReduction = 20
	self.manaPercentReduction = 40

	self.firePerk = "modifier_npc_dota_hero_jakiro_perk_fire"
	self.icePerk = "modifier_npc_dota_hero_jakiro_perk_ice"

	self.cooldownReduction = 1-(self.cooldownPercentReduction / 100)
	self.manaReduction = self.manaPercentReduction / 100
	return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk:OnAbilityFullyCast(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local ability = keys.ability
		if caster == keys.unit and ability then
			if ability:HasAbilityFlag("fire") then
				if caster:HasModifier(self.firePerk) then
					caster:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
					local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
					ability:EndCooldown()
					ability:StartCooldown(cooldown)
					caster:RemoveModifierByName(self.firePerk)
				end
				caster:AddNewModifier(caster,nil,self.icePerk,{Duration = self.timeToCast})
			elseif ability:HasAbilityFlag("ice") then
				if caster:HasModifier(self.icePerk) then
					caster:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
					local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
					ability:EndCooldown()
					ability:StartCooldown(cooldown)
					caster:RemoveModifierByName(self.icePerk)
				end
				caster:AddNewModifier(caster,nil,self.firePerk,{Duration = self.timeToCast})
			end
		end
	end
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_jakiro_perk_fire				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_jakiro_perk_fire ~= "" then modifier_npc_dota_hero_jakiro_perk_fire = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk_fire:RemoveOnDeath()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk_fire:GetTexture()
	return "jakiro_liquid_fire"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_jakiro_perk_ice				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_jakiro_perk_ice ~= "" then modifier_npc_dota_hero_jakiro_perk_ice = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk_ice:RemoveOnDeath()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_jakiro_perk_ice:GetTexture()
	return "jakiro_ice_path"
end
--------------------------------------------------------------------------------------------------------

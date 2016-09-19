--------------------------------------------------------------------------------------------------------
--
--		Hero: Abaddon
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_abaddon_perk", "abilities/hero_perks/npc_dota_hero_abaddon_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_charges", "abilities/modifiers/modifier_charges.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_abaddon_perk == nil then npc_dota_hero_abaddon_perk = class({}) end

function npc_dota_hero_abaddon_perk:GetIntrinsicModifierName()
    return "modifier_npc_dota_hero_abaddon_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_abaddon_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_abaddon_perk == nil then modifier_npc_dota_hero_abaddon_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsHidden()
	return true
end

function modifier_npc_dota_hero_abaddon_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function modifier_npc_dota_hero_abaddon_perk:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_abaddon_perk:OnIntervalThink()
	if not self.activated then
		local shield = self:GetParent():FindAbilityByName("abaddon_aphotic_shield")
		if shield:GetLevel() > 0 then
			if shield and shield:GetLevel() > 0 then
				self:GetParent():AddNewModifier(self:GetParent(), shield, "modifier_charges",
					{
						max_count = 2,
						start_count = 1,
						replenish_time = shield:GetCooldown(-1)
					}
				)
			end
			self.activated = true
		end
	end
end

local Timers = require('easytimers')

function modifier_npc_dota_hero_abaddon_perk:OnAbilityExecuted(params)
	if params.unit == self:GetParent() then
		if params.ability:GetName() == "abaddon_death_coil" then
			local coil = params.ability
			self:GetParent():Heal(coil:GetSpecialValueFor("self_damage")*2, self:GetParent())
			Timers:CreateTimer(function()
				if not coil:IsCooldownReady() then
					self:GetParent():Heal(coil:GetSpecialValueFor("self_damage")*2, self:GetParent())
				else
					return 0.01
				end
			end, DoUniqueString('abbadonSelfHeal'), 0.01)
		end
		if params.ability:GetName() == "abaddon_aphotic_shield" then
			local shield = params.ability
			local stacks = self:GetParent():GetModifierStackCount("modifier_charges", self:GetParent())
			if not self:GetParent():HasModifier("modifier_charges") then
				self:GetParent():AddNewModifier(self:GetParent(), shield, "modifier_charges",
						{
							max_count = 2,
							start_count = 1,
							replenish_time = shield:GetCooldown(-1)
						}
					)
			end
			if stacks < 1 then
				shield:StartCooldown(shield:GetTrueCooldown())
			end
			if stacks > 1 then
				 Timers:CreateTimer(function()
					if not shield:IsCooldownReady() then
						shield:EndCooldown()
					else
						return 0.01
					end
				end, DoUniqueString('abbadonShield'), 0.01)
			end
		end
	end
end
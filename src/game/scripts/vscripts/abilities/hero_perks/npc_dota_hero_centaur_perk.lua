--------------------------------------------------------------------------------------------------------
--
--		Hero: centaur
--		Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_centaur_perk", "abilities/hero_perks/npc_dota_hero_centaur_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_centaur_perk == nil then npc_dota_hero_centaur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_centaur_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_centaur_perk == nil then modifier_npc_dota_hero_centaur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsHidden()
	return true
end

function modifier_npc_dota_hero_centaur_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:OnCreated()
	self.SelfDamaging = { ["pudge_rot"] = true,
						  ["item_soul_ring"] = true,
						  ["centaur_double_edge"] = true,
						  ["abaddon_death_coil"] = true,
						  ["huskar_burning_spear"] = true,
						  ["slark_dark_pact"] = true,
						  ["phoenix_sun_ray"] = true,
						  ["phoenix_icarus_dive"] = true,
						  ["phoenix_fire_spirits"] = true,
						  ["lone_druid_spirit_bear"] = true,
						  ["pugna_life_drain"] = true,
						  ["huskar_life_break"] = true
						}
end

function modifier_npc_dota_hero_centaur_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_centaur_perk:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		if params.inflictor and self.SelfDamaging[params.inflictor:GetName()] then
			local hp = self:GetParent():GetHealth()
			self:GetParent():SetHealth(hp + params.damage*0.25)
		end
	end
end
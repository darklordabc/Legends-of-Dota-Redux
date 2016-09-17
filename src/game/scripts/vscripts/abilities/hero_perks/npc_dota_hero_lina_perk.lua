--------------------------------------------------------------------------------------------------------
--
--		Hero: Lina
--		Perk: Increases Lina's intelligence by 3 for each level put in fire-type spells.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lina_perk", "abilities/hero_perks/npc_dota_hero_lina_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lina_perk == nil then npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lina_perk
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lina_perk == nil then modifier_npc_dota_hero_lina_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:IsHidden()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lina_perk:GetModifierBonusStats_Intellect(params)
	local caster = self:GetCaster()

	local intellect_value = 3

	local bonusIntellect = 0
	local fireSpells = {
		lina_dragon_slave = true,
		lina_fiery_soul = true,
		lina_light_strike_array = true,
		lina_laguna_blade = true,
		dragon_knight_breathe_fire = true,
		nyx_assassin_mana_burn = true,
		jakiro_macropyre = true,
		jakiro_dual_breath = true,
		jakiro_liquid_fire = true,
		ember_spirit_fire_remnant = true,
		ember_spirit_flame_guard = true,
		ember_spirit_searing_chains = true,
		ogre_magi_fireblast = true,
		ogre_magi_ignite = true,
		phoenix_icarus_dive = true,
		phoenix_fire_spirits = true,
		phoenix_sun_ray = true,
		phoenix_supernova = true,
		doom_bringer_scorched_earth = true,
		doom_bringer_doom = true,
		doom_bringer_infernal_blade = true,
		clinkz_searing_arrows = true,
		warlock_rain_of_chaos = true,
		invoker_chaos_meteor = true,
		invoker_sun_strike = true,
		invoker_forge_spirit = true,
		huskar_burning_spear = true,
		batrider_firefly = true,
		batrider_flamebreak = true,
		batrider_flaming_lasso = true,
		abyssal_underlord_firestorm = true,
		black_dragon_fireball = true,
		warlock_golem_flaming_fists = true,
		warlock_golem_permanent_immolation = true,
		warlock_golem_permanent_immolation_lod = true
	}

	for i = 0, 15 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and fireSpells[ability:GetName()] then
			local level = ability:GetLevel()
			bonusIntellect = bonusIntellect + (level * intellect_value)	
		end
	end
	return bonusIntellect
end
--------------------------------------------------------------------------------------------------------


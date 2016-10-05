--------------------------------------------------------------------------------------------------------
--
--    Hero: Chen
--    Perk: 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_chen_perk", "abilities/hero_perks/npc_dota_hero_chen_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_chen_perk == nil then npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_chen_perk        
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_chen_perk == nil then modifier_npc_dota_hero_chen_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chen_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_npc_dota_hero_chen_perk:OnAbilityStart(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if not chen_abilities then
      chen_abilities = {
		"enchantress_untouchable",
		"faceless_void_time_lock",
		"furion_teleportation",
		"huskar_berserkers_blood",
		"kunkka_tidebringer",
		"life_stealer_feast",
		"luna_lunar_blessing",
		 "luna_moon_glaive",
		 "lycan_feral_impulse",
		 "meepo_geostrike",
		 "necrolyte_heartstopper_aura",
		 "necrolyte_sadist",
		 "nevermore_dark_lord",
		 "night_stalker_hunter_in_the_night",
		 "omniknight_degen_aura",
		 "phantom_assassin_coup_de_grace",
		 "razor_unstable_current",
		 "shredder_reactive_armor",
		 "skeleton_king_vampiric_aura",
		 "slardar_bash",
		 "slark_essence_shift",
		 "slark_shadow_dance",
		 "sniper_headshot",
		 "sniper_take_aim",
		 "spectre_dispersion",
		 "spirit_breaker_charge_of_darkness",
		 "spirit_breaker_greater_bash",
		 "sven_great_cleave",
		 "techies_suicide",
		 "tiny_craggy_exterior",
		 "troll_warlord_fervor",
		 "ursa_fury_swipes",
		 "vengefulspirit_command_aura",
		 "viper_corrosive_skin",
		 "viper_nethertoxin",
		 "weaver_geminate_attack",
		 "riki_permanent_invisibility",
		 "beastmaster_boar_poison",
		 "beastmaster_greater_boar_poison",
		 "lone_druid_spirit_bear_entangle",
		 "roshan_slam",
		 "warlock_golem_flaming_fists",
		 "warlock_golem_permanent_immolation_lod",
		 "visage_summon_familiars_stone_form",
		 "imba_dazzle_shallow_grave",
		 "holdout_arcane_aura",
		 "ursa_enrage",
      }
    end

    if ability:GetAbilityName() == "chen_test_of_faith_teleport" and target:IsCreep() then
      -- Setting the table value one further
      if not chen_abilities_count then chen_abilities_count = 1 else chen_abilities_count =  chen_abilities_count + 1 end

      if chen_abilities_count > 1 then 
        target:RemoveAbility(chen_abilities[chen_abilities_count -1])
      end

      target:AddAbility(chen_abilities[chen_abilities_count])
      target:FindAbilityByName(chen_abilities[chen_abilities_count]):UpgradeAbility(true)
    end
  end
end                          


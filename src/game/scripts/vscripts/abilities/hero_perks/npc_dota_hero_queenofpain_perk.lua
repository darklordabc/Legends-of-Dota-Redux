--------------------------------------------------------------------------------------------------------
--
--      Hero: Queen of Pain
--      Perk: Queen of Pain deals 10% more damage to male heroes, but recieves 10% more damage from female heroes.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_queenofpain_perk", "abilities/hero_perks/npc_dota_hero_queenofpain_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_queenofpain_perk == nil then npc_dota_hero_queenofpain_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_queenofpain_perk               
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_queenofpain_perk == nil then modifier_npc_dota_hero_queenofpain_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:IsHidden()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:OnCreated()
    self.MaleHeroes = {
        npc_dota_hero_abaddon = true,
        npc_dota_hero_abyssal_underlord = true,
        npc_dota_hero_alchemist = true,
        npc_dota_hero_antimage = true,
        npc_dota_hero_arc_warden = true,
        npc_dota_hero_axe = true,
        npc_dota_hero_bane = true,
        npc_dota_hero_batrider = true,
        npc_dota_hero_beastmaster = true,
        npc_dota_hero_bloodseeker = true,
        npc_dota_hero_bounty_hunter = true,
        npc_dota_hero_brewmaster = true,
        npc_dota_hero_bristleback = true,
        npc_dota_hero_centaur = true,
        npc_dota_hero_chaos_knight = true,
        npc_dota_hero_chen = true,
        npc_dota_hero_clinkz = true,
        npc_dota_hero_dark_seer = true,
        npc_dota_hero_dazzle = true,
        npc_dota_hero_disruptor = true,
        npc_dota_hero_doom_bringer = true,
        npc_dota_hero_dragon_knight = true,
        npc_dota_hero_earth_spirit = true,
        npc_dota_hero_earthshaker = true,
        npc_dota_hero_elder_titan = true,
        npc_dota_hero_ember_spirit = true,
        npc_dota_hero_faceless_void = true,
        npc_dota_hero_furion = true,
        npc_dota_hero_gyrocopter = true,
        npc_dota_hero_huskar = true,
        npc_dota_hero_invoker = true,
        npc_dota_hero_jakiro = true,
        npc_dota_hero_juggernaut = true,
        npc_dota_hero_keeper_of_the_light = true,
        npc_dota_hero_kunkka = true,
        npc_dota_hero_leshrac = true,
        npc_dota_hero_lich = true,
        npc_dota_hero_life_stealer = true,
        npc_dota_hero_lion = true,
        npc_dota_hero_lone_druid = true,
        npc_dota_hero_lycan = true,
        npc_dota_hero_magnataur = true,
        npc_dota_hero_meepo = true,
        npc_dota_hero_morphling = true,
        npc_dota_hero_necrolyte = true,
        npc_dota_hero_nevermore = true,
        npc_dota_hero_night_stalker = true,
        npc_dota_hero_nyx_assassin = true,
        npc_dota_hero_obsidian_destroyer = true,
        npc_dota_hero_ogre_magi = true,
        npc_dota_hero_omniknight = true,
        npc_dota_hero_oracle = true,
        npc_dota_hero_phantom_lancer = true,
        npc_dota_hero_pudge = true,
        npc_dota_hero_pugna = true,
        npc_dota_hero_rattletrap = true,
        npc_dota_hero_razor = true,
        npc_dota_hero_riki = true,
        npc_dota_hero_rubick = true,
        npc_dota_hero_sand_king = true,
        npc_dota_hero_shadow_demon = true,
        npc_dota_hero_shadow_shaman = true,
        npc_dota_hero_shredder = true,
        npc_dota_hero_silencer = true,
        npc_dota_hero_skeleton_king = true,
        npc_dota_hero_skywrath_mage = true,
        npc_dota_hero_slardar = true,
        npc_dota_hero_slark = true,
        npc_dota_hero_sniper = true,
        npc_dota_hero_spirit_breaker = true,
        npc_dota_hero_storm_spirit = true,
        npc_dota_hero_sven = true,
        npc_dota_hero_terrorblade = true,
        npc_dota_hero_tidehunter = true,
        npc_dota_hero_tinker = true,
        npc_dota_hero_tiny = true,
        npc_dota_hero_treant = true,
        npc_dota_hero_troll_warlord = true,
        npc_dota_hero_tusk = true,
        npc_dota_hero_undying = true,
        npc_dota_hero_ursa = true,
        npc_dota_hero_venomancer = true,
        npc_dota_hero_viper = true,
        npc_dota_hero_visage = true,
        npc_dota_hero_warlock = true,
        npc_dota_hero_weaver = true,
        npc_dota_hero_witch_doctor = true,
        npc_dota_hero_zuus = true
    }
    self.FemaleHeroes = {
        npc_dota_hero_broodmother = true,
        npc_dota_hero_crystal_maiden = true,
        npc_dota_hero_death_prophet = true,
        npc_dota_hero_drow_ranger = true,
        npc_dota_hero_enchantress = true,
        npc_dota_hero_legion_commander = true,
        npc_dota_hero_winter_wyvern = true,
        npc_dota_hero_lina = true,
        npc_dota_hero_luna = true,
        npc_dota_hero_medusa = true,
        npc_dota_hero_mirana = true,
        npc_dota_hero_naga_siren = true,
        npc_dota_hero_phantom_assassin = true,
        npc_dota_hero_queenofpain = true,
        npc_dota_hero_spectre = true,
        npc_dota_hero_templar_assassin = true,
        npc_dota_hero_vengefulspirit = true,
        npc_dota_hero_windrunner = true,
        npc_dota_hero_winter_wyvern = true
    }
    return true
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, 
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    -- body
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.target and self.MaleHeroes[keys.target:GetName()] then
        return 10
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_queenofpain_perk:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker and self.FemaleHeroes[keys.attacker:GetName()] then
        return 10
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------

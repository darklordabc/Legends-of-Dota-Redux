local storage = {}

local modifierMap = {
    item_abyssal_blade = 'modifier_item_abyssal_blade',
    item_ancient_janggo = 'modifier_item_ancient_janggo',
    item_arcane_boots = 'modifier_item_arcane_boots',
    item_armlet = 'modifier_item_armlet',
    item_assault = 'modifier_item_assault',
    item_bfury = 'modifier_item_battlefury',
    item_belt_of_strength = 'modifier_item_belt_of_strength',
    item_black_king_bar = 'modifier_item_black_king_bar',
    item_blade_mail = 'modifier_item_blade_mail',
    item_blade_of_alacrity = 'modifier_item_blade_of_alacrity',
    item_blades_of_attack = 'modifier_item_blades_of_attack',
    item_blink = 'modifier_item_blink_dagger',
    item_bloodstone = 'modifier_item_bloodstone',
    item_boots_of_elves = 'modifier_item_boots_of_elves',
    lod_item_boots = 'modifier_item_boots_of_speed',
    item_travel_boots = 'modifier_item_boots_of_travel',
    item_bracer = 'modifier_item_bracer',
    item_broadsword = 'modifier_item_broadsword',
    item_buckler = 'modifier_item_buckler',
    item_butterfly = 'modifier_item_butterfly',
    item_chainmail = 'modifier_item_chainmail',
    item_circlet = 'modifier_item_circlet',
    item_claymore = 'modifier_item_claymore',
    item_basher = 'modifier_item_cranium_basher',
    item_crimson_guard = 'modifier_item_crimson_guard',
    item_cyclone = 'modifier_item_cyclone',
    item_dagon = 'modifier_item_dagon',
    item_dagon_2 = 'modifier_item_dagon',
    item_dagon_3 = 'modifier_item_dagon',
    item_dagon_4 = 'modifier_item_dagon',
    item_dagon_5 = 'modifier_item_dagon',
    item_demon_edge = 'modifier_item_demon_edge',
    item_desolator = 'modifier_item_desolator',
    item_diffusal_blade = 'modifier_item_diffusal_blade',
    item_diffusal_blade_2 = 'modifier_item_diffusal_blade',
    item_rapier = 'modifier_item_divine_rapier',
    item_eagle = 'modifier_item_eaglehorn',
    item_energy_booster = 'modifier_item_energy_booster',
    item_ethereal_blade = 'modifier_item_etheral_blade',
    item_gauntlets = 'modifier_item_gauntlets',
    item_gem = 'modifier_item_gem_of_true_sight',
    item_ghost = 'modifier_item_ghost_scepter',
    item_gloves = 'modifier_item_gloves_of_haste',
    item_greater_crit = 'modifier_item_greater_crit',
    item_hand_of_midas = 'modifier_item_hand_of_midas',
    item_headdress = 'modifier_item_headdress',
    item_heart = 'modifier_item_heart',
    item_heavens_halberd = 'modifier_item_heavens_halberd',
    item_helm_of_iron_will = 'modifier_item_helm_of_iron_will',
    item_helm_of_the_dominator = 'modifier_item_helm_of_the_dominator',
    item_hood_of_defiance = 'modifier_item_hood_of_defiance',
    item_hyperstone = 'modifier_item_hyperstone',
    lod_item_invis_sword = 'modifier_item_invisibility_edge',
    item_branches = 'modifier_item_ironwood_branch',
    item_javelin = 'modifier_item_javelin',
    item_lesser_crit = 'modifier_item_lesser_crit',
    item_maelstrom = 'modifier_item_maelstrom',
    item_magic_stick = 'modifier_item_magic_stick',
    item_magic_wand = 'modifier_item_magic_wand',
    item_manta = 'modifier_item_manta_style',
    item_mantle = 'modifier_item_mantle',
    lod_item_lifesteal = 'modifier_item_mask_of_death',
    item_mask_of_madness = 'modifier_item_mask_of_madness',
    item_medallion_of_courage = 'modifier_item_medallion_of_courage',
    item_mekansm = 'modifier_item_mekansm',
    item_mithril_hammer = 'modifier_item_mithril_hammer',
    item_mjollnir = 'modifier_item_mjollnir',
    item_monkey_king_bar = 'modifier_item_monkey_king_bar',
    item_mystic_staff = 'modifier_item_mystic_staff',
    item_necronomicon = 'modifier_item_necronomicon',
    item_necronomicon_2 = 'modifier_item_necronomicon',
    item_necronomicon_3 = 'modifier_item_necronomicon',
    item_null_talisman = 'modifier_item_null_talisman',
    item_oblivion_staff = 'modifier_item_oblivion_staff',
    item_ogre_axe = 'modifier_item_ogre_axe',
    item_orb_of_venom = 'modifier_item_orb_of_venom',
    item_orchid = 'modifier_item_orchid_malevolence',
    item_pers = 'modifier_item_perseverance',
    item_phase_boots = 'modifier_item_phase_boots',
    item_pipe = 'modifier_item_pipe',
    item_cloak = 'modifier_item_planeswalkers_cloak',
    item_platemail = 'modifier_item_plate_mail',
    item_point_booster = 'modifier_item_point_booster',
    item_poor_mans_shield = 'modifier_item_poor_mans_shield',
    item_power_treads = 'modifier_item_power_treads',
    item_quarterstaff = 'modifier_item_quarterstaff',
    item_quelling_blade = 'modifier_item_quelling_blade',
    item_radiance = 'modifier_item_radiance',
    item_reaver = 'modifier_item_reaver',
    item_refresher = 'modifier_item_refresherorb',
    item_ring_of_aquila = 'modifier_item_ring_of_aquila',
    item_ring_of_basilius = 'modifier_item_ring_of_basilius',
    item_ring_of_health = 'modifier_item_ring_of_health',
    item_ring_of_protection = 'modifier_item_ring_of_protection',
    item_ring_of_regen = 'modifier_item_ring_of_regeneration',
    item_robe = 'modifier_item_robe_of_magi',
    item_rod_of_atos = 'modifier_item_rod_of_atos',
    item_relic = 'modifier_item_sacred_relic',
    item_sange = 'modifier_item_sange',
    item_sange_and_yasha = 'modifier_item_sange_and_yasha',
    item_satanic = 'modifier_item_satanic',
    item_shadow_amulet = 'modifier_item_shadow_amulet',
    item_sheepstick = 'modifier_item_sheepstick',
    item_shivas_guard = 'modifier_item_shivas_guard',
    item_skadi = 'modifier_item_skadi',
    item_slippers = 'modifier_item_slippers',
    item_sobi_mask = 'modifier_item_sobi_mask',
    item_soul_booster = 'modifier_item_soul_booster',
    item_soul_ring = 'modifier_item_soul_ring',
    item_sphere = 'modifier_item_sphere',
    item_staff_of_wizardry = 'modifier_item_staff_of_wizardry',
    item_stout_shield = 'modifier_item_stout_shield',
    item_talisman_of_evasion = 'modifier_item_talisman_of_evasion',
    item_tranquil_boots = 'modifier_item_tranquil_boots',
    item_ultimate_orb = 'modifier_item_ultimate_orb',
    item_ultimate_scepter = 'modifier_item_ultimate_scepter',
    item_urn_of_shadows = 'modifier_item_urn_of_shadows',
    item_vanguard = 'modifier_item_vanguard',
    item_veil_of_discord = 'modifier_item_veil_of_discord',
    item_vitality_booster = 'modifier_item_vitality_booster',
    item_vladmir = 'modifier_item_vladmir',
    item_void_stone = 'modifier_item_void_stone',
    item_wraith_band = 'modifier_item_wraith_band',
    item_yasha = 'modifier_item_yasha',
}

function init(keys)
    local hero = keys.caster
    local ability = keys.ability

    local itemName = ability:GetAbilityName():gsub('lod_', '')
    local itemModifierName = itemName:gsub('_5', ''):gsub('_10', ''):gsub('_20', '')

    -- Create the item
    local item = CreateItem(itemName, hero, hero)
    if not item then return end

    -- Add the modifier (the passive part)
    if GameRules.allowItemModifers then
        hero:AddNewModifier(hero, item, modifierMap[itemModifierName] or ('modifier_'..itemName), {})
    end

    -- Store info on this ability
    storage[ability] = {
        item = item
    }
end

function initToggle(keys)
    -- Setup
    init(keys)

    -- Grab ability
    local ability = keys.ability

    -- Grab info
    local info = storage[ability]
    if not info then return end

    -- Grab the item
    local item = info.item
    if not item or not IsValidEntity(item) then return end

    -- Toggle item off
    item:ToggleAbility()
end

function onUse(keys)
    -- Grab useful stuff
    local ability = keys.ability

    -- Grab info
    local info = storage[ability]
    if not info then return end

    -- Grab the item
    local item = info.item
    if not item or not IsValidEntity(item) then return end

    -- Check the item's cooldown
    if item:IsCooldownReady() then
        -- Cast the ability
        item:CastAbility()
    else
        -- Match the cooldown
        ability:EndCooldown()
        ability:StartCooldown(item:GetCooldownTimeRemaining())
    end
end

function onUnitTarget(keys)
    onUse(keys)
end

function onPointTarget(keys)
    onUse(keys)
end

function onToggle(keys)
    -- Grab useful stuff
    local ability = keys.ability

    -- Grab info
    local info = storage[ability]
    if not info then return end

    -- Grab the item
    local item = info.item
    if not item or not IsValidEntity(item) then return end

    -- Toggle it
    item:ToggleAbility()
end

function onChannel(keys)
    -- Grab useful stuff
    local ability = keys.ability

    -- Grab info
    local info = storage[ability]
    if not info then return end

    -- Grab the item
    local item = info.item
    if not item or not IsValidEntity(item) then return end

    -- Check the item's cooldown
    if item:IsCooldownReady() then
        -- Cast the ability
        ability:EndChannel(false)
        item:CastAbility()
    else
        -- Match the cooldown
        ability:EndCooldown()
        ability:StartCooldown(item:GetCooldownTimeRemaining())
    end
end

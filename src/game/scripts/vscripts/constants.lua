local Constants = {}

-- Game Phases
Constants.PHASE_LOADING = 1             -- Waiting for players, etc
Constants.PHASE_OPTION_VOTING = 2       -- Voting for options
Constants.PHASE_OPTION_SELECTION = 3    -- Selection options
Constants.PHASE_BANNING = 4             -- Banning stuff
Constants.PHASE_SELECTION = 5           -- Selecting heroes
Constants.PHASE_DRAFTING = 6            -- Place holder for drafting mode
Constants.PHASE_RANDOM_SELECTION = 7    -- Random build selection phase (for All Random)
Constants.PHASE_REVIEW = 8              -- Review Phase
Constants.PHASE_SPAWN_HEROES = 9        -- Item picking has started, we are spawning our heroes
Constants.PHASE_ITEM_PICKING = 10       -- Item picking phase
Constants.PHASE_INGAME = 11             -- Game has started

-- Balance Mode Values
Constants.BALANCE_MODE_POINTS = 120

-- EXP Needed for each level
Constants.XP_PER_LEVEL_TABLE = {
        0,-- 1
        240,-- 2
        600,-- 3
        1080,-- 4
        1680,-- 5
        2300,-- 6
        2940,-- 7
        3600,-- 8
        4280,-- 9
        5080,-- 10
        5900,-- 11
        6740,-- 12
        7640,-- 13
        8865,-- 14
        10115,-- 15
        11390,-- 16
        12690,-- 17
        14015,-- 18
        15415,-- 19
        16905,-- 20
        18405,-- 21
        20155,-- 22
        22155,-- 23
        24405,-- 24
        26905, -- 25
        35000,-- 26
        37700,-- 27
        40500,-- 28
        43400,-- 29
        46400,-- 30
        49500,-- 31
        52700,-- 32
        56000,-- 33
        59400,-- 34
        62900,-- 35
        66500,-- 36
        70200,-- 37
        74000,-- 38
        77900,-- 39
        81900,-- 40
        86000,-- 41
        90200,-- 42
        94500,-- 43
        98900,-- 44
        103400,-- 45
        108000,-- 46
        112700,-- 47
        117500,-- 48
        122400,-- 49
        127400,-- 50
        132500,-- 51
        137700,-- 52
        143000,-- 53
        148400,-- 54
        153900,-- 55
        159500,-- 56
        165200,-- 57
        171000,-- 58
        176900,-- 59
        182900,-- 60
        189000,-- 61
        195200,-- 62
        201500,-- 63
        207900,-- 64
        214400,-- 65
        221000,-- 66
        227700,-- 67
        234500,-- 68
        241400,-- 69
        248400,-- 70
        255500,-- 71
        262700,-- 72
        270000,-- 73
        277400,-- 74
        284900,-- 75
        292500,-- 76
        300200,-- 77
        308000,-- 78
        315900,-- 79
        323900,-- 80
        332000,-- 81
        340200,-- 82
        348500,-- 83
        356900,-- 84
        365400,-- 85
        374000,-- 86
        382700,-- 87
        391500,-- 88
        400400,-- 89
        409400,-- 90
        418500,-- 91
        427700,-- 92
        437000,-- 93
        446400,-- 94
        455900,-- 95
        465500,-- 96
        475200,-- 97
        485000,-- 98
        494900,-- 99
        504900,-- 100
    }


--Max percent scaling factor for Fat-O-Meter, per hero. Generally speaking, bigger hero = smaller max height.
--Initial categories: Small: 3.6, Humanoid: 3.3, Large: 3.0, Flying/Tall: 2.7, Huge: 2.4. Adjust individually as necessary.
Constants.FAT_SCALING = {
	npc_dota_hero_ancient_apparition = 3.0,
	npc_dota_hero_antimage = 3.0,
	npc_dota_hero_axe = 3.0,
	npc_dota_hero_bane = 2.7,
	npc_dota_hero_beastmaster = 3.0,
	npc_dota_hero_bloodseeker = 3.6,
	npc_dota_hero_chen = 3.3,
	npc_dota_hero_crystal_maiden = 3.3,
	npc_dota_hero_dark_seer = 3.6,
	npc_dota_hero_dazzle = 3.3,
	npc_dota_hero_dragon_knight = 3.3,
	npc_dota_hero_doom_bringer = 2.4,
	npc_dota_hero_drow_ranger = 3.3,
	npc_dota_hero_earthshaker = 3.3,
	npc_dota_hero_enchantress = 3.3,
	npc_dota_hero_enigma = 3.0,
	npc_dota_hero_faceless_void = 3.6,
	npc_dota_hero_furion = 3.3,
	npc_dota_hero_juggernaut = 3.6,
	npc_dota_hero_kunkka = 3.3,
	npc_dota_hero_leshrac = 3.3,
	npc_dota_hero_lich = 2.7,
	npc_dota_hero_life_stealer = 3.0,
	npc_dota_hero_lina = 3.3, --Flying, but small model
	npc_dota_hero_lion = 3.3,
	npc_dota_hero_mirana = 3.0,
	npc_dota_hero_morphling = 3.3,
	npc_dota_hero_necrolyte = 3.3,
	npc_dota_hero_nevermore = 3.0,
	npc_dota_hero_night_stalker = 3.0,
	npc_dota_hero_omniknight = 3.3,
	npc_dota_hero_puck = 3.3, --Flying, but small model
	npc_dota_hero_pudge = 3.0,
	npc_dota_hero_pugna = 3.6,
	npc_dota_hero_rattletrap = 3.6,
	npc_dota_hero_razor = 2.7,
	npc_dota_hero_riki = 3.6,
	npc_dota_hero_sand_king = 3.0,
	npc_dota_hero_shadow_shaman = 3.3,
	npc_dota_hero_slardar = 3.0,
	npc_dota_hero_sniper = 3.6,
	npc_dota_hero_spectre = 3.3,
	npc_dota_hero_storm_spirit = 3.3,
	npc_dota_hero_sven = 3.0,
	npc_dota_hero_tidehunter = 3.0,
	npc_dota_hero_tinker = 3.3,
	npc_dota_hero_tiny = 3.0, --Nobody even picks him anyway, but I stuck him in the middle so he's not too small without grow but not too big with it.
	npc_dota_hero_vengefulspirit = 3.0,
	npc_dota_hero_venomancer = 3.3,
	npc_dota_hero_viper = 2.7,
	npc_dota_hero_weaver = 3.0,
	npc_dota_hero_windrunner = 3.3,
	npc_dota_hero_witch_doctor = 3.3,
	npc_dota_hero_zuus = 3.6,
	npc_dota_hero_broodmother = 2.4,
	npc_dota_hero_skeleton_king = 3.0,
	npc_dota_hero_queenofpain = 3.3,
	npc_dota_hero_huskar = 3.3, --Smaller than normal Dota because of not necessarily having Berserker's Blood
	npc_dota_hero_jakiro = 2.7,
	npc_dota_hero_batrider = 2.7,
	npc_dota_hero_warlock = 3.3,
	npc_dota_hero_alchemist = 3.0,
	npc_dota_hero_death_prophet = 3.3,
	npc_dota_hero_ursa = 3,2,
	npc_dota_hero_bounty_hunter = 3.6,
	npc_dota_hero_silencer = 3.3,
	npc_dota_hero_spirit_breaker = 3.0,
	npc_dota_hero_invoker = 3.3,
	npc_dota_hero_clinkz = 3.6,
	npc_dota_hero_obsidian_destroyer = 2.7,
	npc_dota_hero_shadow_demon = 3.0,
	npc_dota_hero_lycan = 3.0,
	npc_dota_hero_lone_druid = 3.3,
	npc_dota_hero_brewmaster = 3.0,
	npc_dota_hero_phantom_lancer = 3.0,
	npc_dota_hero_treant = 3.0,
	npc_dota_hero_ogre_magi = 3.0,
	npc_dota_hero_chaos_knight = 3.0,
	npc_dota_hero_phantom_assassin = 3.3,
	npc_dota_hero_gyrocopter = 2.7,
	npc_dota_hero_rubick = 3.0,
	npc_dota_hero_luna = 3.0,
	npc_dota_hero_wisp = 3.0, --Io doesn't scale well visually, so we can be more modest. His particles just rise up in the air while his clickbox grows.
	npc_dota_hero_disruptor = 3.0,
	npc_dota_hero_undying = 2.7,
	npc_dota_hero_templar_assassin = 3.0,
	npc_dota_hero_naga_siren = 3.3,
	npc_dota_hero_nyx_assassin = 3.3,
	npc_dota_hero_keeper_of_the_light = 3.0,
	npc_dota_hero_visage = 2.7,
	npc_dota_hero_meepo = 3.6,
	npc_dota_hero_magnataur = 3.0,
	npc_dota_hero_centaur = 2.4,
	npc_dota_hero_slark = 3.6,
	npc_dota_hero_shredder = 3.0,
	npc_dota_hero_medusa = 3.0,
	npc_dota_hero_troll_warlord = 3.0,
	npc_dota_hero_tusk = 3.0,
	npc_dota_hero_bristleback = 3.6,
	npc_dota_hero_skywrath_mage = 2.7,
	npc_dota_hero_elder_titan = 3.0,
	npc_dota_hero_abaddon = 3.0,
	npc_dota_hero_earth_spirit = 3.0,
	npc_dota_hero_ember_spirit = 3.3,
	npc_dota_hero_legion_commander = 3.0,
	npc_dota_hero_phoenix = 2.7,
	npc_dota_hero_terrorblade = 2.7,
	npc_dota_hero_techies = 3.6,
	npc_dota_hero_oracle = 2.7,
	npc_dota_hero_winter_wyvern = 2.7,
	npc_dota_hero_arc_warden = 3.3,
	npc_dota_hero_abyssal_underlord = 2.4,
}

-- Imba Stuff
CAST_RANGE_TALENTS = {}														-- Cast range talent values
CAST_RANGE_TALENTS["special_bonus_cast_range_50"] = 50
CAST_RANGE_TALENTS["special_bonus_cast_range_60"] = 60
CAST_RANGE_TALENTS["special_bonus_cast_range_75"] = 75
CAST_RANGE_TALENTS["special_bonus_cast_range_100"] = 100
CAST_RANGE_TALENTS["special_bonus_cast_range_125"] = 125
CAST_RANGE_TALENTS["special_bonus_cast_range_150"] = 150
CAST_RANGE_TALENTS["special_bonus_cast_range_175"] = 175
CAST_RANGE_TALENTS["special_bonus_cast_range_200"] = 200
CAST_RANGE_TALENTS["special_bonus_cast_range_250"] = 250
CAST_RANGE_TALENTS["special_bonus_cast_range_300"] = 300

MAXIMUM_ATTACK_SPEED = 600					-- What should we use for the maximum attack speed?

return Constants

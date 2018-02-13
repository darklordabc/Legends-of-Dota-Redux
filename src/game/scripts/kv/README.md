**abilities.kv** - List of all abilities that will appear on the abilities skill select screen. Divided into brackets which represent the different categories of abilities.

**abilityDeps.kv** - Ability dependencies. These list abilities that require secondary abilities, if a player picks an ability on the left, they will receive the ability on the right.

**abilityReps.kv** -

**banned.kv** - List of banned players from Redux. This is imported from original LoD and has not been updated since Redux split off.

**bans.kv** - Ability combination bans. Most banned combinations are now dealt with "ReduxBans" flags in the ability data, and bans.kv is slightly a relic, but now it contains special ban combinations, like groups of banned abilities and other special bans. 

**bot_skills.kv** - Lists abilities that bots will select for their extra skills, each bot has a list and the lists are in order of priority, the best abilities at the top, worst at the bottom.

**bot_skills_imba_WIP.kv** - Same as above, but the list contains OP abilities. This is currently not used.

**camps.kv** - Defines the neutral camp group of creatures. This is used for the set of abilities that spawn neutral camps (e.g. "spawn_small_camp").

**consumable_items.kv** - List of items that can be consumed.

**contributors.kv** - Credits for people who have worked on the game. This is used for the ingame credits page. It is also used for the code that gives players gold names.

**hashes.kv** - 

**hero_perks.kv** - This is for the checkbox in the skill picking menu that only shows perk related skills. It defines which perk category is related to which hero, or it mentions specific abilities (instead of categories).

**owners.kv** - 

**perks.kv** - Currently only used to determine what abilities Chen gives to creeps with his perk, and to determine which gender is each hero for QOP's perk.

**randompicker.kv** - Used for the "True Random" ability that is no longer useable

**sounds.kv** - 

**statuploadersettings.kv** - The web address where to upload stats.

**towers.kv** - Classifies tower abilities into power levels. This is for when abilities are given to towers, it can keep track of the total power levels of towers and try to make sure their mirror tower is similar power. 

**ts_entities.kv** - These are entities that need to switch teams when a player switches teams.

**unique_skills.kv** - These are abilities that a bot team will only pick one of, i.e. if another bot already has one of these, all other bots won't pick it.

**voting.kv** - 

**wearables.kv** - This is related to the wearables library, currently its only used for the MAGA hat for Roshan.

**whatsup.kv** - Old welcome messaged used by Ash47. Unused now.

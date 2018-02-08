abilities.kv - List of all abilities that will appear on the abilities skill select screen. Divided into brackets which represent the different categories of abilities.

abilityDeps.kv - Ability dependencies. This list abilities that require secondary abiliites, if a player picks an ability on the left, they will receive the ability on the right.

banned.kv - List of banned players from Redux. This is imported from original LoD and has not been updated since Redux split off.

bans.kv - Ability combination bans. Most banned combinations are now dealt with "ReduxBans" flags in ability data, and bans.kv is slightly a relic, but now it contains special ban combinations, like groups of banned abilities and other special bans. 

bot_skills.kv - Lists abilities that bots will select for their extra skills, each bot has a list and the lists are in order of priority, the best abilities at the top, worst at the bottom.

bot_skills_imba_WIP.kv - Same as above, but the list contains OP abilities. This is currently not used.

camps.kv - Defines the neutral camp group of creatures. This is used for the set of abilities that spawn neutral camps (e.g. "spawn_small_camp").

consumable_items.kv - List of items that can be consumed.

contributors.kv - Credits for people who have worked on the game. This is used for the ingame credits page. It is also used for the code that gives players gold names.
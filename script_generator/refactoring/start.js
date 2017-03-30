var fs = require('fs')
var deepmerge = require("deepmerge")
var vdf = require("./simple-vdf")

//Parse input kvs
var flags, balance_mode, bans, perks;

try {flags = vdf.parse(fs.readFileSync("../../src/game/scripts/kv/flags.kv", 'utf-8'))} catch(e) {}
try {balance_mode = vdf.parse(fs.readFileSync("../../src/game/scripts/kv/balance_mode.kv", 'utf-8'))} catch(e) {}
try {bans = vdf.parse(fs.readFileSync("../../src/game/scripts/kv/bans.kv", 'utf-8'))} catch(e) {}
try {perks = vdf.parse(fs.readFileSync("../../src/game/scripts/kv/perks.kv", 'utf-8'))} catch(e) {}

//Read possible outputs to find files, that contains certain abilities
var npc_abilities_override = vdf.parse(fs.readFileSync("../../src/game/scripts/npc/npc_abilities_override.txt", 'utf-8'))
var npc_items_custom = vdf.parse(fs.readFileSync("../../src/game/scripts/npc/npc_items_custom.txt", 'utf-8'))
npc_items_custom = npc_items_custom[Object.keys(npc_items_custom)[0]]
var npc_abilities_custom = fs.readFileSync("../../src/game/scripts/npc/npc_abilities_custom.txt", 'utf-8').split("\n");
var abilityFileList = []
for (var i = 0; i < npc_abilities_custom.length; i++) {
	var line = npc_abilities_custom[i].trim();
	if (line.startsWith("#base ")) {
		var filePath = line.replace("#base ", "").slice(0, -1).substring(1);
		try {
			var file = fs.readFileSync("../../src/game/scripts/npc/" + filePath, 'utf-8')
			var data = vdf.parse(file)
			var abilityName = Object.keys(data[Object.keys(data)[0]])[0];
			abilityFileList[abilityName] = "../../src/game/scripts/npc/" + filePath
		} catch (e) {}
	}
}
function DecidePath(ability) {
	if (npc_items_custom[ability]) return "../../src/game/scripts/npc/npc_items_custom.txt";
	if (abilityFileList[ability]) return abilityFileList[ability];
	return "../../src/game/scripts/npc/npc_abilities_override.txt";
}

var abilityNewFlags = {}

//Parse flags
if (flags) {
	flags = flags[Object.keys(flags)[0]]
	for (var groupName in flags) {
		var group = flags[groupName]
		for (var ability in group) {
			if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
			abilityNewFlags[ability].ReduxFlags = abilityNewFlags[ability].ReduxFlags == null ? groupName : abilityNewFlags[ability].ReduxFlags + " | " + groupName
		}
	}
}

//Parse perks
if (perks) {
	perks = perks[Object.keys(perks)[0]]
	for (var groupName in perks) {
		var group = perks[groupName]
		for (var ability in group) {
			if (!(/^\d+$/.test(ability)) && !ability.startsWith("npc_")) {
				if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
				abilityNewFlags[ability].ReduxPerks = abilityNewFlags[ability].ReduxPerks == null ? groupName : abilityNewFlags[ability].ReduxPerks + " | " + groupName
			}
			
		}
	}
}

//Parse balance mode values
if (balance_mode) {
	balance_mode = balance_mode[Object.keys(balance_mode)[0]]
	var tierMap = {
		"tier_1": 120,
		"tier_2": 100,
		"tier_3": 90,
		"tier_4": 80,
		"tier_5": 70,
		"tier_6": 60,
		"tier_7": 50,
		"tier_8": 40,
		"tier_9": 30,
		"tier_10": 20,
		"tier_11": 10,
		"tier_0": -1,
	}
	for (var groupName in balance_mode) {
		var cost = tierMap[groupName]
		if (cost) {
			for (var ability in balance_mode[groupName]) {
				if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
				abilityNewFlags[ability].ReduxCost = cost
			}
		}
	}
}

//Parse troll combos
if (bans) {
	bans = bans[Object.keys(bans)[0]]
	
	
	for (var banGroup in bans) {
		switch(banGroup) {
			case "BannedCombinations":
				for (var ban_ability in bans[banGroup]) {
					for (var ability in bans.BannedCombinations[ban_ability]) {
						if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
						abilityNewFlags[ability].ReduxBans = abilityNewFlags[ability].ReduxBans == null ? ban_ability : abilityNewFlags[ability].ReduxBans + " | " + ban_ability
					}
				}
				break;
			case "CategoryBans":
				for (var ability in bans[banGroup]) {
					if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
					for (var i in bans.CategoryBans[ability]) {
						var bc = bans.CategoryBans[ability][i]
						abilityNewFlags[ability].ReduxBanCategory = abilityNewFlags[ability].ReduxBanCategory == null ? bc : abilityNewFlags[ability].ReduxBanCategory + " | " + bc
					}
				}
				break;
			//These are just flags
			case "wtfAutoBan":
			case "doNotRandom":
			case "OPSkillsList":
			case "noHero":
			case "SuperOP":
				for (var ability in bans[banGroup]) {
					if (!abilityNewFlags[ability]) abilityNewFlags[ability] = {};
					abilityNewFlags[ability].ReduxFlags = abilityNewFlags[ability].ReduxFlags == null ? banGroup : abilityNewFlags[ability].ReduxFlags + " | " + banGroup
				}
		}
	}

}

//Compile
var compilable = {}
for (var ability in abilityNewFlags) {
	var path = DecidePath(ability)
	if (!compilable[path]) compilable[path] = {};
	compilable[path][ability] = abilityNewFlags[ability]
}

var gdn = require('path').dirname
for (var path in compilable) {
	var input = vdf.parse(fs.readFileSync(path, 'utf-8'))
	var rootKey = Object.keys(input)[0]
	for (var ability in compilable[path]) {
		input[rootKey][ability] = deepmerge(input[rootKey][ability], compilable[path][ability])
	}
	fs.writeFileSync(path, vdf.stringify(input, 87, true));
}
var fs = require('fs')

// Script directories
var settings = require('./settings.json');                  // The settings file
var scriptDir = settings.scriptDir;                         // The directory where dota scripts are placed
var scriptDirOut = settings.scriptDirOut                    // The directory where our files are outputted
var resourcePath = settings.dotaDir + 'dota/resource/';     // The directory to read resource files from
var customDir = settings.customDir;                         // The directory where our mods are read from, to be merged in

// Create the output folder
if(!fs.existsSync(scriptDirOut)) fs.mkdirSync(scriptDirOut);

// Precache generator
fs.readFile(scriptDir+'npc_heroes_source1.txt', function(err, source1) {
    fs.readFile(scriptDir+'npc_heroes_source2.txt', function(err, source2) {
        console.log('Loading source1 heroes...');
        var rootHeroes1 = parseKV(''+source1);
        console.log('Loading source2 heroes...');
        var rootHeroes2 = parseKV(''+source2);

        var precacher = {};

        var newKV = {};

        var ignoreHeroes = {    // These are heroes bots can play as, can't edit those, DOH!
            npc_dota_hero_axe: true,
            npc_dota_hero_bane: true,
            npc_dota_hero_bounty_hunter: true,
            npc_dota_hero_bloodseeker: true,
            npc_dota_hero_bristleback: true,
            npc_dota_hero_chaos_knight: true,
            npc_dota_hero_clinkz: true,
            npc_dota_hero_crystal_maiden: true,
            npc_dota_hero_dazzle: true,
            npc_dota_hero_death_prophet: true,
            npc_dota_hero_dragon_knight: true,
            npc_dota_hero_drow_ranger: true,
            npc_dota_hero_earthshaker: true,
            npc_dota_hero_jakiro: true,
            npc_dota_hero_juggernaut: true,
            npc_dota_hero_kunkka: true,
            npc_dota_hero_lich: true,
            npc_dota_hero_lina: true,
            npc_dota_hero_lion: true,
            npc_dota_hero_luna: true,
            npc_dota_hero_necrolyte: true,
            npc_dota_hero_omniknight: true,
            npc_dota_hero_oracle: true,
            npc_dota_hero_phantom_assassin: true,
            npc_dota_hero_pudge: true,
            npc_dota_hero_razor: true,
            npc_dota_hero_riki: true,
            npc_dota_hero_sand_king: true,
            npc_dota_hero_nevermore: true,
            npc_dota_hero_skywrath_mage: true,
            npc_dota_hero_sniper: true,
            npc_dota_hero_sven: true,
            npc_dota_hero_tidehunter: true,
            npc_dota_hero_tiny: true,
            npc_dota_hero_vengefulspirit: true,
            npc_dota_hero_viper: true,
            npc_dota_hero_warlock: true,
            npc_dota_hero_windrunner: true,
            npc_dota_hero_witch_doctor: true,
            npc_dota_hero_skeleton_king: true,
            npc_dota_hero_zuus: true
        }

        var heroes1 = rootHeroes1.DOTAHeroes;
        var heroes2 = rootHeroes2.DOTAHeroes;
        for(var name in heroes1) {
            if(name == 'Version') continue;
            if(name == 'npc_dota_hero_base') continue;

            var data1 = heroes1[name];
            var data2 = heroes2[name];

            if(!ignoreHeroes[name]) {
                newKV[name+'_lod'] = {
                    override_hero: name,
                    Ability1: 'attribute_bonus'
                }

                for(var i=2;i<=16;++i) {
                    if(heroes1[name]['Ability' + i]) {
                        newKV[name+'_lod']['Ability' + i] = '';
                    }
                }
            }

            // Check if they are melee
            if(data1.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK') {
                if(!newKV[name+'_lod']) {
                    newKV[name+'_lod'] = {
                        override_hero: name
                    }
                }

                // Give them projectile speed + model
                newKV[name+'_lod'].ProjectileSpeed = 1000
                newKV[name+'_lod'].ProjectileModel = 'luna_base_attack'
            }

            // Store precacher data
            precacher['npc_precache_'+name+'_s1'] = {
                BaseClass: 'npc_dota_creep',
                precache: {
                    particlefile: data1.ParticleFile,
                    soundfile: data1.GameSoundsFile
                }
            }

            if(data2) {
                precacher['npc_precache_'+name+'_s2'] = {
                    BaseClass: 'npc_dota_creep',
                    precache: {
                        particle_folder: data2.particle_folder,
                        soundfile: data2.GameSoundsFile
                    }
                }
            }

            // Extra precache stuff
            if(data1.precache) {
                for(var key in data1.precache) {
                    precacher['npc_precache_'+name+'_s1'].precache[key] = data1.precache[key];
                }
            }

            if(data2 && data2.precache) {
                for(var key in data2.precache) {
                    precacher['npc_precache_'+name+'_s2'].precache[key] = data2.precache[key];
                }
            }

            //precacher.precache = precacher.precache+'"soundfile" "'+data.GameSoundsFile+'"\n'
        }

        // Techies override prcaching
        precacher.npc_precache_npc_dota_hero_techies_s2.precache.model = 'models/heroes/techies/fx_techiesfx_mine.vmdl';

        fs.writeFile(scriptDirOut+'precache_data.txt', toKV(precacher), function(err) {
            if (err) throw err;

            console.log('Done saving precacher file!');
        });

        fs.writeFile(scriptDirOut+'npc_heroes_custom.txt', toKV(newKV, 'DOTAHeroes'), function(err) {
            if (err) throw err;

            console.log('Done saving file!');
        });
    });
});

fs.readFile(scriptDir+'items.txt', function(err, itemsRaw) {
    // Convert into something useable
    var items = parseKV(''+itemsRaw).DOTAAbilities;

    var currentID = 2000;
    var currentIDPassive = 3000;
    var newKV = {};
    var newKVPassive = {};
    var outputSkillIDs = '';
    var outputSkillIDsPassive = '';

    for(var itemName in items) {
        if(itemName == 'Version') continue;
        if(itemName.indexOf('recipe') != -1) continue;
        if(itemName.indexOf('winter') != -1) continue;
        if(itemName.indexOf('present') != -1) continue;
        if(itemName.indexOf('greevil') != -1) continue;
        if(itemName.indexOf('halloween') != -1) continue;
        if(itemName.indexOf('mystery') != -1) continue;
        if(itemName.indexOf('courier') != -1) continue;
        if(itemName.indexOf('tango') != -1) continue;
        if(itemName.indexOf('tpscroll') != -1) continue;
        if(itemName.indexOf('ward') != -1) continue;
        if(itemName.indexOf('clarity') != -1) continue;
        if(itemName.indexOf('flask') != -1) continue;
        if(itemName.indexOf('dust') != -1) continue;
        if(itemName.indexOf('bottle') != -1) continue;
        if(itemName.indexOf('smoke') != -1) continue;
        var item = items[itemName];

        var cost = item.ItemCost;
        if(!cost) continue;

        var requiredLevel = Math.floor(cost / 500)+1;

        var store = {
            BaseClass: 'ability_datadriven',
            AbilityBehavior: item.AbilityBehavior,
            AbilityTextureName: 'lod_' + itemName,
            RequiredLevel: requiredLevel,
            MaxLevel: 1,
            OnUpgrade: {
                RunScript: {
                    ScriptFile: 'scripts/vscripts/../abilities/items.lua',
                    Function: 'init'
                }
            },
            OnSpellStart: {
                RunScript: {
                    ScriptFile: 'scripts/vscripts/../abilities/items.lua',
                    Function: 'onUse'
                }
            },
            AbilitySpecial: item.AbilitySpecial
        };

        if(item.AbilityBehavior.indexOf('DOTA_ABILITY_BEHAVIOR_UNIT_TARGET') != -1) {
            store.OnSpellStart.RunScript.Function = 'onUnitTarget';
        }

        if(item.AbilityBehavior.indexOf('DOTA_ABILITY_BEHAVIOR_POINT') != -1) {
            store.OnSpellStart.RunScript.Function = 'onPointTarget';
        }

        if(item.AbilityBehavior.indexOf('DOTA_ABILITY_BEHAVIOR_TOGGLE') != -1) {
            store.OnToggleOn = {
                RunScript: {
                    ScriptFile: 'scripts/vscripts/../abilities/items.lua',
                    Function: 'onToggle'
                }
            };

            store.OnToggleOff = {
                RunScript: {
                    ScriptFile: 'scripts/vscripts/../abilities/items.lua',
                    Function: 'onToggle'
                }
            };

            store.OnUpgrade.RunScript.Function = 'initToggle';
        }

        if(item.AbilityBehavior.indexOf('DOTA_ABILITY_BEHAVIOR_CHANNELLED') != -1) {
            store.OnSpellStart.RunScript.Function = 'onChannel';
        }

        if(item.AbilityUnitTargetType) {
            store.AbilityUnitTargetType = item.AbilityUnitTargetType;
        }

        if(item.AbilityUnitTargetTeam) {
            store.AbilityUnitTargetTeam = item.AbilityUnitTargetTeam;
        }

        if(item.AbilityManaCost) {
            store.AbilityManaCost = item.AbilityManaCost;
        }

        if(item.AbilityCastRange) {
            store.AbilityCastRange = item.AbilityCastRange
        }

        if(item.AbilityCastPoint) {
            store.AbilityCastPoint = item.AbilityCastPoint;
        }

        if(item.AbilityCooldown) {
            store.AbilityCooldown = item.AbilityCooldown;
        }

        if(item.AbilityUnitTargetFlags) {
            store.AbilityUnitTargetFlags = item.AbilityUnitTargetFlags;
        }

        if(item.AbilitySharedCooldown) {
            store.AbilitySharedCooldown = item.AbilitySharedCooldown;
        }

        if(item.AbilityChannelTime) {
            store.AbilityChannelTime = item.AbilityChannelTime;
        }

        if(item.AbilityBehavior.indexOf('DOTA_ABILITY_BEHAVIOR_PASSIVE') != -1) {
            // Passive Item
            newKVPassive['lod_' + itemName] = store;
            delete store.OnSpellStart;

            // Store number
            outputSkillIDsPassive += '"lod_' + itemName+'"    "' + (currentIDPassive++) + '"\n';
        } else {
            // Active item
            newKV['lod_' + itemName] = store;

            // Store number
            outputSkillIDs += '"lod_' + itemName+'"    "' + (currentID++) + '"\n';
        }
    }

    fs.writeFile(scriptDirOut+'ability_items.txt', toKV(newKV), function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });

    fs.writeFile(scriptDirOut+'ability_items_passive.txt', toKV(newKVPassive), function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });

    fs.writeFile(scriptDirOut+'outputSkillIDs.txt', outputSkillIDs+'\n\n'+outputSkillIDsPassive, function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });
});

// CSP Generator

var langs = ['english', 'russian'];
var langIn = {};
var langOut = {};
var specialChar;    // Special character needed for doto encoding

var permutations = {
    // This edits the cooldown of skills
    cooldown: {
        vals: [0, 1, 2, 5],
        func: function(ability, newAb, mult) {
            if(!ability.AbilityCooldown) return null;
            if(mult == 1) return null;

            var cooldowns = ability.AbilityCooldown[0].split(' ');

            for(var i=0; i<cooldowns.length; ++i) {
                if(mult != 0) {
                    cooldowns[i] = r(parseFloat(cooldowns[i])/mult, 1);
                } else {
                    cooldowns[i] = 0.0;
                }
            }

            newAb.AbilityCooldown = cooldowns.join(' ');

            // Return the modified spell
            return newAb;
        }
    },

    manaCost: {
        vals: [0, 1, 2, 5],
        func: function(ability, newAb, mult) {
            if(!ability.AbilityManaCost) return null;
            if(mult == 1) return null;

            var manacosts = ability.AbilityManaCost[0].split(' ');

            for(var i=0; i<manacosts.length; ++i) {
                if(mult != 0) {
                    manacosts[i] = Math.round(parseFloat(manacosts[i])/mult);
                } else {
                    manacosts[i] = 0.0;
                }
            }

            newAb.AbilityManaCost = manacosts.join(' ');

            // Return the modified spell
            return newAb;
        }
    }
};

// Order to apply permutions
var permList = ['cooldown', 'manaCost'];

// Permutate a spell
function permute(spellName, ability, storage) {
    // Build slots list
    var slots = [];
    for(var i=0; i<permList.length; ++i) {
        slots[i] = 0;
    }

    // Grab english
    var english = langIn.english;

    // List of suffixes we found
    var suffixes = [];

    // Loop over all the things we need to apply
    while(slots[slots.length-1] < permutations[permList[permList.length-1]].vals.length) {
        var newSpell = {
            BaseClass: spellName
        };
        var suffix = '';

        var changed = false;
        for(var i=0; i<permList.length; ++i) {
            // Grab a modifier
            var perm = permutations[permList[i]];
            var spellValue = perm.vals[slots[i]];

            // Add to the suffix
            suffix += '_' + spellValue;

            var tempChange = perm.func(ability, newSpell, spellValue);

            if(tempChange != null) {
                newSpell = tempChange;
                changed = true;
            }
        }

        // Store the spell
        if(changed) {
            // Store the spell
            storage[spellName + suffix] = newSpell;

            // Store suffix
            suffixes.push(suffix);
        }

        // Push permution along
        var sel = 0;
        slots[sel]++;
        while(slots[sel] >= permutations[permList[sel]].vals.length) {
            if(slots[sel+1] == null) break;

            slots[sel] = 0;
            slots[++sel]++;
        }
    }

    // Generate language for this spell
    for(var key in english) {
        if(key.indexOf(spellName) != -1) {
            for(var i=0; i<suffixes.length; ++i) {
                var suffix = suffixes[i];
                var newStr = key.replace(spellName, spellName + suffix);
                generateLanguage(newStr, key);
            }
        }
    }
}

// theString is the string we search for and use as a key to store in
// if theString can't be find, search using altString
// search in actual language, if that fails, search in english, if that fails, commit suicide
function generateLanguage(theString, altString) {
    // Grab a reference to english
    var english = langIn.english;

    for(var i=0; i<langs.length; ++i) {
        // Grab a language
        var lang = langs[i];
        var langFile = langIn[lang];
        var storeTo = langOut[lang];

        if(langFile[theString]) {
            storeTo[theString] = langFile[theString];
        } else if(langFile[altString]) {
            storeTo[theString] = langFile[altString];
        } else if(english[theString]) {
            storeTo[theString] = english[theString];
        } else if(english[altString]) {
            storeTo[theString] = english[altString];
        } else {
            console.log('Failed to find ' + theString);
        }
    }
}

//function allPerms
function doCSP() {
    fs.readFile(scriptDir+'npc_abilities.txt', function(err, abilitesRaw) {
        // Convert into something useable
        var abs = parseKV(''+abilitesRaw).DOTAAbilities;

        fs.readFile(customDir+'npc_abilities_custom.txt', function(err, abilitesCustomRaw) {
            // Convert into something useable
            var absCustom = parseKV(''+abilitesCustomRaw).DOTAAbilities;

            fs.readFile(scriptDir+'items.txt', function(err, itemsRaw) {
                // Begin to permute
                console.log('Beginning permutations!');

                // Convert into something useable
                var items = parseKV(''+itemsRaw).DOTAAbilities;

                // New abilities KV
                var newAbs = {};

                // Merge in custom abilities
                for(var key in absCustom) {
                    if(key == 'Version') continue;

                    // Store into our CSP file
                    abs[key] = absCustom[key];

                    // Store into our actual custom file
                    newAbs[key] = absCustom[key];
                }

                // Merge in items
                for(var key in items) {
                    abs[key] = items[key];
                }

                // Loop over all spells
                for(var spellName in abs) {
                    // Spells to simply ignore
                    if(spellName == 'Version') continue;
                    if(spellName == 'ability_base') continue;
                    if(spellName == 'attribute_bonus') continue;
                    if(spellName == 'default_attack') continue;
                    if(spellName.indexOf('recipe') != -1) continue;
                    if(spellName.indexOf('winter') != -1) continue;
                    if(spellName.indexOf('present') != -1) continue;
                    if(spellName.indexOf('greevil') != -1) continue;
                    if(spellName.indexOf('halloween') != -1) continue;
                    if(spellName.indexOf('mystery') != -1) continue;
                    if(spellName.indexOf('courier') != -1) continue;
                    if(spellName.indexOf('tango') != -1) continue;
                    if(spellName.indexOf('tpscroll') != -1) continue;
                    if(spellName.indexOf('ward') != -1) continue;
                    if(spellName.indexOf('clarity') != -1) continue;
                    if(spellName.indexOf('flask') != -1) continue;
                    if(spellName.indexOf('dust') != -1) continue;
                    if(spellName.indexOf('bottle') != -1) continue;
                    if(spellName.indexOf('smoke') != -1) continue;

                    var newSpell = {};

                    // Store all permutions of the spell
                    permute(spellName, abs[spellName], newAbs);
                }

                // Output new abs file
                fs.writeFile(scriptDirOut+'npc_abilities_custom.txt', toKV(newAbs, 'DOTAAbilities'), function(err) {
                    if (err) throw err;

                    console.log('Done saving file compiled abilities file.');
                });

                // Output language files
                for(var i=0; i<langs.length; ++i) {
                    (function(lang) {
                        fs.writeFile(scriptDirOut+'addon_' + lang + '.txt', specialChar + toKV({Tokens: langOut[lang]}, 'lang'), 'utf16le', function(err) {
                            if (err) throw err;

                            console.log('Finished saving ' + lang + '!');
                        });
                    })(langs[i]);
                }
            });
        });
    });
}

/*
    Helper functions
*/

// Round to places decimal places
function r(value, places) {
    for(var i=0; i<places; i++) {
        value *= 10;
    }

    value = Math.round(value);

    for(var i=0; i<places; i++) {
        value /= 10;
    }

    return value;
}

/*
Parses most of a KV file

Mostly copied from here:
https://github.com/Matheus28/KeyValue/blob/master/m28/keyvalue/KeyValue.hx
*/
var TYPE_BLOCK = 0;
function parseKV(data) {
    // Make sure we have some data to work with
    if(!data) return null;

    var tree = [{}];
    var treeType = [TYPE_BLOCK];
    var keys = [null];

    var i = 0;
    var line = 1;

    while(i < data.length) {
        var chr = data.charAt(i);

        if(chr == ' ' || chr == '\t') {
            // Ignore white space
        } else if(chr == '\n') {
            // We moved onto the next line
            line++;
            if(data.charAt(i+1) == '\r') i++;
        } else if(chr == '\r') {
            // We moved onto the next line
            line++;
            if(data.charAt(i+1) == '\n') i++;
        } else if(chr == '/') {
            if(data.charAt(i+1) == '/') {
                // We found a comment, ignore rest of the line
                while(++i < data.length) {
                    chr = data.charAt(i);

                    // Check for new line
                    if(chr == '\n') {
                        if(data.charAt(i+1) == '\r') ++i;
                        break;
                    }
                    if(chr == '\r') {
                        if(data.charAt(i+1) == '\n') ++i;
                        break;
                    }
                }

                // We are on a new line
                line++;
            }
        } else if(chr == '"') {
            var resultString = '';
            i++;

            while(i < data.length) {
                chr = data.charAt(i);
                if(chr == '"') break;

                if(chr == '\n') {
                    // We moved onto the next line
                    line++;
                    if(data.charAt(i+1) == '\r') i++;
                } else if(chr == '\r') {
                    // We moved onto the next line
                    line++;
                    if(data.charAt(i+1) == '\n') i++;
                } else if(chr == '\\') {
                    i++;
                    // Gran the mext cjaracter
                    chr = data.charAt(i);

                    // Check for escaped characters
                    switch(chr) {
                        case '\\':chr = '\\'; break;
                        case '"': chr = '"'; break;
                        case '\'': chr = '\''; break;
                        case 'n': chr = '\n'; break;
                        case 'r': chr = '\r'; break;
                        default:
                            chr = '\\';
                            i--;
                        break;
                    }
                }

                resultString += chr;
                i++;
            }

            if (i == data.length || chr == '\n' || chr == '\r') throw new Error("Unterminated string at line " + line);

            if(treeType[treeType.length - 1] == TYPE_BLOCK){
                if (keys[keys.length - 1] == null) {
                    keys[keys.length - 1] = resultString;
                }else {
                    if(tree[tree.length - 1][keys[keys.length - 1]] == null) {
                        tree[tree.length - 1][keys[keys.length - 1]] = [];
                    }
                    tree[tree.length - 1][keys[keys.length - 1]].push(resultString);
                    keys[keys.length - 1] = null;
                }
            }

            // Check if we need to reparse the character that ended this string
            if(chr != '"') --i;
        } else if(chr == '{') {
            if(treeType[treeType.length - 1] == TYPE_BLOCK){
                if (keys[keys.length - 1] == null) {
                    throw new Error("A block needs a key at line " + line + " (offset " + i + ")");
                }
            }

            tree.push({});
            treeType.push(TYPE_BLOCK);
            keys.push(null);
        } else if (chr == '}') {
            if (tree.length == 1) {
                throw new Error("Mismatching bracket at line " + line + " (offset " + i + ")");
            }
            if (treeType.pop() != TYPE_BLOCK) {
                throw new Error("Mismatching brackets at line " + line + " (offset " + i + ")");
            }
            keys.pop();
            var obj = tree.pop();

            if(treeType[treeType.length - 1] == TYPE_BLOCK){
                tree[tree.length - 1][keys[keys.length - 1]] = obj;
                keys[keys.length - 1] = null;
            }else {
                tree[tree.length - 1].push(obj);
            }
        } else {
            console.log("Unexpected character \"" + chr + "\" at line " + line + " (offset " + i + ")");

            // Skip to next line
            while(++i < data.length) {
                chr = data.charAt(i);

                // Check for new line
                if(chr == '\n') {
                    if(data.charAt(i+1) == '\r') ++i;
                    break;
                }
                if(chr == '\r') {
                    if(data.charAt(i+1) == '\n') ++i;
                    break;
                }
            }

            // We are on a new line
            line++;

            // Move onto the next char
            i++;
        }

        i++;
    }

    if (tree.length != 1) {
        throw new Error("Missing brackets");
    }

    return tree[0];
}

function escapeString(str) {
    return str.replace(/\\/g, '\\\\').replace(/\"/g, '\\"').replace(/\n/g, '\\n');
}

function toKV(obj, key) {
    var myStr = '';

    if(obj == null) {
        // Nothing to return
        return '';
    } else if (typeof obj == 'number') {
        return '"' + escapeString(key) + '""' + obj + '"';
    } else if (typeof obj == 'boolean') {
        return '"' + escapeString(key) + '""' + obj + '"';
    } else if (typeof obj == 'string') {
        return '"' + escapeString(key) + '""' + obj + '"';
    } else if(obj instanceof Array) {
        // An array of strings
        for(var i=0; i<obj.length; i++) {
            myStr = myStr + '"' + escapeString(key) + '" "' + escapeString(obj[i]) + '"';
        }

        return myStr;
    } else {
        // An object
        for(var entry in obj) {
            myStr += toKV(obj[entry], entry)
        }

        if(key != null) {
            return '"' + escapeString(key) + '"{\n' + myStr + '}';
        } else {
            return myStr;
        }
    }
}

// Read in our language files
(function() {
    var ourData = ''+fs.readFileSync(customDir + 'addon_english.txt');
    var english = parseKV(ourData).lang.Tokens;

    specialChar = fs.readFileSync(resourcePath + 'dota_english.txt', 'utf16le').substring(0, 1);

    for(var i=0; i<langs.length; ++i) {
        // Grab a language
        var lang = langs[i];

        var data = fs.readFileSync(resourcePath + 'dota_' + lang + '.txt', 'utf16le').substring(1);

        // Load her up
        langIn[lang] = parseKV(data).lang.Tokens;
        langOut[lang] = {};

        var toUse;
        if(fs.existsSync(customDir + 'addon_' + lang + '.txt')) {
            var ourData = ''+fs.readFileSync(customDir + 'addon_' + lang + '.txt');
            toUse = parseKV(ourData).lang.Tokens;
        } else {
            toUse = english;
        }

        for(var key in english) {
            if(toUse[key]) {
                langOut[lang][key] = toUse[key];
            } else {
                langOut[lang][key] = english[key];
            }
        }
    }

    console.log('Done loading languages!');
})();

// Do CSP stuff
doCSP();

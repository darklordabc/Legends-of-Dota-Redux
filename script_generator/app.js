var fs = require('fs')

// Script directories
var settings = require('./settings.json');                  // The settings file
var scriptDir = settings.scriptDir;                         // The directory where dota scripts are placed
var scriptDirOut = settings.scriptDirOut                    // The directory where our files are outputted
var resourcePath = settings.dotaDir + 'dota/resource/';     // The directory to read resource files from
var customDir = settings.customDir;                         // The directory where our mods are read from, to be merged in

// Code needed to do multipliers
var spellMult = require('./spellMult.json');

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
            npc_dota_hero_alchemist: true,
            npc_dota_hero_axe: true,
            npc_dota_hero_antimage: true,
            npc_dota_hero_bane: true,
            npc_dota_hero_batrider: true,
            npc_dota_hero_beastmaster: true,
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
            npc_dota_hero_techies: true,
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
    // Global multiplier
    multiplier: {
        vals: [5, 10, 20],
        func: function(spellName, ability, newAb, mult) {
            function divide(specialName, vals) {
                for(var i=0; i<vals.length; ++i) {
                    vals[i] = parseFunction(vals[i] / mult);
                }

                return vals.join(' ');
            }

            function multiply(specialName, vals) {
                // Check if there is a max
                var max = null;
                if(spellMult.specific_max_value[specialName]) {
                    max = parseFunction(spellMult.specific_max_value[specialName]);
                }
                if(spellMult.more_specific_max_value[spellName] && spellMult.more_specific_max_value[spellName][specialName]) {
                    max = parseFunction(spellMult.more_specific_max_value[spellName][specialName]);
                }

                // Do the mult
                for(var i=0; i<vals.length; ++i) {
                    vals[i] = parseFunction(vals[i] * mult);

                    // Enfore the max
                    if(max != null && vals[i] > max) {
                        vals[i] = max;
                    }
                }

                return vals.join(' ');
            }

            function divide_or_multiply(specialName, valString, parseFunction) {
                var vals = valString.split(' ');

                // Convert all to floats
                for(var i=0; i<vals.length; ++i) {
                    vals[i] = parseFunction(vals[i]);
                }

                // Check for specific values
                if(spellMult.fixed_value[spellName] && spellMult.fixed_value[spellName][specialName]) {
                    return spellMult.fixed_value[spellName][specialName];
                }

                // Should we always divide this attribute?
                if(spellMult.force_divide[specialName]) {
                    return divide(specialName, vals);
                }

                // Check if we need to multiply or divide
                if(vals.length > 1) {
                    // Check if we are increasing, or decreasing
                    if(vals[0] > vals[1]) {
                        // Decreasing, divide
                        return divide(specialName, vals, parseFunction);
                    } else {
                        // Increasing, multiply
                        return multiply(specialName, vals, parseFunction);
                    }
                } else {
                    // Only one value, assume multiply
                    return multiply(specialName, vals, parseFunction);
                }
            }

            for(var key in newAb) {
                (function(key) {
                    if(newAb[key] != null && !spellMult.ignore_all_normal[key] && !isNaN(parseInt(newAb[key][0]))) {
                        function divide2(vals, parseFunction) {
                            for(var i=0; i<vals.length; ++i) {
                                vals[i] = parseFunction(vals[i] / mult);
                            }

                            return vals.join(' ');
                        }

                        function multiply2(vals, parseFunction) {
                            // Do the mult
                            for(var i=0; i<vals.length; ++i) {
                                vals[i] = parseFunction(vals[i] * mult);
                            }

                            return vals.join(' ');
                        }

                        function divide_or_multiply2(valString, parseFunction) {
                            var vals = valString.split(' ');

                            // Convert all to floats
                            for(var i=0; i<vals.length; ++i) {
                                vals[i] = parseFunction(vals[i]);
                            }

                            // Check if we need to multiply or divide
                            if(vals.length > 1) {
                                // Check if we are increasing, or decreasing
                                if(vals[0] > vals[1]) {
                                    // Decreasing, divide
                                    return divide2(vals, parseFunction);
                                } else {
                                    // Increasing, multiply
                                    return multiply2(vals, parseFunction);
                                }
                            } else {
                                // Only one value, assume multiply
                                return multiply2(vals, parseFunction);
                            }
                        }

                        // Do it
                        newAb[key] = [divide_or_multiply2(newAb[key][0], function(str) {
                            // Decide if it's a float or int
                            return parseInt(str);
                        })];
                    }
                })(key);
            }

            if(ability.AbilitySpecial) {
                for(var slotNum in ability.AbilitySpecial) {
                    var slot = ability.AbilitySpecial[slotNum];
                    var parseFunction = parseInt;
                    if(slot.var_type) {
                        if(slot.var_type == 'FIELD_FLOAT') {
                            parseFunction = function(str) {
                                var retNum = parseFloat(str);

                                retNum *= 100;
                                retNum = Math.floor(retNum);
                                retNum = retNum / 100;

                                return retNum;
                            };
                        } else if(slot.var_type != 'FIELD_INTEGER') {
                            console.log('Unknown field type: ' + slot.var_type);
                        }
                    }
                    for(var specialName in slot) {
                        if(specialName == 'var_type') continue;

                        // Check for ignores
                        if(spellMult.ignore_all_special[specialName]) continue;
                        if(spellMult.ignore_special[spellName] && spellMult.ignore_special[spellName][specialName]) continue;

                        var oldVal = slot[specialName][0];
                        var newVal = divide_or_multiply(specialName, oldVal, parseFunction);

                        // Did we actually change anything?
                        if(newVal != oldVal) {
                            // Store the change
                            newAb.AbilitySpecial[slotNum][specialName] = [newVal];
                        }
                    }
                }
            }

            // Return the changes
            return newAb;
        }
    }

    // This edits the cooldown of skills
    /*cooldown: {
        vals: [0, 1, 2, 5],
        func: function(spellName, ability, newAb, mult) {
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
        func: function(spellName, ability, newAb, mult) {
            if(!ability.AbilityManaCost) return null;
            if(mult == 1) return null;

            var manacosts = ability.AbilityManaCost[0].split(' ');

            for(var i=0; i<manacosts.length; ++i) {
                if(mult != 0) {
                    manacosts[i] = Math.round(parseInt(manacosts[i])/mult);
                } else {
                    manacosts[i] = 0.0;
                }
            }

            newAb.AbilityManaCost = manacosts.join(' ');

            // Return the modified spell
            return newAb;
        }
    },

    damage: {
        vals: [1, 2, 5],
        func: function(spellName, ability, newAb, mult) {
            if(!ability.AbilitySpecial) return null;
            if(mult == 1) return null;

            var abSpec = ability.AbilitySpecial;

            var doMult = {
                damage: true,
                damage_scepter: true,
                bonus_damage: true,
                ward_damage_tooltip: true,
                strike_damage: true,
                tick_damage: true
            };

            var changed = false;
            for(var specNum in abSpec) {
                var spec = abSpec[specNum];

                for(var keyName in spec) {
                    if(keyName == 'var_type') continue;

                    if(doMult[keyName]) {
                        var vals = spec[keyName][0].split(' ');

                        for(var i=0; i<vals.length; ++i) {
                            vals[i] = Math.round(parseInt(vals[i])*mult);
                        }

                        newAb.AbilitySpecial[specNum][keyName] = vals.join(' ');
                        changed = true;
                    }
                }
            }

            // Did we even change anything?
            if(!changed) return null;

            // Return the modified spell
            return newAb;
        }
    }*/
};

// Order to apply permutions
var permList = ['multiplier'];

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
    var appendsOnEnd = [];

    // Loop over all the things we need to apply
    while(slots[slots.length-1] < permutations[permList[permList.length-1]].vals.length) {
        var newSpell = {
            BaseClass: spellName,
            //AbilityType: ability.AbilityType,
            AbilityBehavior: ability.AbilityBehavior,
            AbilitySpecial: clone(ability.AbilitySpecial)
        };
        if(ability.AbilityUnitDamageType) newSpell.AbilityUnitDamageType = ability.AbilityUnitDamageType;

        // Copy over useful things
        if(ability.BaseClass) newSpell.BaseClass = ability.BaseClass;
        for(var key in ability) {
            if(!newSpell[key]) newSpell[key] = ability[key];
        }

        // Don't store the spellID
        delete newSpell.ID;

        var suffix = '';
        var appendOnEnd = '';

        //var changed = false;
        for(var i=0; i<permList.length; ++i) {
            // Grab a modifier
            var perm = permutations[permList[i]];
            var spellValue = perm.vals[slots[i]];

            // Add to the suffix
            suffix += '_' + spellValue;
            appendOnEnd += ' x' + spellValue;

            var tempChange = perm.func(spellName, ability, newSpell, spellValue);

            if(tempChange != null) {
                newSpell = tempChange;
                //changed = true;
            }
        }

        // Store the spell
        //if(changed) {
            // Store the spell
            storage[spellName + suffix] = newSpell;

            // Store suffix
            suffixes.push(suffix);
            appendsOnEnd.push(appendOnEnd);
        //}

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
                var appendOnEnd = '';
                if(key.toLowerCase() == 'dota_tooltip_ability_' + spellName) {
                    appendOnEnd = appendsOnEnd[i];
                }

                var suffix = suffixes[i];
                var newStr = key.replace(spellName, spellName + suffix);
                generateLanguage(newStr, key, appendOnEnd);
            }
        }
    }
}

// theString is the string we search for and use as a key to store in
// if theString can't be find, search using altString
// search in actual language, if that fails, search in english, if that fails, commit suicide
function generateLanguage(theString, altString, appendOnEnd) {
    // Grab a reference to english
    var english = langIn.english;

    if(appendOnEnd == null) appendOnEnd = '';

    if(altString == 'lod_item_quelling_blade') {
        console.log(theString);
    }

    for(var i=0; i<langs.length; ++i) {
        // Grab a language
        var lang = langs[i];
        var langFile = langIn[lang];
        var storeTo = langOut[lang];

        if(langFile[theString]) {
            storeTo[theString] = langFile[theString] + appendOnEnd;
        } else if(langFile[altString]) {
            storeTo[theString] = langFile[altString] + appendOnEnd;
        } else if(english[theString]) {
            storeTo[theString] = english[theString] + appendOnEnd;
        } else if(english[altString]) {
            storeTo[theString] = english[altString] + appendOnEnd;
        } else if(storeTo[altString]) {
            storeTo[theString] = storeTo[altString] + appendOnEnd;
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
                var newItems = {};

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
                if(!settings.noPermute) {
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
                        if(spellMult.dont_parse[spellName]) continue;

                        var newSpell = {};

                        // Where to store the spell/item into
                        var storeLocation = newAbs;
                        if(items[spellName]) {
                            storeLocation = newItems;
                        }

                        // Store all permutions of the spell
                        permute(spellName, abs[spellName], storeLocation);
                    }
                }

                // Output new abs file
                fs.writeFile(scriptDirOut+'npc_abilities_custom.txt', toKV(newAbs, 'DOTAAbilities'), function(err) {
                    if (err) throw err;

                    console.log('Done saving file compiled abilities file.');
                });

                // Merge in the custom items
                fs.readFile(customDir+'npc_items_custom.txt', function(err, abilitesCustomRaw) {
                    // Convert into something useable
                    var customItems = parseKV(''+abilitesCustomRaw).DOTAAbilities;

                    // Ensure none of our generated items are buyable
                    for(var key in newItems) {
                        newItems[key].ItemPurchaseable = 0;
                    }

                    // Copy across the custom items
                    for(var key in customItems) {
                        newItems[key] = customItems[key];
                    }

                    // Output updated items file
                    fs.writeFile(scriptDirOut+'npc_items_custom.txt', toKV(newItems, 'DOTAAbilities'), function(err) {
                        if (err) throw err;

                        console.log('Done saving file compiled abilities file.');
                    });
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

function clone(x) {
   if (x === null || x === undefined)
        return x;
    if (x.clone)
        return x.clone();
    if (x.constructor == Array)
    {
        var r = [];
        for (var i=0,n=x.length; i<n; i++)
            r.push(clone(x[i]));
        return r;
    }
    if(typeof(x) == 'object') {
        var y = {};
        for(var key in x) {
            y[key] = clone(x[key]);
        }
        return y;
    }
    return x;
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
    return str.replace(/\\/gm, '\\\\').replace(/\"/gm, '\\"').replace(/(\r\n|\n|\r|\n\r)/gm, '\\n');
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
        return '"' + escapeString(key) + '""' + escapeString(obj) + '"';
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

        for(var key in toUse) {
            if(!langIn[lang][key]) {
                langIn[lang][key] = toUse[key];
            }
        }
    }

    console.log('Done loading languages!');
})();

// Do CSP stuff
doCSP();

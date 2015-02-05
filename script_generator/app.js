var fs = require('fs')

var TYPE_BLOCK = 0;
var TYPE_ARRAY = 1;

/*
Parses most of a KV file

Mostly copied from here:
https://github.com/Matheus28/KeyValue/blob/master/m28/keyvalue/KeyValue.hx
*/
function parseKV(data) {
    // Make sure we have some data to work with
    if(!data) return null;

    var tree = [{}];
    var treeType = [TYPE_BLOCK];
    var keys = [null];

    var i = 1;
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
                    if(chr == '\n' || chr == '\r') break;
                }

                // We are on a new line
                line++;

                // Move onto the next char
                i++;
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
                    tree[tree.length - 1][keys[keys.length - 1]] = resultString;
                    keys[keys.length - 1] = null;
                }
            }else if (treeType[treeType.length - 1] == TYPE_ARRAY) {
                tree[tree.length - 1].push(resultString);
            }

            // Check if we need to reparse the character that ended this string
            if(chr != '"') --i;
        /*} else if(chr >= '0' && chr <= '9') {
            var startIndex = i++;
            while (i < data.length) {
                chr = data.charAt(i);
                if ((chr < '0' || chr > '9') && chr != '.' && chr != 'x') break;
                i++;
            }

            var resultNumber = parseInt(data.substr(startIndex, i - startIndex));
            if (resultNumber == null) throw new Error("Invalid number at line " + line + " (offset " + i + ")");

        */
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
                if(chr == '\n' || chr == '\r') break;
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

/*function isIdentifier(str) {
    return (~/^[a-zA-Z$_-][a-zA-Z0-9$_-]*$/).match(str);
}

function escapeString(str) {
    return str;//StringTools.replace(StringTools.replace(StringTools.replace(StringTools.replace(str, '\\', '\\\\'), '"', '\\"'), '\r', '\\r'), '\n', '\\n');
}*/

function isKeyword(str) {
    switch(str) {
        case 'true': return true;
        case 'false': return true;
        case 'null': return true;
        case 'undefined': return true;
        default: return false;
    }
}

function toKV(obj, root) {
    if (obj == null) {
        return '"null"';
    } else if (typeof obj == 'number') {
        return '"'+obj.toString()+'"';
    } else if (typeof obj == 'boolean') {
        return '"'+obj.toString()+'"';
    } else if (typeof obj == 'string') {
        /*if (isKeyword(obj) || !isIdentifier(obj)) {
            return '"' + escapeString(obj) + '"';
        }else {
            return obj;
        }*/
        return '"'+obj+'"';
    } else if (obj instanceof Array) {
        return '"'+obj.join(' ')+'"';
    }else {
        var str = '';
        if (!root) {
            str += '{';
        }
        var first = true;
        for(var i in obj) {
            if(!first) {
                str += ' ';
            }
            first = false;
            str += toKV(i, false)+' '+toKV(obj[i], false);
        }

        if (!root) {
            str += '}';
        }

        return str;
    }
}

// Script directories
var settings = require('./settings.json');
var scriptDir = settings.scriptDir;
var scriptDirOut = settings.scriptDirOut
var resourcePath = settings.dotaDir + 'dota/resource/';

// Create the output folder
fs.mkdirSync(scriptDirOut);

// Precache generator
fs.readFile(scriptDir+'npc_heroes_source1.txt', function(err, source1) {
    fs.readFile(scriptDir+'npc_heroes_source2.txt', function(err, source2) {
        console.log('Loading source1 heroes...');
        var rootHeroes1 = parseKV(''+source1, true);
        console.log('Loading source2 heroes...');
        var rootHeroes2 = parseKV(''+source2, true);

        var precacher = {};

        var newKV = {};

        var ignoreHeroes = {
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

        /*newKV['npc_dota_hero_treant_lod'].Ability4 = 'treant_overgrowth';
        newKV['npc_dota_hero_treant_lod'].Ability5 = 'attribute_bonus';
        newKV['npc_dota_hero_treant_lod'].Ability6 = '';
        newKV['npc_dota_hero_ogre_magi_lod'].Ability4 = 'ogre_magi_multicast';
        newKV['npc_dota_hero_ogre_magi_lod'].Ability5 = 'attribute_bonus';
        newKV['npc_dota_hero_ogre_magi_lod'].Ability6 = '';
        newKV['npc_dota_hero_shredder_lod'].Ability4 = 'attribute_bonus';
        newKV['npc_dota_hero_shredder_lod'].Ability5 = '';
        newKV['npc_dota_hero_shredder_lod'].Ability6 = '';
        newKV['npc_dota_hero_shredder_lod'].Ability7 = '';
        newKV['npc_dota_hero_earth_spirit_lod'].Ability5 = 'earth_spirit_magnetize';
        newKV['npc_dota_hero_earth_spirit_lod'].Ability6 = 'attribute_bonus';
        newKV['npc_dota_hero_earth_spirit_lod'].Ability7 = '';

        newKV['npc_dota_hero_invoker_lod'] = {
            override_hero: 'npc_dota_hero_invoker',
            Ability1: 'attribute_bonus',
            Ability2: '',
            Ability3: '',
            Ability4: '',
            Ability5: '',
            Ability6: '',
            Ability7: '',
            Ability8: '',
            Ability9: '',
            Ability10: '',
            Ability11: '',
            Ability12: '',
            Ability13: '',
            Ability14: '',
            Ability15: '',
            Ability16: '',
        }

        newKV['npc_dota_hero_rubick_lod'] = {
            override_hero: 'npc_dota_hero_rubick',
            Ability1: 'attribute_bonus',
            Ability2: '',
            Ability3: '',
            Ability4: '',
            Ability5: '',
            Ability6: '',
            Ability7: '',
            Ability8: '',
            Ability9: '',
            Ability10: '',
            Ability11: ''
        }

        newKV['npc_dota_hero_keeper_of_the_light_lod'] = {
            override_hero: 'npc_dota_hero_keeper_of_the_light',
            Ability1: 'attribute_bonus',
            Ability2: '',
            Ability3: '',
            Ability4: '',
            Ability5: '',
            Ability6: '',
            Ability7: '',
            Ability8: '',
            Ability9: '',
            Ability10: '',
            Ability11: ''
        }

        newKV['npc_dota_hero_wisp_lod'] = {
            override_hero: 'npc_dota_hero_wisp',
            Ability1: 'attribute_bonus',
            Ability2: '',
            Ability3: '',
            Ability4: '',
            Ability5: '',
            Ability6: '',
            Ability7: '',
            Ability8: '',
            Ability9: '',
            Ability10: '',
            Ability11: ''
        }*/

        fs.writeFile(scriptDirOut+'precache_data.txt', toKV(precacher, true), function(err) {
            if (err) throw err;

            console.log('Done saving precacher file!');
        });

        fs.writeFile(scriptDirOut+'npc_heroes_custom.txt', toKV({DOTAHeroes: newKV}, true), function(err) {
            if (err) throw err;

            console.log('Done saving file!');
        });
    });
});

fs.readFile(scriptDir+'items.txt', function(err, itemsRaw) {
    // Convert into something useable
    var items = parseKV(''+itemsRaw, true).DOTAAbilities;

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

    fs.writeFile(scriptDirOut+'ability_items.txt', toKV(newKV, true), function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });

    fs.writeFile(scriptDirOut+'ability_items_passive.txt', toKV(newKVPassive, true), function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });

    fs.writeFile(scriptDirOut+'outputSkillIDs.txt', outputSkillIDs+'\n\n'+outputSkillIDsPassive, function(err) {
        if (err) throw err;

        console.log('Done saving file!');
    });
});

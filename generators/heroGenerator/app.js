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

var scriptDir = '';

// Item + Skill modifier
fs.readFile(scriptDir+'npc_heroes_source1.txt', function(err, source1) {
    fs.readFile(scriptDir+'npc_heroes_source2.txt', function(err, source2) {
        var rootHeroes1 = parseKV(''+source1, true);
        var rootHeroes2 = parseKV(''+source2, true);

        var precacher = {};

        var newKV = {};

        var heroes1 = rootHeroes1.DOTAHeroes;
        var heroes2 = rootHeroes2.DOTAHeroes;
        for(var name in heroes1) {
            if(name == 'Version') continue;
            if(name == 'npc_dota_hero_base') continue;

            var data1 = heroes1[name];
            var data2 = heroes2[name];

            newKV[name+'_lod'] = {
                override_hero: name//,
                //AbilityLayout: '6'
            }

            // Check if they are melee
            if(data1.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK') {
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

        fs.writeFile(scriptDir+'precache_data.txt', toKV(precacher, true), function(err) {
            if (err) throw err;

            console.log('Done saving precacher file!');
        });

        fs.writeFile(scriptDir+'npc_heroes_custom.txt', toKV({DOTAHeroes: newKV}, true), function(err) {
            if (err) throw err;

            console.log('Done saving file!');
        });
    });
});

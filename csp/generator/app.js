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
                }else if(chr == '\\') {
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

function mul(data, value, acc) {
    return data.split(' ').map(function(x) {
        return r(x * value, acc);
    }).join(' ');
}

function div(data, value, acc) {
    return data.split(' ').map(function(x) {
        return r(x / value, acc);
    }).join(' ');
}

var scriptDir = '../scripts/npc/';

var ignore = {
    "ability_base": true,
    "default_attack": true
}

// The multiplier
var mult = 3.0;

var mapFunction = function(ability, field, data) {
    if(field == 'AbilityCooldown' || field == 'AbilityManaCost') {
        return div(data, mult, 1);
    }

    if(field == 'AbilityDamage') {
        return mul(data, mult, 1);
    }

    if(field == 'AbilityCastRange') {
        return mul(data, Math.sqrt(mult), 0);
    }

    return null;
}

var fixthis = {};
function mapAbilitySpecial(ability, field, data) {
    var quickMap = {
        "damage": 1,
        "cooldown_scepter": -1,
        "enfeeble_attack_reduction": 1,
        "fiend_grip_mana_drain": 1,
        "fiend_grip_damage": 1,
        "fiend_grip_mana_drain_scepter": 1,
        "fiend_grip_damage_scepter": 1,
        "damage_increase_pct": 1,
        "health_bonus_pct": 1,
        "health_bonus_creep_pct": 1,
        "bonus_movement_speed": 1,
        "bonus_movement": 1,
        "bonus_damage": 1,
        "movement_damage_pct": 1,
        "damage_cap_amount": 1,
        "silence_radius": 0,
        "trueshot_ranged_damage": 1,
        "marksmanship_agility_bonus": 1,
        "fissure_range": 0,
        "fissure_radius": 0,
        "totem_damage_percentage": 0,
        "aftershock_range": 0,
        "echo_slam_damage_range": 0,
        "echo_slam_echo_search_range": 0,
        "echo_slam_echo_range": 0,
        "echo_slam_echo_damage": 1,
        "blade_dance_crit_mult": 0,
        "blade_fury_radius": 0,
        "healing_ward_heal_amount": 1,
        "healing_ward_aura_radius": 0,
        "omni_slash_damage": 1,
        "omni_slash_jumps": 1,
        "omni_slash_radius": 0,
        "omni_slash_cooldown_scepter": -1,
        "omni_slash_jumps_scepter": 1,
        "radius": 0,
        "damage_bonus": 1,
        "movespeed_bonus": 1,
        "dragon_slave_width_initial": 0,
        "dragon_slave_width_end": 0,
        "dragon_slave_distance": 0,
        "dragon_slave_speed": 0,
        "light_strike_array_aoe": 0,
        "fiery_soul_attack_speed_bonus": 1,
        "fiery_soul_move_speed_bonus": 1,
        "fiery_soul_max_stacks": 1,
        "damage_scepter": 1,
        "cast_range_scepter": 0,
        "width": 0,
        "length": 0,
        "speed": 0,
        //"mana_per_second": 1,
        "break_distance": 0,
        "mana_cost_scepter": -1,
        "cooldown_scepter": -1,
        "splash_radius_scepter": 0,
        "arrow_width": 0,
        "arrow_range": 0,
        "arrow_max_stunrange": 0,
        "arrow_bonus_damage": 1,
        "leap_distance": 0,
        "leap_speed": 0,
        "leap_acceleration": 0,
        "leap_radius": 0,
        "leap_speedbonus": 1,
        "leap_speedbonus_as": 1,
        "starfall_radius": 0,
        "starfall_secondary_radius": 0,
        "damage_min": 1,
        "damage_max": 1,
        "damage_base": 1,
        "bonus_attributes": 1,
        "mana_cost": -1,
        "shadowraze_radius": 0,
        "shadowraze_range": 0,
        "necromastery_damage_per_soul": 1,
        "necromastery_max_souls": 1,
        "necromastery_souls_hero_bonus": 1,
        "presence_radius": 0,
        "requiem_radius": 0,
        "requiem_reduction_damage": 1,
        "requiem_reduction_tooltip": 1,
        "requiem_reduction_radius": 0,
        "requiem_line_width_start": 0,
        "requiem_line_width_end": 0,
        "requiem_line_speed": 0,
        "lance_speed": 0,
        "max_illusions": 0,
        "max_distance": 0,
        "orb_speed": 0,
        "orb_vision": 0,
        "coil_radius": 0,
        "coil_break_radius": 0,
        "coil_break_damage": 1,
        "coil_break_damage_scepter": 1,
        "flesh_heap_range": 0,
        "hook_speed": 0,
        "hook_width": 0,
        "hook_distance": 0,
        "vision_radius": 0,
        "rot_radius": 0,
        "dismember_damage": 1,
        "strength_damage_scepter": 1,
        "start_radius": 0,
        "end_radius": 0,
        "end_distance": 0,
        "targets": 1,
        "damage": 1,
        "total_damage": 1,
        "full_splash_radius": 0,
        "mid_splash_radius": 0,
        "min_splash_radius": 0,
        "damage_min_scepter": 1,
        "damage_max_scepter": 1,
        "drain_rate": 1,
        "drain_range": 0,
        "blast_speed": 0,
        "blast_dot_damage": 1,
        "vampiric_aura_radius": 0,
        "vampiric_aura": 1,
        "crit_mult": 0,
        "slow_radius": 0,
        "range": 0,
        "carrion_swarm_mana_cost_adjust": 1,
        "silence_mana_cost_adjust": 1,
        "exorcism_1_extra_spirits": 1,
        "exorcism_2_extra_spirits": 1,
        "exorcism_3_extra_spirits": 1,
        "spirits": 1,
        "spirit_speed": 0,
        "max_distance": 0,
        "give_up_distance": 0,
        "average_damage": 1,
        "bolt_speed": 0,
        "bolt_aoe": 0,
        "vision_radius": 0,
        "great_cleave_radius": 0,
        "great_cleave_damage": 1,
        "warcry_armor": 1,
        "warcry_radius": 0,
        "gods_strength_damage": 1,
        "static_remnant_radius": 0,
        "static_remnant_damage_radius": 0,
        "static_remnant_damage": 1,
        "electric_vortex_pull_units_per_second": 0,
        "electric_vortex_pull_tether_range": 0,
        "overload_aoe": 0,
        "ball_lightning_initial_mana_percentage": -1,
        "ball_lightning_initial_mana_base": -1,
        "ball_lightning_aoe": 0,
        "ball_lightning_travel_cost_base": -1,
        "ball_lightning_travel_cost_percent": -1,
        "ball_lightning_vision_radius": 0,
        "burrow_width": 0,
        "burrow_speed": 0,
        "tooltip_range": 0,
        "sand_storm_radius": 0,
        "caustic_finale_radius": 0,
        "caustic_finale_damage": 1,
        "epicenter_radius": 0,
        "epicenter_pulses": 1,
        "epicenter_damage": 1,
        "epicenter_pulses_scepter": 1,
        "grab_radius": 0,
        "bonus_damage_pct": 1,
        "grow_bonus_damage_pct": 1,
        "toss_damage": 1,
        "bonus_armor": 1,
        "bonus_damage": 1,
        "grow_bonus_damage_pct": 1,
        "bonus_range_scepter": 0,
        "bonus_cleave_radius_scepter": 0,
        "bonus_cleave_damage_scepter": 1,
        "bonus_building_damage_scepter": 1,
        "grow_bonus_damage_pct_scepter": 1,
        "jump_count": 1,
        "true_sight_radius": 0,
        "sight_radius_day": 0,
        "sight_radius_night": 0,
        "crush_radius": 0,
        "bonus_damage": 1,
        "projectile_speed": 0,
        "damage_reduction": 1,
        "damage_cleanse": -1,
        "damage_reduction": 1,
        "magic_missile_speed": 0,
        "aura_radius": 0,
        "bonus_damage_pct": 1,
        "wave_speed": 0,
        "wave_width": 0,
        "vision_aoe": 0,
        "mana_regen": 1,
        "explosion_radius": 0,
        "explosion_min_dist": 0,
        "explosion_max_dist": 0,
        "shackle_distance": 0,
        "aoe_damage": 0,
        "health_conversion": 1,
        "jumps": 1,
        "jump_range": 0,
        "projectile_speed": 0,
        "cast_range_scepter": 0,
        "bounce_range": 0,
        "hero_damage": 1,
        "bounces": 1,
        "bounces_tooltip": 1,
        //"mana_per_second": -1,
        "heal": 1,
        "damage_multiplier": 1,
        "spawn_count": 1,
        "split_attack_count": -1,
        "eidolon_hp_tooltip": 1,
        "eidolon_dmg_tooltip": 1,
        "damage_percent": 1,
        "pull_radius": 0,
        "pull_speed": 0,
        "far_radius": 0,
        "near_radius": 0,
        "far_damage": 1,
        "near_damage": 1,
        "targets": 1,
        "collision_radius": 0,
        "splash_radius": 0,
        "bonus_attack_range": 0,
        "projectile_speed": 0,
        "area_of_effect": 0,
        "hero_multiplier": 1,
        "health_regen": 1,
        "damage_per_health": 1,
        "damage_per_health_scepter": 1,
        "count": 1,
        "damage_share_percentage": 1,
        "search_aoe": 0,
        "aoe": 0,
        "golem_hp_tooltip": 1,
        "golem_dmg_tooltip": 1,
        "number_of_golems_scepter": 1,
        "damage": 1,
        "spread": 0,
        "strike_damage": 1,
        "blink_range": 0,
        "area_of_effect": 0,
        "starting_aoe": 0,
        "distance": 0,
        "final_aoe": 0,
        "tick_damage": 1,
        "ward_hp_tooltip": 1,
        "ward_damage_tooltip": 1,
        "structure_damage_mod": 1,
        "bonus_spell_damage_pct": 1,
        "health_drain": 1,
        "health_drain_scepter": 1,
        "bonus_range_scepter": 0,
        "bonus_attack_speed": 1,
        "bonus_max_attack_count": 1,
        "crit_bonus": 0,
        "instances": 1,
        "attack_spill_range": 0,
        "attack_spill_width": 0,
        "max_traps": 1,
        "trap_radius": 0,
        "non_hero_damage_pct": 1,
        "max_damage_tooltip": 1,
        "bounces": 1,
        "bonus_night_vision": 0,
        "beams": 1,
        "hit_count": 1,
        "beams_scepter": 1,
        "hit_count_scepter": 1,
        "dragon_cast_range": 0,
        "bonus_health_regen": 1,
        "corrosive_breath_damage": 1,
        "frost_aoe": 0,
        "splash_radius": 0,
        "splash_damage_percent": 1,
        "max_targets": 1,
        "bounce_radius": 0,
        "damage_radius": 0,
        "vision": 0,
        "radius_scepter": 0,
        "attacks_to_destroy": 1,
        "drain_amount": 1,
        "push_length": 0,
        "push_speed": 0,
        "spacing": 0,
        "latch_radius": 0,
        "stun_radius": 0,
        "num_explosions": 1,
        "mana_cost_per_second": -1,
        "vision_range": 0,
        "max_treants": 1,
        "attribute_bonus_per_level": 1,
        "damage_per_burn": 1,
        "mana_per_hit": 1,
        "min_blink_range": 0,
        "mana_void_damage_per_mana": 1,
        "mana_void_aoe_radius": 0,
        "kill_threshold": 1,
        "cooldown": -1,
        "speed_aoe": 0,
        "kill_threshold_scepter": 1,
        "cast_range_tooltip": 0,
        "damage_assist_factor": 1,
        "damage_assist_aoe": 0,
        "visibility_threshold_pct": 0,
        "invis_threshold_pct": 0,
        "fow_range": 0,
        "ghostship_speed": 0,
        "ghostship_width": 0,
        "ghostship_distance": 0,
        "arrow_speed": 0,
        "range_tooltip": 0,
        "morph_cooldown": -1,
        "tooltip_cast_range": 0,
        "fake_lance_distance": 0,
        "ward_count": 1,
        "hp_drain": 1,
        "healing_aura_radius": 0,
        "blink_range": 0,
        "min_blink_range": 0,
        "mana_void_aoe_radius": 0,
        "radius": 0,
        "speed_aoe": 0,
        "cast_range_tooltip": 0,
        "bounce_radius": 0,
        "bonus_gold_self": 1,
        "bonus_gold_radius": 0,
        "attack_speed_bonus": 1,
        "hp_leech_percent": 1,
        "heal_percent": 1,
        "leech_damage": 1,
        "damage_count": 1,
        "damage_block": 1,
        "heal": 1,
        "attrib_bonus": 1,
        "hurt_attrib_bonus": 1,
        "hurt_percent": 1,
        "tooltip_attrib_bonus": 1,
        "tooltip_hurt_attrib_bonus": 1,
        "health_cost": -1,
        "attack_speed_bonus_per_stack": 1,
        "health_cost_percent": -1,
        "charge_speed": 0,
        "tooltip_health_cost_percent": -1,
        "damage_per_unit": 1,
        "attack_speed": 1,
        "hp_regen": 1,
        "reward_damage": 1,
        "bonus_regen": 1,
        "bonus_chance_damage": 1,
        "bonus_speed": 1,
        "damage_bonus": 1,
        "damage_bonus_ranged": 1,
        "damage_block_melee": 1,
        "damage_block_ranged": 1,
        "bonus_strength": 1,
        "bonus_agility": 1,
        "bonus_intellect": 1,
        "bonus_all_stats": 1,
        "lifesteal_percent": 1,
        "bonus_mana_regen": 1,
        "health_restore": 1,
        "mana_restore": 1,
        "max_charges": 1,
        "charge_radius": 0,
        "restore_per_charge": 1,
        "total_mana": 1,
        "total_health": 1,
        "health": 1,
        "true_sight_range": 0,
        "total_heal": 1,
        "minimun_distance": 0,
        "maximum_distance": 0,
        "bonus_stat": 1,
        "bonus_attack_speed": 1,
        "bonus_gold": 1,
        "xp_multiplier": 1,
        "aura_radius": 0,
        "aura_health_regen": 0,
        "heal_amount": 1,
        "heal_radius": 0,
        "heal_bonus_armor": 1,
        "damage_aura": 0,
        "armor_aura": 1,
        "mana_regen_aura": 1,
        "bonus_aoe_radius": 0,
        "bonus_aoe_armor": 0,
        "aura_mana_regen": 1,
        "aura_bonus_armor": 1,
        "barrier_radius": 0,
        "barrier_block": 1,
        "soul_radius": 0,
        "soul_initial_charge": 1,
        "soul_additional_charges": 1,
        "soul_heal_amount": 1,
        "soul_damage_amount": 1,
        "silence_damage_percent": 1,
        "push_length": 0,
        "warrior_truesight": 0,
        "warrior_mana_feedback": 1,
        "archer_attack_speed": 1,
        "archer_mana_burn": 1,
        "archer_attack_speed_radius": 0,
        "aura_attack_speed": 1,
        "aura_positive_armor": 1,
        "aura_negative_armor": 1,
        "health_regen_rate": 1,
        "cooldown_melee": -1,
        "model_scale": 1,
        "blast_radius": 0,
        "blast_speed": 0,
        "blast_damage": 1,
        "charge_range": 0,
        "heal_on_death_range": 0,
        "heal_on_death_base": 1,
        "heal_on_death_per_charge": 1,
        "vision_on_death_radius": 0,
        "respawn_time_reduction": 1,
        "death_gold_reduction": 1,
        "bash_damage": 1,
        "crit_multiplier": 0,
        "cleave_radius": 0,
        "cleave_damage_percent": 1,
        "images_count": 1,
        "unholy_bonus_damage": 1,
        "unholy_bonus_attack_speed": 1,
        "unholy_bonus_strength": 1,
        "unholy_health_drain": -1,
        "windwalk_bonus_damage": 1,
        "movement_speed_percent_bonus": 1,
        "unholy_lifesteal_percent": 1,
        "static_strikes": 1,
        "static_damage": 1,
        "static_primary_radius": 0,
        "static_seconary_radius": 0,
        "static_radius": 0,
        "static_cooldown": -1,
        "chain_damage": 1,
        "chain_strikes": 1,
        "chain_radius": 0,
        "corruption_armor": 1,
        "berserk_bonus_attack_speed": 1,
        "berserk_bonus_movement_speed": 1,
        "berserk_extra_damage": 1,
        "initial_charges": 1,
        "feedback_mana_burn": 1,
        "blast_agility_multiplier": 1,
        "blast_damage_base": 1,
        "ethereal_damage_bonus": 1,
        "health_sacrifice": -1,
        "mana_gain": 1,
        "replenish_radius": 0,
        "replenish_amount": 1,
        "poison_damage": 1,
        "bonus_aura_attack_speed_pct": 1,
        "bonus_aura_movement_speed_pct": 1,
        "bonus_attack_speed_pct": 1,
        "bonus_movement_speed_pct": 1,
        "bonus_mana_regen_pct": 1,
        "shock_radius": 0,
        "max_attacks": 1,
        "attack_speed_bonus_pct": 1,
        "damage_per_stack": 1,
        "life_damage_bonus_percent": 1,
        "rockets_per_second": 1,
        "min_damage": 1,
        "pre_flight_time": -1,
        "hero_damage": 1,
        "acceleration": 0,
        "damage_first": 1,
        "damage_second": 1,
        "damage_second_scepter": 1,
        "armor_reduction": 1,
        "max_damage": 1,
        "bonus_bonus_gold": 1,
        "bonus_gold_cap": 1,
        "base_attack_time": -1,
        "bonus_health": 1,
        "tooltip_clones": 1,
        "tooltip_share_percentage": 1,
        "tooltip_share_percentage_scepter": 1
    }

    var m = quickMap[field] || quickMap['customval_'+field];
    if(m != null) {
        if(m > 0) {
            return mul(data, mult, 1);
        } else if(m < 0) {
            return div(data, mult, 1);
        } else {
            return mul(data, Math.sqrt(mult), 0);
        }
    } else {
        if(field.indexOf('duration') == -1 && field.indexOf('stun') == -1 && field.indexOf('move_speed') == -1 && field.indexOf('cooldown') == -1 && field.indexOf('armor') == -1 && field.indexOf('chance') == -1 && field.indexOf('resistance') == -1 && field.indexOf('slow') == -1 && field.indexOf('speed_bonus') == -1 && field.indexOf('tick') == -1 && field.indexOf('interval') == -1 && field.indexOf('time') == -1 && field.indexOf('animation') == -1 && field.indexOf('knockback') == -1 && field.indexOf('movement_speed') == -1 && field.indexOf('delay') == -1) {
            fixthis[field] = -2;
        }
    }

    return null;
}

fs.readFile(scriptDir+'items.txt', function(err, itemData) {
    var rootItems = parseKV(''+itemData, true);
    var items = rootItems.DOTAAbilities;
    fs.readFile(scriptDir+'npc_abilities.txt', function(err, data) {
        if (err) throw err;

        // Parse ability file
        console.log('Parsing npc data');
        var rootFile = parseKV(''+data);
        var abs = rootFile.DOTAAbilities;

        for(var name in items) {
            abs[name] = items[name];
        }

        for(var name in abs) {
            if(name == "Version") continue;

            // Should we ignore this?
            if(ignore[name]) {
                // Don't encode it
                delete abs[name];
                continue;
            }

            // Grab the ability
            var ab = abs[name];

            // We've removed all fields from this ability
            var removedAll = true;

            // Make changes
            for(var field in ab) {
                if(field == 'AbilitySpecial') {
                    // We haven't changed any special values
                    var changedSpecial = false;

                    // Loop over all special values
                    for(var num in ab[field]) {
                        var d = ab[field][num];
                        for(key in d) {
                            if(key == 'var_type') continue;

                            var ret = mapAbilitySpecial(name, key, d[key]);
                            if(ret == null) {
                                // Delete the field
                                delete ab[field][num];
                            } else {
                                // Store the change
                                d[key] = ret;

                                // We have changed a special value
                                changedSpecial = true;
                            }
                        }
                    }

                    // Did we change any special values?
                    if(!changedSpecial) {
                        // Remove the ability special
                        delete ab[field];
                    } else {
                        removedAll = false;
                    }
                } else {
                     var ret = mapFunction(name, field, ab[field]);
                    if(ret == null) {
                        // Delete the field
                        delete ab[field];
                    } else {
                        // Store the change
                        ab[field] = ret;

                        // We havent removed all
                        removedAll = false;
                    }
                }
            }

            // Did we remove all fields?
            if(removedAll) {
                // Remove this ability
                delete abs[name];
            }
        }

        var newKV = toKV(rootFile, true);

        fs.writeFile(scriptDir+'npc_abilities_override.txt', newKV, function(err) {
            if (err) throw err;

            console.log('Done saving file!');
        });

        fs.writeFile('fixthis.txt', JSON.stringify(fixthis), function(err) {
            if (err) throw err;

            console.log('Done saving fixthis.txt');
        });
    });
});

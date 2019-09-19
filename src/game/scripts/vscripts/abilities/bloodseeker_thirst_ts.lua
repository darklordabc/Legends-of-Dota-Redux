--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
function __TS__ArrayForEach(arr, callbackFn)
    do
        local i = 0
        while i < #arr do
            callbackFn(_G, arr[i + 1], i, arr)
            i = i + 1
        end
    end
end

function __TS__SourceMapTraceBack(fileName, sourceMap)
    _G.__TS__sourcemap = _G.__TS__sourcemap or {}
    _G.__TS__sourcemap[fileName] = sourceMap
    if _G.__TS__originalTraceback == nil then
        _G.__TS__originalTraceback = debug.traceback
        debug.traceback = function(thread, message, level)
            local trace = _G.__TS__originalTraceback(thread, message, level)
            local result = string.gsub(
                trace,
                "(%S+).lua:(%d+)",
                function(file, line)
                    local fileSourceMap = _G.__TS__sourcemap[tostring(file) .. ".lua"]
                    if fileSourceMap and fileSourceMap[line] then
                        return tostring(file) .. ".ts:" .. tostring(fileSourceMap[line])
                    end
                    return tostring(file) .. ".lua:" .. tostring(line)
                end
            )
            return result
        end
    end
end

__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["37"] = 1,["38"] = 3,["39"] = 3,["40"] = 3,["41"] = 3,["42"] = 3,["43"] = 3,["45"] = 3,["47"] = 3,["48"] = 3,["50"] = 3,["51"] = 4,["52"] = 5,["53"] = 4,["54"] = 8,["55"] = 9,["56"] = 10,["57"] = 11,["58"] = 12,["59"] = 13,["61"] = 8,["62"] = 19,["63"] = 19,["64"] = 19,["65"] = 19,["66"] = 19,["67"] = 19,["69"] = 19,["71"] = 19,["72"] = 19,["74"] = 19,["75"] = 20,["76"] = 21,["77"] = 22,["78"] = 22,["79"] = 22,["81"] = 20,["82"] = 26,["83"] = 27,["84"] = 28,["85"] = 29,["86"] = 30,["87"] = 31,["88"] = 32,["89"] = 33,["90"] = 34,["91"] = 34,["92"] = 34,["93"] = 35,["94"] = 36,["95"] = 36,["96"] = 36,["97"] = 36,["99"] = 34,["100"] = 34,["101"] = 40,["102"] = 26,["103"] = 43,["104"] = 44,["105"] = 43,["106"] = 50,["107"] = 51,["108"] = 50,["109"] = 54,["110"] = 55,["111"] = 54,["112"] = 58,["113"] = 59,["114"] = 58,["115"] = 62,["116"] = 63,["117"] = 62,["118"] = 66,["119"] = 67,["120"] = 66,["121"] = 70,["122"] = 71,["123"] = 70,["124"] = 74,["125"] = 75,["126"] = 74,["127"] = 79,["128"] = 79,["129"] = 79,["130"] = 79,["131"] = 79,["132"] = 79,["134"] = 79,["136"] = 79,["137"] = 79,["139"] = 79,["140"] = 80,["141"] = 81,["142"] = 80,["143"] = 84,["144"] = 85,["145"] = 85,["146"] = 85,["147"] = 84});
LinkLuaModifier("modifier_blodseeker_thrist_lod_buff", "abilities/bloodseeker_thirst_ts.lua", LUA_MODIFIER_MOTION_NONE)
bloodseeker_thirst_lod = {}
bloodseeker_thirst_lod.name = "bloodseeker_thirst_lod"
bloodseeker_thirst_lod.__index = bloodseeker_thirst_lod
bloodseeker_thirst_lod.prototype = {}
bloodseeker_thirst_lod.prototype.__index = bloodseeker_thirst_lod.prototype
bloodseeker_thirst_lod.prototype.constructor = bloodseeker_thirst_lod
function bloodseeker_thirst_lod.new(...)
    local self = setmetatable({}, bloodseeker_thirst_lod.prototype)
    self:____constructor(...)
    return self
end
function bloodseeker_thirst_lod.prototype.____constructor(self)
end
function bloodseeker_thirst_lod.prototype.GetIntrinsicModifierName(self)
    return "modifier_blodseeker_thrist_lod_buff"
end
function bloodseeker_thirst_lod.prototype.OnUpgrade(self)
    local caster = self:GetCaster()
    if self:GetName() == "bloodseeker_thirst_lod" then
        caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {})
    elseif self:GetName() == "bloodseeker_thirst_lod_op" then
        caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {})
    end
end
modifier_blodseeker_thrist_lod_buff = {}
modifier_blodseeker_thrist_lod_buff.name = "modifier_blodseeker_thrist_lod_buff"
modifier_blodseeker_thrist_lod_buff.__index = modifier_blodseeker_thrist_lod_buff
modifier_blodseeker_thrist_lod_buff.prototype = {}
modifier_blodseeker_thrist_lod_buff.prototype.__index = modifier_blodseeker_thrist_lod_buff.prototype
modifier_blodseeker_thrist_lod_buff.prototype.constructor = modifier_blodseeker_thrist_lod_buff
function modifier_blodseeker_thrist_lod_buff.new(...)
    local self = setmetatable({}, modifier_blodseeker_thrist_lod_buff.prototype)
    self:____constructor(...)
    return self
end
function modifier_blodseeker_thrist_lod_buff.prototype.____constructor(self)
end
function modifier_blodseeker_thrist_lod_buff.prototype.OnCreated(self)
    if IsServer() then
        self:StartIntervalThink(
            FrameTime()
        )
    end
end
function modifier_blodseeker_thrist_lod_buff.prototype.OnIntervalThink(self)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local team = caster:GetTeamNumber()
    local units = HeroList:GetAllHeroes()
    local bonus = 0
    local max_treshhold = ability:GetSpecialValueFor("buff_threshold_pct")
    local min_treshhold = ability:GetSpecialValueFor("visibility_threshold_pct")
    __TS__ArrayForEach(
        units,
        function(____, hero)
            if hero:IsOpposingTeam(team) and hero:IsAlive() and hero:IsRealHero() and hero:GetHealthPercent() < max_treshhold then
                bonus = bonus + math.max(
                    max_treshhold - min_treshhold,
                    hero:GetHealthPercent() - max_treshhold
                )
            end
        end
    )
    self:SetStackCount(bonus)
end
function modifier_blodseeker_thrist_lod_buff.prototype.DeclareFunctions(self)
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end
function modifier_blodseeker_thrist_lod_buff.prototype.GetModifierAttackSpeedBonus_Constant(self)
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_attack_speed") * 0.5
end
function modifier_blodseeker_thrist_lod_buff.prototype.GetModifierMoveSpeedBonus_Percentage(self)
    return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_movement_speed") * 0.5
end
function modifier_blodseeker_thrist_lod_buff.prototype.IsAura(self)
    return true
end
function modifier_blodseeker_thrist_lod_buff.prototype.GetAuraSearchTeam(self)
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_blodseeker_thrist_lod_buff.prototype.GetAuraSearchType(self)
    return DOTA_UNIT_TARGET_HERO
end
function modifier_blodseeker_thrist_lod_buff.prototype.GetModifierAura(self)
    return "modifier_blodseeker_thrist_lod_debuff"
end
function modifier_blodseeker_thrist_lod_buff.prototype.IsHidden(self)
    return self:GetStackCount() == 0
end
modifier_blodseeker_thrist_lod_debuff = {}
modifier_blodseeker_thrist_lod_debuff.name = "modifier_blodseeker_thrist_lod_debuff"
modifier_blodseeker_thrist_lod_debuff.__index = modifier_blodseeker_thrist_lod_debuff
modifier_blodseeker_thrist_lod_debuff.prototype = {}
modifier_blodseeker_thrist_lod_debuff.prototype.__index = modifier_blodseeker_thrist_lod_debuff.prototype
modifier_blodseeker_thrist_lod_debuff.prototype.constructor = modifier_blodseeker_thrist_lod_debuff
function modifier_blodseeker_thrist_lod_debuff.new(...)
    local self = setmetatable({}, modifier_blodseeker_thrist_lod_debuff.prototype)
    self:____constructor(...)
    return self
end
function modifier_blodseeker_thrist_lod_debuff.prototype.____constructor(self)
end
function modifier_blodseeker_thrist_lod_debuff.prototype.IsHidden(self)
    return self:GetParent():GetHealthPercent() > self:GetAbility():GetSpecialValueFor("visibility_threshold_pct")
end
function modifier_blodseeker_thrist_lod_debuff.prototype.CheckState(self)
    return {
        [MODIFIER_STATE_PROVIDES_VISION] = self:GetParent():GetHealthPercent() < self:GetAbility():GetSpecialValueFor("visibility_threshold_pct")
    }
end

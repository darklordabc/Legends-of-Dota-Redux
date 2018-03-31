if spell_lab_bomber == nil then
	spell_lab_bomber = class({})
end

LinkLuaModifier("spell_lab_bomber_modifier", "abilities/spell_lab/bomber/ability.lua", LUA_MODIFIER_MOTION_NONE)
if spell_lab_bomber_modifier == nil then
	spell_lab_bomber_modifier = class({})
end

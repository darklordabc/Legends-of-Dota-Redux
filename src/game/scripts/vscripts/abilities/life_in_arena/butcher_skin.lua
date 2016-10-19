butcher_skin = class ({})
LinkLuaModifier("modifier_butcher_skin", "abilities/life_in_arena/modifier_butcher_skin.lua" ,LUA_MODIFIER_MOTION_NONE)

function butcher_skin:GetIntrinsicModifierName() 
	return "modifier_butcher_skin"
end
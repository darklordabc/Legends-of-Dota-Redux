brewmaster_ferocity_all = class({})
LinkLuaModifier( "modifier_brewmaster_ferocity_lua_all", "abilities/life_in_arena/modifier_brewmaster_ferocity_lua_all",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function brewmaster_ferocity_all:GetIntrinsicModifierName()
	return "modifier_brewmaster_ferocity_lua_all"
end


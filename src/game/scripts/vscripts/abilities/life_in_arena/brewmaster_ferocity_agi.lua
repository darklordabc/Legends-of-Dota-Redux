brewmaster_ferocity_agi = class({})
LinkLuaModifier( "modifier_brewmaster_ferocity_lua_agi", "abilities/life_in_arena/modifier_brewmaster_ferocity_lua_agi",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function brewmaster_ferocity_agi:GetIntrinsicModifierName()
	return "modifier_brewmaster_ferocity_lua_agi"
end


brewmaster_ferocity = class({})
LinkLuaModifier( "modifier_brewmaster_ferocity_lua", "abilities/life_in_arena/modifier_brewmaster_ferocity_lua",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function brewmaster_ferocity:GetIntrinsicModifierName()
	return "modifier_brewmaster_ferocity_lua"
end


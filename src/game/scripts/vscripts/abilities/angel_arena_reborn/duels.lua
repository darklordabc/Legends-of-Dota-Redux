angel_arena_duels = class({})

LinkLuaModifier("modifier_duel_out_of_game", "abilities/angel_arena_reborn/duels.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tribune", "abilities/angel_arena_reborn/duels.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invis_reveal", "abilities/angel_arena_reborn/duels.lua",LUA_MODIFIER_MOTION_NONE)

modifier_invis_reveal = class({})

function modifier_invis_reveal:IsHidden()
	return true
end

function modifier_invis_reveal:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_invis_reveal:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true
	}
	return state
end

modifier_tribune = class({})

function modifier_tribune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
 
	return funcs
end

function modifier_tribune:IsHidden()
	return true
end

function modifier_tribune:GetDisableHealing()
	return true
end

function modifier_tribune:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true
	}
	return state
end

modifier_duel_out_of_game = class({})

function modifier_duel_out_of_game:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
 
	return funcs
end

function modifier_duel_out_of_game:IsHidden()
	return true
end

function modifier_duel_out_of_game:GetDisableHealing()
	return true
end

--------------------------------------------------------------------------------
function modifier_duel_out_of_game:IsPurgable()
    return false
end

function modifier_duel_out_of_game:IsDebuff()
	return true
end

function modifier_duel_out_of_game:GetModifierModelChange ()
    return "models/development/invisiblebox.vmdl"
end

function modifier_duel_out_of_game:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_duel_out_of_game:CheckState()
	local state = {
		-- [MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true
	}
	return state
end
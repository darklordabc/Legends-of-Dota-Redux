modifier_core_courier_flying = class({})
---------------------------------------------------------------------------
function modifier_core_courier_flying:IsHidden()
	return false
end

---------------------------------------------------------------------------
function modifier_core_courier_flying:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_MODEL_CHANGE,
	}
	return funcs
end

---------------------------------------------------------------------------
function modifier_core_courier_flying:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
	}
	return state
end
---------------------------------------------------------------------------
function modifier_core_courier_flying:RemoveOnDeath()
	return false
end

---------------------------------------------------------------------------
function modifier_core_courier_flying:GetVisualZDelta()
	return 150
end

---------------------------------------------------------------------------
function modifier_core_courier_flying:GetModifierModelChange()
	return "models/props_gameplay/donkey_wings.vmdl"
end

---------------------------------------------------------------------------

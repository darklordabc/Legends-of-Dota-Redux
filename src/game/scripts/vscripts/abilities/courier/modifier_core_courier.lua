modifier_core_courier = class({})
---------------------------------------------------------------------------
function modifier_core_courier:IsHidden()
	return false
end

---------------------------------------------------------------------------
function modifier_core_courier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_RESPAWN,
	}
	return funcs
end

---------------------------------------------------------------------------
function modifier_core_courier:MakeCourierFlying()
	Timers:CreateTimer(function()
		local parent = self:GetParent()
		if parent:IsAlive() then
			parent:AddNewModifier(parent, nil, "modifier_core_courier_flying", nil)
			return nil
		else
			return 1.0
		end
	end)
end

---------------------------------------------------------------------------
function modifier_core_courier:OnCreated()
	if not IsServer() then return end

	local parent = self:GetParent()

	if not parent.flying then
		Timers:CreateTimer(180, function() -- 180 seconds after respawn courier it has flying
			self:MakeCourierFlying()
			parent.flying = true
		end)
	end
end

---------------------------------------------------------------------------
function modifier_core_courier:GetModifierMoveSpeedBonus_Constant()
	return 150
end

---------------------------------------------------------------------------
function modifier_core_courier:RemoveOnDeath()
	return false
end

---------------------------------------------------------------------------
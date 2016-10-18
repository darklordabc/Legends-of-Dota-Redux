modifier_lord_of_lightning_holy_wrath_slow = class({})

function modifier_lord_of_lightning_holy_wrath_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_lord_of_lightning_holy_wrath_slow:GetEffectName()
	return ""
end

function modifier_lord_of_lightning_holy_wrath_slow:IsDebuff()
	return true 
end 

function modifier_lord_of_lightning_holy_wrath_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
 
	return funcs
end

function modifier_lord_of_lightning_holy_wrath_slow:GetModifierMoveSpeedBonus_Percentage(params) 
	return self.slow_move_speed
end

function modifier_lord_of_lightning_holy_wrath_slow:OnCreated(kv)
	self.slow_move_speed = -100
	self:StartIntervalThink(1)
end

function modifier_lord_of_lightning_holy_wrath_slow:OnIntervalThink()
	self.slow_move_speed = self.slow_move_speed + 20 
	if self.slow_move_speed == 0 and IsServer() then 
		self:Destroy()
	end
end
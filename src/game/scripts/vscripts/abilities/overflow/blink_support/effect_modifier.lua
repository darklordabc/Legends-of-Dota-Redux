if blink_support_effect_modifier == nil then
	blink_support_effect_modifier = class({})
end

function blink_support_effect_modifier:OnCreated( kv )	
	if IsServer() then
		if self:GetCaster() ~= self:GetParent() then
			local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ROOTBONE_FOLLOW, self:GetParent())
			--ParticleManager:SetParticleControl(nFXIndex, 1, self:GetCaster():GetAbsOrigin()) 
			ParticleManager:SetParticleControlEnt(nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true) 
			self:AddParticle( nFXIndex, false, false, -1, false, false )
		end
	end
end

function blink_support_effect_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function blink_support_effect_modifier:IsHidden()
	if self:GetCaster() == self:GetParent() then
	return true
	else
	return false
	end
end
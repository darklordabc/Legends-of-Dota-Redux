alexander_soulseal = class({})

LinkLuaModifier("modifier_soulseal","abilities/dusk/alexander_soulseal",LUA_MODIFIER_MOTION_NONE)

function alexander_soulseal:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	if target:TriggerSpellAbsorb(self) then return end
	-- target:TriggerSpellReflect(self)

	local duration = self:GetSpecialValueFor("duration") --[[Returns:table
	No Description Set
	]]
	local slow = self:GetSpecialValueFor("slow")

	target:AddNewModifier(caster, self, "modifier_soulseal", {Duration = duration, slow = slow}) --[[Returns:void
	No Description Set
	]]
end

-- Modifiers

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

modifier_soulseal = class({})

function modifier_soulseal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}
	return funcs
end

function modifier_soulseal:OnCreated( kv )

	if IsServer() then

		local p = "particles/units/heroes/hero_alexander/soulseal.vpcf"
		local p2 = "particles/generic_gameplay/generic_silenced.vpcf"

		self:GetParent():EmitSound("Alexander.Soulseal")
		self.p_index = ParticleManager:CreateParticle(p, PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
		Creates a new particle effect
		]]
		ParticleManager:SetParticleControlEnt(self.p_index,0,self:GetParent(),PATTACH_POINT_FOLLOW,"attach_hitloc",self:GetParent():GetCenter(),true)
		self.p_index2 = ParticleManager:CreateParticle(p2, PATTACH_OVERHEAD_FOLLOW, self:GetParent()) --[[Returns:int
		Creates a new particle effect
		]]
	end

end

function modifier_soulseal:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_soulseal:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.p_index,false)
		ParticleManager:DestroyParticle(self.p_index2,false)
	end
end

function modifier_soulseal:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}
	return state
end

function modifier_soulseal:IsDebuff()
	return true
end
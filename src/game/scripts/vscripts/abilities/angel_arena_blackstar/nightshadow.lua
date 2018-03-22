aabs_nightshadow = {}

function aabs_nightshadow:GetIntrinsicModifierName()
	return "modifier_aabs_nightshadow"
end

modifier_aabs_nightshadow = {
	IsHidden = function() return true end,
	IsPurgeable = function() return false end,
	RemoveOnDeath = function() return false end,

	DeclareFunctions = function() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,

	OnAttackLanded = function(self, keys)
		if not IsServer() or keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() then return end

		if self:GetAbility() then
			if RollPercentage(self:GetAbility():GetSpecialValueFor("proc_chance")) then
				for i = 0, self:GetParent():GetAbilityCount() - 1 do
					local ab = caster:GetAbilityByIndex(i)
					if ab then
						local current = ab:GetCooldownTimeRemaining()
						local reduction = self:GetAbility():GetSpecialValueFor("cooldown_reduction")

						ab:EndCooldown()
						if current > reduction then

							ab:StartCooldown(current - reduction)

							local p = ParticleManager:CreateParticle("particles/items_fx/electrical_arc_01_system.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
							--TODO: radius..? what.
							--ParticleManager:SetParticleControl(p, 1, Vector(radius, radius, radius))

							ParticleManager:ReleaseParticleIndex(p)
						end
					end
				end
				self:GetAbility():UseResources(false, false, true)
			end
		else
			self:Destroy()
			return
		end
	end,
}
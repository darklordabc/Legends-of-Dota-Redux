LinkLuaModifier("modifier_aabs_nightshadow", "abilities/angel_arena_blackstar/nightshadow.lua", LUA_MODIFIER_MOTION_NONE)

aabs_nightshadow = {}
aabs_nightshadow_op = {}

function aabs_nightshadow_op:GetIntrinsicModifierName()
	return "modifier_aabs_nightshadow"
end

function aabs_nightshadow:GetIntrinsicModifierName()
	return "modifier_aabs_nightshadow"
end

modifier_aabs_nightshadow = {
	IsHidden = function() return true end,
	IsPurgeable = function() return false end,
	RemoveOnDeath = function() return false end,

	DeclareFunctions = function() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end,

	OnAttackLanded = function(self, keys)
		if not IsServer() or keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or not self:GetParent():IsRealHero() then return end

		if self:GetAbility() then
			if self:GetAbility():IsCooldownReady() and RollPercentage(self:GetAbility():GetSpecialValueFor("proc_chance")) then
				for i = 0, self:GetParent():GetAbilityCount() - 1 do
					local ab = self:GetParent():GetAbilityByIndex(i)
					if ab then
						local current = ab:GetCooldownTimeRemaining()
						local reduction = self:GetAbility():GetSpecialValueFor("cooldown_reduction")

						ab:EndCooldown()
						if current > reduction then

							ab:StartCooldown(current - reduction)
							
							local p = ParticleManager:CreateParticle("particles/items_fx/electrical_arc_01_system.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
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

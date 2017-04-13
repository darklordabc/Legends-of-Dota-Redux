function MaliceOrbCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:HasModifier("modifier_malice_debuff") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_malice_orb", {duration = 1.5})
		caster:EmitSound("Hero_SkeletonKing.CriticalStrike")
	end
end

function MaliceVision( keys )
	local ability = keys.ability
	local target = keys.target
	local targetPos = target:GetAbsOrigin()

	ability:CreateVisibilityNode(targetPos, 16, 0.03)
end
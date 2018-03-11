function ModifyStacks( keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local maxStacks = ability:GetSpecialValueFor("max_stacks")

	if not caster.targetTable then caster.targetTable = {} end

	if not caster:PassivesDisabled() then
		local targetBool = true
		for k,v in pairs(caster.targetTable) do
			if v == target then
				targetBool = false
				break
			end
		end

		if targetBool == true then 
			table.insert(caster.targetTable, target)
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_battle_rhythm",{})
			local stacks = caster:GetModifierStackCount("modifier_battle_rhythm",ability)
			if stacks < maxStacks then
				caster:SetModifierStackCount("modifier_battle_rhythm",ability,stacks + 1)
			end
		end

		local stackPercent = caster:GetModifierStackCount("modifier_battle_rhythm",ability) * 25

		if ability.FXstacks then
			--ParticleManager:SetParticleControl(ability.FXstacks, 1, Vector(20*stackPercent,0,0) )
			--ParticleManager:SetParticleControl(ability.FXstacks, 3, Vector(20*stackPercent,0,0) )
		else
			ability.FXstacks = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_stampede_haste.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			--ParticleManager:SetParticleControl(ability.FXstacks, 3, Vector(20*stackPercent,0,0) )
		end
	end
end

function ResetTargetTable( keys )
	keys.caster.targetTable = {}
	ParticleManager:DestroyParticle(keys.ability.FXstacks,false)
	keys.ability.FXstacks = nil
end

function HandleStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	
end
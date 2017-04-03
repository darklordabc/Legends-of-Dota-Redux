--[[function RarefactionToggle(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:GetToggleState() then
		if not caster:HasModifier("modifier_proteus_rarefaction_aura") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_proteus_rarefaction_aura", {})
		end
	else
		if caster:HasModifier("modifier_proteus_rarefaction_aura") then
			caster:RemoveModifierByName("modifier_proteus_rarefaction_aura")
		end
	end
end
]]
function RarefactionCooldownReduction(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local cooldownreduction = ability:GetSpecialValueFor("cooldown_reduction")
	for i = 0, 16 do
		local ability = target:GetAbilityByIndex(i)
		if ability and ability:GetAbilityType() ~= 1 then
			local cooldown = ability:GetCooldownTimeRemaining()
			if cooldown > 0.25 then
				ability:EndCooldown()
				if cooldown - cooldownreduction < 0.25 then
					ability:EndCooldown()
					ability:StartCooldown(0.25)
				else
					ability:EndCooldown()
					ability:StartCooldown(cooldown - cooldownreduction)
				end
			end
		end
	end
end

function ScepterCheck( keys )
	local caster = keys.caster
	local ability = keys.ability

	local jet = caster:FindAbilityByName("proteus_jet")

	if caster:HasScepter() and jet and jet:GetLevel() > 0 then
		local charges = jet:GetSpecialValueFor("charges_scepter")
		jet:ApplyDataDrivenModifier(caster,caster,"modifier_proteus_jet_charges",{})
		caster:SetModifierStackCount("modifier_proteus_jet_charges", jet, charges)
	end
end
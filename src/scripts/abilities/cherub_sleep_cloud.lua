function SleepDamageCheck( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local threshold = ability:GetLevelSpecialValueFor("damage_to_wake", (ability:GetLevel() - 1))
	local damage = keys.DamageTaken
	if total_damage == nil then total_damage = 0 end
	
	total_damage = total_damage + damage
	if total_damage >= threshold then
		target:RemoveModifierByName("modifier_sleep_cloud_aura")
		target:RemoveModifierByName("modifier_sleep_cloud_effect")
		total_damage = 0
	end
end

function SleepDamageRemove( keys )
	local caster = keys.caster
	local target = keys.unit
	total_damage = 0
end

function SleepAuraCheck( keys )
	if not keys.target:HasModifier("modifier_sleep_cloud_aura") then
		keys.target:RemoveModifierByName("modifier_sleep_cloud_effect")
	end
end
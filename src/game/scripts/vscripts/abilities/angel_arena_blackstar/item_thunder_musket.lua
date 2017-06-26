function UpdateRangedBonus(keys)
	local caster = keys.caster
	local ability = keys.ability

	--if caster:IsRangedAttacker() then
		if not caster:HasModifier("modifier_item_thunder_musket_ranged") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_thunder_musket_ranged", nil)
		end
		if not caster:HasModifier("modifier_item_thunder_musket_ranged_thunderstruck") and ability:IsCooldownReady() then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_thunder_musket_ranged_thunderstruck", nil)
		elseif caster:HasModifier("modifier_item_thunder_musket_ranged_thunderstruck") and not ability:IsCooldownReady() then
			caster:RemoveModifierByName("modifier_item_thunder_musket_ranged_thunderstruck")
		end
	--elseif (caster:HasModifier("modifier_item_thunder_musket_ranged") or caster:HasModifier("modifier_item_thunder_musket_ranged_thunderstruck")) and not caster:IsRangedUnit() then
	--	caster:RemoveModifierByName("modifier_item_thunder_musket_ranged")
	--	caster:RemoveModifierByName("modifier_item_thunder_musket_ranged_thunderstruck")
	--end
end

function ThunderstruckProc(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not ability:IsCooldownReady() then return end

	--if PreformAbilityPrecastActions(caster, ability) then
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = ability:GetAbilitySpecial("thunderstruck_magical_damage"),
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
		target:EmitSound("Hero_Zuus.ArcLightning.Target")
		--SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, ability:GetAbilitySpecial("thunderstruck_magical_damage"), nil)
		ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_lightning_ti_5.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	--end
	ability:StartCooldown(5)
end

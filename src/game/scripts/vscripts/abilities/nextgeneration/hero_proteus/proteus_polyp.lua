function Polyp(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	
	local polypMax = ability:GetSpecialValueFor("max_polyp_health")
	local polypDuration = ability:GetSpecialValueFor("duration")
	local polypBase = ability:GetSpecialValueFor("base_polyp_health")
	local polypRegen = ability:GetSpecialValueFor("polyp_regen")
	local polyp = target.PolypAttached
	
	if not polyp or polyp:IsNull() then
		polyp = CreateUnitByName("npc_dota_proteus_polyp", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		target.PolypAttached = polyp
		polyp:SetMaxHealth(polypMax)
		polyp:SetBaseMaxHealth(polypMax)
		polyp:SetHealth(polypBase)
		polyp:SetBaseHealthRegen(polypRegen)
		ability:ApplyDataDrivenModifier(caster, polyp, "modifier_proteus_polyp_unit", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_proteus_polyp_protection", {Duration = polypDuration})
		polyp:AddNewModifier(caster,ability,"modifier_kill",{Duration = polypDuration})
		polyp:SetParent(target, "attach_hitloc")
		polyp:SetOrigin( polyp:GetOrigin()+Vector(-1,-2,5) )
	else -- refresh polyp
		target.PolypAttached:SetMaxHealth(polypMax)
		target.PolypAttached:SetBaseMaxHealth(polypMax)
		target.PolypAttached:SetBaseHealthRegen(polypRegen)
		target.PolypAttached:AddNewModifier(caster,ability,"modifier_kill",{Duration = polypDuration})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_proteus_polyp_protection", {Duration = polypDuration})
		if target.PolypAttached:GetHealth() < polypBase then
			target.PolypAttached:SetHealth(polypBase)
		end
	end
end

function PolypCheck(keys)
	local polyp = keys.target
	local ability = keys.ability

	if polyp:IsNull() then return end
	
	if polyp:GetHealth() == polyp:GetMaxHealth() then
		polyp:GetMoveParent():RemoveModifierByName("modifier_proteus_polyp_protection")
	end
	polyp:RemoveSelf()
end

function PolypDamageBlock(keys)
	local victim = keys.unit
	local damage = keys.damage
	local polyp = victim.PolypAttached
	local damageBlock = damage

	if polyp:IsNull() then return end

	if damageBlock > polyp:GetHealth() then damageBlock = polyp:GetHealth() end
	victim:SetHealth(victim:GetHealth() + damageBlock)
	polyp:SetHealth(polyp:GetHealth() - damage)
	if polyp:GetHealth() <= 0 then
		polyp:GetMoveParent():RemoveModifierByName("modifier_proteus_polyp_protection")
		polyp:RemoveSelf()
	end
end

function PolypSetDamage(keys)
	local owner = keys.attacker
	local target = keys.target
	local ability = keys.ability

	if owner.PolypAttached:IsNull() then return end

	local polyp = owner.PolypAttached
	local polypBase = ability:GetSpecialValueFor("base_polyp_health")
	local polypCheck = polyp:GetHealth() - polypBase
	local polypHealthToDamage = ability:GetSpecialValueFor("damage_per_health") / 100

	if polypCheck > 0 then
		polyp:SetHealth(polypBase)
		owner.bonusDamage = polypCheck * polypHealthToDamage
	end
end

function PolypBonusDamage(keys)
	local owner = keys.attacker
	local target = keys.target
	local ability = keys.ability

	if owner.PolypAttached:IsNull() then return end

	if owner.bonusDamage and target:IsAlive() then
		target:EmitSound("Hero_Shared.WaterFootsteps")
		ApplyDamage({ victim = target, attacker = owner, damage = owner.bonusDamage, damage_type = DAMAGE_TYPE_PHYSICAL })
		SendOverheadEventMessage( owner:GetPlayerOwner(), OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, owner.bonusDamage, nil )
	end
end
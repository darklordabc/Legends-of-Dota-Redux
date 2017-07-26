function Ablaze( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local armor = caster:GetPhysicalArmorValue()
	local armor_damage = armor * 0.5

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = armor_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = ability,
	}
	ApplyDamage(damageTable)
end



function CheckCooldown( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local sound = keys.sound
	local mana = ability:GetManaCost(ability:GetLevel() - 1)
	
	if ability:IsCooldownReady() then
		ability.off_cooldown = 1
		caster:SpendMana(mana, ability)
		EmitSoundOn(sound, target)
	end
end

function BulwarkStrikeDamage( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local particle = keys.particle
	local particle2	= keys.particle2
	local sound = keys.sound
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local cooldown = ability:GetTrueCooldown()
	local armor = caster:GetPhysicalArmorValue()
	local armor_multiplier = ability:GetLevelSpecialValueFor("armor_multiplier", ability:GetLevel() - 1)
	local ablaze_multiplier = ability:GetLevelSpecialValueFor("ablaze_multiplier", ability:GetLevel() - 1)
	local armor_damage = armor * armor_multiplier

	local type_damage = ability:GetAbilityDamageType()

	if ability.off_cooldown == 1 then
		if target:HasModifier("ablaze_modifier") then
			units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			for k, v in pairs(units) do
				ability:ApplyDataDrivenModifier(caster, v, "ablaze_modifier", {})
				local particle2 = ParticleManager:CreateParticle(particle2, PATTACH_ABSORIGIN_FOLLOW, target)
				armor_damage = armor_damage + armor * ablaze_multiplier
			end
		end
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = armor_damage,
			damage_type = type_damage,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
			ability = ability,
		}
		ApplyDamage(damageTable)
		ability:ApplyDataDrivenModifier(caster, target, "ablaze_modifier", {})
		local particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		

		ability:StartCooldown(cooldown)
		ability.off_cooldown = 0
	end
end



function SkippingFlames( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local delay = ability:GetLevelSpecialValueFor("delay", ability:GetLevel() - 1)
	local ablaze_multiplier = ability:GetLevelSpecialValueFor("ablaze_multiplier", ability:GetLevel() - 1)
	local armor = caster:GetPhysicalArmorValue()
	local armor_damage = armor * 0.5 * ablaze_multiplier
	local sound = keys.sound
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()
	ability.skipping_flames_damage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel() - 1)

	ability:ApplyDataDrivenModifier(caster, target, "skipping_flames_modifier", {})

	units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)

	for k, v in pairs(units) do
		local ablaze = v:FindModifierByName("ablaze_modifier")
		local distance = (v:GetAbsOrigin() - target_location):Length2D()
		local projectile_speed = distance/delay

		if ablaze ~= nil and v:IsAlive() then
			local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(particle, 0, target_location)
			ParticleManager:SetParticleControl(particle, 1, v:GetAbsOrigin())
			v:RemoveModifierByName("ablaze_modifier")
			ability.skipping_flames_damage = ability.skipping_flames_damage + armor_damage * (ablaze:GetDuration() / 0.5)
			EmitSoundOn(sound, v)
		end
	end
end

function SkippingFlamesDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ability.skipping_flames_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = ability,
	}
	ApplyDamage(damageTable)
	print(ability.skipping_flames_damage)
	ability:ApplyDataDrivenModifier(caster, target, "ablaze_modifier", {})
end



function CheckStun( keys )
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetTrueCooldown()
	local sound = keys.sound
	local particle = keys.particle

	if caster:IsStunned() and ability:IsCooldownReady() and caster:IsIllusion() == false then
		EmitSoundOn(sound, caster)
		local particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster) 
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
		ability:ApplyDataDrivenModifier(caster, caster, "unwavering_stance_active_modifier", {})
		ability:StartCooldown(cooldown)
	end
end

function StunImmune( keys )
	local caster = keys.caster
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false

	caster:Purge(RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

function UnwaveringApplyAblaze( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker

	ability:ApplyDataDrivenModifier(caster, attacker, "ablaze_modifier", {})
end



function MoltenCharge( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local modifier = keys.modifier
	local sound = keys.sound
	local particle = keys.particle

	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed + 0.1

	ability.molten_charge_distance = distance
	ability.molten_charge_speed = speed * 1/30
	ability.molten_charge_direction = direction
	ability.molten_charge_traveled_distance = 0

	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})

	EmitSoundOn(sound, caster)
	local particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster) 
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true)
end

function MoltenChargeMotion( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability.molten_charge_traveled_distance < ability.molten_charge_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.molten_charge_direction * ability.molten_charge_speed)
		ability.molten_charge_traveled_distance = ability.molten_charge_traveled_distance + ability.molten_charge_speed
	else
		caster:InterruptMotionControllers(false)
	end
end

function MoltenChargeDamage( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local armor = caster:GetPhysicalArmorValue()
	local armor_multiplier = ability:GetLevelSpecialValueFor("armor_multiplier", ability:GetLevel() - 1)
	local armor_damage = armor * armor_multiplier

	local type_damage = ability:GetAbilityDamageType()

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = armor_damage,
		damage_type = type_damage,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = ability,
	}
	ApplyDamage(damageTable)

	if target:HasModifier("ablaze_modifier") then
		ability:ApplyDataDrivenModifier(caster, target, "molten_charge_root_modifier", {})
	else
		ability:ApplyDataDrivenModifier(caster, target, "molten_charge_slow_modifier", {})
	end

	if target:IsHero() then
		ability:ApplyDataDrivenModifier(caster, target, "molten_charge_armor_drain_modifier", {})
	end
	ability:ApplyDataDrivenModifier(caster, target, "ablaze_modifier", {})
end

function DrainArmor( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local duration = ability:GetLevelSpecialValueFor("stack_duration", ability:GetLevel() - 1)
	local break_distance = ability:GetLevelSpecialValueFor("break_distance", ability:GetLevel() - 1)

	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

	local modifier_ui_buff = caster:FindModifierByName("molten_charge_armor_drain_buff_display_modifier")
	local modifier_ui_debuff = target:FindModifierByName("molten_charge_armor_drain_debuff_display_modifier")

	if modifier_ui_buff == nil then
		ability:ApplyDataDrivenModifier(caster, caster, "molten_charge_armor_drain_buff_display_modifier", {})
		modifier_ui_buff = caster:FindModifierByName("molten_charge_armor_drain_buff_display_modifier")
	end

	if modifier_ui_debuff == nil then
		ability:ApplyDataDrivenModifier(caster, target, "molten_charge_armor_drain_debuff_display_modifier", {})
		modifier_ui_debuff = target:FindModifierByName("molten_charge_armor_drain_debuff_display_modifier")
	end

	if distance <= break_distance and target:IsAlive() and caster:IsAlive() then
		for i=ability:GetLevel() -1,0,-1 do
			modifier_ui_buff:IncrementStackCount()
			modifier_ui_debuff:IncrementStackCount()
		end

		modifier_ui_buff:SetDuration(duration, true)
		modifier_ui_debuff:SetDuration(duration, true)

		ability:ApplyDataDrivenModifier(caster, target, "molten_charge_armor_drain_debuff_modifier", {})
		ability:ApplyDataDrivenModifier(caster, caster, "molten_charge_armor_drain_buff_modifier", {})
	else
		target:RemoveModifierByNameAndCaster("molten_charge_armor_drain_modifier", caster)
		if caster:FindModifierByNameAndCaster("molten_charge_armor_drain_buff_display_modifier", caster) ~= nil and modifier_ui_buff:GetStackCount() < 1 then
			caster:RemoveModifierByNameAndCaster("molten_charge_armor_drain_buff_display_modifier", caster)
		end
		if target:FindModifierByNameAndCaster("molten_charge_armor_drain_debuff_display_modifier", caster) ~= nil and modifier_ui_debuff:GetStackCount() < 1 then
			target:RemoveModifierByNameAndCaster("molten_charge_armor_drain_debuff_display_modifier", caster)
		end
	end
end

function DrainArmorParticle( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local particle = keys.particle

	target.ArmorDrainParticle = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(target.ArmorDrainParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_overhead", caster:GetAbsOrigin(), true)
end

function DrainArmorParticleEnd( keys )
	local target = keys.target

	ParticleManager:DestroyParticle(target.ArmorDrainParticle, false)
end

function RemoveStacks( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier = keys.modifier
	local modifier_ui = target:FindModifierByName(modifier)

	if target:IsAlive() and modifier_ui ~= nil then		
		for i=ability:GetLevel() -1,0,-1 do
			modifier_ui:DecrementStackCount()
		end
		if modifier_ui:GetStackCount() < 1 then
			target:RemoveModifierByName(modifier)
		end
	end
end

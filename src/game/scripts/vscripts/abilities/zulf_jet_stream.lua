function JetStreamGetLocation( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	caster.caster_location = caster:GetAbsOrigin()
	caster.casterVec = (point - caster:GetAbsOrigin()):Normalized()
end



function JetStreamProjectile( keys )
	local caster = keys.caster
	local ability = keys.ability
	--local timers = require('easytimers')
	forwardVec = caster.casterVec

	-- Projectile variables
	local wave_speed = 1500
	local wave_width = ability:GetLevelSpecialValueFor("width", (ability:GetLevel() - 1))
	local wave_range = ability:GetLevelSpecialValueFor("length", (ability:GetLevel() - 1))
	local wave_location = caster.caster_location
	local wave_particle = keys.wave_particle


	-- Creating the projectile
	local projectileTable =
	{
		EffectName = wave_particle,
		Ability = ability,
		vSpawnOrigin = caster.caster_location,
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = wave_range,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		bProvidesVision = true,
		iVisionRadius = wave_width,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	--[[Timer to provide vision
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		wave_location = wave_location + forwardVec * (wave_speed * 1/30)
		local distance = (wave_location - caster.caster_location):Length2D()
		-- Checking if we traveled far enough, if yes then destroy the timer
		if distance >= wave_range then
			return nil
		else
			return 1/30
		end
	end)]]--
end

function JetStreamEffect( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local abilityStackBuff = target:GetModifierStackCount("modifier_jet_stream_buff_increase", ability)
	local abilityStackDebuff = target:GetModifierStackCount("modifier_jet_stream_debuff_decrease", ability)
	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local target_angle = target:GetForwardVector().y
	local projectile_angle = forwardVec.y
	-- Convert the radian to degrees.
	local angle_difference = (target_angle - projectile_angle) * 180
	local attacker_angle = angle_difference / math.pi
	-- See the opening block comment for why I do this. Basically it's to turn negative angles into positive ones and make the math simpler.
	result_angle = math.abs(attacker_angle)
	
	if caster:GetTeam() == target:GetTeam() and result_angle < 45 then	
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jet_stream_buff", {})
	elseif caster:GetTeam() ~= target:GetTeam() and result_angle > 45 then	
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jet_stream_debuff", {})
	else
		target:RemoveModifierByName("modifier_jet_stream_debuff")
	end
end

function JetStreamBuff( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local stacks = ability:GetLevelSpecialValueFor("max_speed", ability:GetLevel() - 1)
	
	if not target:HasModifier("modifier_jet_stream_buff_increase") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jet_stream_buff_increase", {} )
	end
	
	local abilityStack = target:GetModifierStackCount("modifier_jet_stream_buff_increase", ability)
	if abilityStack < stacks and result_angle < 45 then
		target:SetModifierStackCount("modifier_jet_stream_buff_increase", ability, abilityStack + 1)
	end
end

function JetStreamDebuff( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local stacks = ability:GetLevelSpecialValueFor("max_speed", ability:GetLevel() - 1)
	
	if not target:HasModifier("modifier_jet_stream_debuff_decrease") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_jet_stream_debuff_decrease", {} )
	end
	
	local abilityStack = target:GetModifierStackCount("modifier_jet_stream_debuff_decrease", ability)
	if abilityStack < stacks and result_angle > 45 then
		target:SetModifierStackCount("modifier_jet_stream_debuff_decrease", ability, abilityStack + 1)
	end
end

function JetStreamCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:HasModifier("modifier_jet_stream_debuff") then
		target:RemoveModifierByName("modifier_jet_stream_debuff_decrease")
	end

	if not target:HasModifier("modifier_jet_stream_buff") then
		target:RemoveModifierByName("modifier_jet_stream_debuff_increase")
	end
end

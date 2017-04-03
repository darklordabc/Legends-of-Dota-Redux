function WaveStart(keys)
	local shivas_guard_particle = ParticleManager:CreateParticle("particles/uther_omniscience_waveactive.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControl(shivas_guard_particle, 1, Vector(keys.BlastFinalRadius, keys.BlastFinalRadius / keys.BlastSpeedPerSecond, keys.BlastSpeedPerSecond))
	
	--keys.caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	keys.caster.current_blast_radius = 0

	local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.BlastFinalRadius, DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local nearby_ally_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.BlastFinalRadius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for i, individual_unit in ipairs(nearby_enemy_units) do
		if individual_unit:HasModifier("modifier_omniscience_wave_hidden") then					
			individual_unit:RemoveModifierByName("modifier_omniscience_wave_hidden")
		end
	end

	for i, individual_unit in ipairs(nearby_ally_units) do
		if individual_unit:HasModifier("modifier_omniscience_wave_hidden") then					
			individual_unit:RemoveModifierByName("modifier_omniscience_wave_hidden")
		end
	end
	
	--Every .03 seconds, damage and apply a movement speed debuff to all units within the current radius of the blast (centered around the caster)
	--that do not already have the debuff.
	--Stop the timer when the blast has reached its maximum radius.
	Timers:CreateTimer({
		endTime = .03, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()		
			keys.caster.current_blast_radius = keys.caster.current_blast_radius + (keys.BlastSpeedPerSecond * .03)
			local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster.current_blast_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			local nearby_ally_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster.current_blast_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for i, individual_unit in ipairs(nearby_enemy_units) do
				if not individual_unit:HasModifier("modifier_omniscience_wave_hidden") then					
					local impact_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_dispel_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
					local target_point = individual_unit:GetAbsOrigin()
					local caster_point = individual_unit:GetAbsOrigin()
					--ParticleManager:SetParticleControl(impact_particle, 1, target_point + (target_point - caster_point) * 30)
					individual_unit:EmitSound("Hero_Wisp.Spirits.Target")
					individual_unit:Purge(true,false,false,false,false)
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_omniscience_wave_hidden", {Duration = 9})
				end
			end

			for i, individual_unit in ipairs(nearby_ally_units) do
				if not individual_unit:HasModifier("modifier_omniscience_wave_hidden") then					
					local impact_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_dispel_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
					local target_point = individual_unit:GetAbsOrigin()
					local caster_point = individual_unit:GetAbsOrigin()
					--ParticleManager:SetParticleControl(impact_particle, 1, target_point + (target_point - caster_point) * 30)
					individual_unit:Purge(false,true,false,true,false)
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_omniscience_wave_hidden", {Duration = 9})
				end
			end
			
			if keys.caster.current_blast_radius < keys.BlastFinalRadius then  --If the blast should still be expanding.
				return .03
			else  --The blast has reached or exceeded its intended final radius.
				keys.caster.current_blast_radius = 0
				return nil
			end
		end
	})
end
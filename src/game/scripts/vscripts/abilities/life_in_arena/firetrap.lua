
function StasisStart( event )
	local caster = event.caster
	local ability = event.ability
	local target_point = event.target_points[1]
	local duration = ability:GetSpecialValueFor('duration') 
	local stasis = CreateUnitByName('fire_trap_unit', target_point, true, caster, caster, caster:GetTeamNumber())
	stasis:AddNewModifier(stasis, nil, "modifier_kill", {duration = duration})
	ability:ApplyDataDrivenModifier(stasis, stasis, 'modifier_stasis_ward', nil)	
	stasis:EmitSound('Hero_Techies.StasisTrap.Plant')
	ParticleManager:CreateParticle("particles/firelord_fire_trap.vpcf", 1, stasis)
end

function StasisSetup( event )
	local stasis = event.caster
	local ability = event.ability
	stasis:AddNewModifier(stasis, nil, "modifier_invisible", {duration = 1})
	ability:ApplyDataDrivenModifier(stasis, stasis, 'modifier_stasis_ward_trigger', {})
end

function StasisThink( event )
	local stasis = event.caster
	if stasis then
		local ability = event.ability
		stasis:AddNewModifier(stasis, nil, "modifier_invisible", {duration = 1})
		local radius = ability:GetSpecialValueFor('detection_radius') 
		local enemies = FindUnitsInRadius(stasis:GetTeamNumber(), stasis:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			if enemy:HasGroundMovementCapability() then
				stasis:RemoveModifierByName('modifier_invisible')
				stasis:RemoveModifierByName('modifier_stasis_ward_trigger')
				Timers:CreateTimer(1, function ()
					if stasis:IsAlive() then
						local radius = ability:GetSpecialValueFor('detonation_radius') 
						local enemies = FindUnitsInRadius(stasis:GetTeamNumber(), stasis:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
						local allies = FindUnitsInRadius(stasis:GetTeamNumber(), stasis:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
						for _,enemy in pairs(enemies) do
							local duration = 0
							if enemy:IsHero() then
								duration = ability:GetSpecialValueFor('stun_hero_duration') 	
							else
								duration = ability:GetSpecialValueFor('stun_duration') 	
							end
							enemy:AddNewModifier(stasis, ability, 'modifier_stunned', {duration = duration})
						end
						for _,ally in pairs(allies) do
							if ally:GetUnitName() == 'fire_trap_unit' then
								ally:ForceKill(true)
							end
						end
						stasis:EmitSound('Hero_Techies.StasisTrap.Stun')
						ParticleManager:CreateParticle("particles/firelord_fire_trap_explode_custom.vpcf", 1, stasis)
						stasis:ForceKill(true)
					end
				end
				)
				break
			end
		end
	end
end
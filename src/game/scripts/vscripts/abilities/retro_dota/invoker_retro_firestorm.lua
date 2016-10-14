--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called when Firestorm is cast.
	Additional parameters: keys.FireballCastRadius, keys.FireballLandDelay, keys.FireballDelayBetweenSpawns,
		keys.FireballVisionRadius, keys.FireballDamageAoE, keys.FireballLandingDamage, keys.FireballDuration,
		keys.FireballExplosionDamage
================================================================================================================= ]]
require('lib/timers')
function invoker_retro_firestorm_on_spell_start(keys)
	local caster_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	
	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
	local target_point_temp = Vector(target_point.x, target_point.y, 0)
	
	local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
	
	keys.caster:EmitSound("Hero_EarthSpirit.Petrify")
	keys.caster:EmitSound("Hero_Warlock.RainOfChaos")
	
	--The number of fireballs to spawn is dependent on the level of Exort.
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_firestorm")
	local num_fireballs = 0
	if exort_ability ~= nil then
		num_fireballs = keys.ability:GetLevelSpecialValueFor("num_fireballs", exort_ability:GetLevel() - 1)
	end
	
	--Create a dummy unit at the center point to emit a sound.
	local fireball_sound_unit = CreateUnitByName("npc_dota_invoker_retro_firestorm_fireball_explosion_unit", target_point, false, nil, nil, keys.caster:GetTeam())
	local dummy_unit_ability = fireball_sound_unit:FindAbilityByName("dummy_unit_passive")
	if dummy_unit_ability ~= nil then
		dummy_unit_ability:SetLevel(1)
	end
	fireball_sound_unit:EmitSound("Hero_EarthSpirit.Magnetize.End")
	
	Timers:CreateTimer({
		endTime = keys.FireballDuration + (keys.FireballDelayBetweenSpawns * num_fireballs) + keys.FireballLandDelay + 3,
		callback = function()
			fireball_sound_unit:RemoveSelf()
		end
	})
	
	--Spawn the fireballs.
	local fireballs_spawned_so_far = 0
	Timers:CreateTimer({
		callback = function()
			--Select a random point within the radius around the target point.
			local random_x_offset = RandomInt(0, keys.FireballCastRadius) - (keys.FireballCastRadius / 2)
			local random_y_offset = RandomInt(0, keys.FireballCastRadius) - (keys.FireballCastRadius / 2)
			local fireball_landing_point = Vector(target_point.x + random_x_offset, target_point.y + random_y_offset, target_point.z)
			fireball_landing_point = GetGroundPosition(fireball_landing_point, nil)
			
			--Create a particle effect consisting of the fireball falling from the sky and landing at the target point.
			local fireball_spawn_point = (fireball_landing_point - (point_difference_normalized * 300)) + Vector (0, 0, 800)
			local fireball_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 0, fireball_spawn_point)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 1, fireball_landing_point)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 2, Vector(keys.FireballLandDelay, 0, 0))
			
			--Spawn the landed fireball when it's supposed to have visually landed.
			Timers:CreateTimer({
				endTime = keys.FireballLandDelay - .05,  --It does not appear that particles will attach to an entity's new position if that entity has just been moved this frame (or there is travel time or something).  So select and move the entity to the destination point, and give it the modifiers to deal damage a frame later.
				callback = function()
					local fireball_unit = nil
					
					--Check out a waiting dummy unit (so we don't have to create one and cause lag).
					local i = 0
					while i <= 79 and fireball_unit == nil do
						if firestorm_fireballs[i] ~= nil then
							fireball_unit = firestorm_fireballs[i]
							firestorm_fireballs[i] = nil
						end
						i = i + 1
					end
					
					if fireball_unit ~= nil then
						fireball_unit:SetTeam(keys.caster:GetTeam())
						fireball_unit:SetAbsOrigin(fireball_landing_point)
						fireball_unit:SetHealth(fireball_unit:GetMaxHealth())
	
						Timers:CreateTimer({
							endTime = .05,
							callback = function()
								fireball_unit:RemoveModifierByName("dummy_modifier_no_health_bar")
								fireball_unit.firestorm_fireball_time_to_explode = GameRules:GetGameTime() + keys.FireballDuration

								local fireball_ground_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball.vpcf", PATTACH_ABSORIGIN, fireball_unit)
						
								fireball_unit:SetDayTimeVisionRange(keys.FireballVisionRadius)
								fireball_unit:SetNightTimeVisionRange(keys.FireballVisionRadius)
								
								fireball_sound_unit:StopSound("Hero_EarthSpirit.RollingBoulder.Target")
								fireball_sound_unit:StopSound("Hero_Phoenix.FireSpirits.Cast")
								fireball_sound_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Target")
								fireball_sound_unit:EmitSound("Hero_Phoenix.FireSpirits.Cast")
								
								local firestorm_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm")
								firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_duration", nil)
								firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_emitter", nil)					
								
								--Damage nearby enemy units with fireball landing damage.
								local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
								
								for i, individual_unit in ipairs(nearby_enemy_units) do
									ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballLandingDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
								end
								
								--Explode the fireball when it is set to expire.  By doing this here and not in modifier_invoker_retro_firestorm_fireball_duration_on_interval_think,
								--the spell can be made with one less dummy unit.
								Timers:CreateTimer({
									endTime = keys.FireballDuration,
									callback = function()
										ParticleManager:DestroyParticle(fireball_ground_particle_effect, false)
										
										local fireball_explosion_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball_explosion.vpcf", PATTACH_ABSORIGIN, fireball_unit)
										
										fireball_sound_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Destroy")
										
										--Damage nearby enemy units with fireball explosion damage.
										local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
										
										for i, individual_unit in ipairs(nearby_enemy_units) do
											ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballExplosionDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
										end
										
										fireball_unit:RemoveModifierByName("modifier_invoker_retro_firestorm_fireball_duration")
										fireball_unit:RemoveModifierByName("modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_emitter")
										
										local firestorm_fireball_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm_fireball")
										firestorm_fireball_ability:ApplyDataDrivenModifier(fireball_unit, fireball_unit, "dummy_modifier_no_health_bar", {Duration = -1})
										
										Timers:CreateTimer({
											endTime = .05,
											callback = function()
												fireball_unit:SetAbsOrigin(Vector(7000, 7000, 128))
										
												--Check back in the dummy unit.
												local i = 0
												while i <= 79 and fireball_unit ~= nil do
													if firestorm_fireballs[i] == nil then
														firestorm_fireballs[i] = fireball_unit
														fireball_unit = nil
													end
													i = i + 1
												end
											end
										})
									end
								})
							end
						})
					else  --If there are no more Fireball dummy units to check out, then create new, temporary ones.
						local fireball_unit = CreateUnitByName("npc_dota_invoker_retro_firestorm_unit", fireball_landing_point, false, nil, nil, keys.caster:GetTeam())
						local fireball_unit_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm_fireball")
						if fireball_unit_ability ~= nil then
							fireball_unit_ability:SetLevel(1)
						end
						
						fireball_unit.firestorm_fireball_time_to_explode = GameRules:GetGameTime() + keys.FireballDuration
						
						local fireball_ground_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball.vpcf", PATTACH_ABSORIGIN, fireball_unit)
						
						fireball_unit:SetDayTimeVisionRange(keys.FireballVisionRadius)
						fireball_unit:SetNightTimeVisionRange(keys.FireballVisionRadius)
						
						fireball_sound_unit:StopSound("Hero_EarthSpirit.RollingBoulder.Target")
						fireball_sound_unit:StopSound("Hero_Phoenix.FireSpirits.Cast")
						fireball_sound_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Target")
						fireball_sound_unit:EmitSound("Hero_Phoenix.FireSpirits.Cast")
						
						local firestorm_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm")
						firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_duration", nil)
						firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_emitter", nil)					
						
						--Damage nearby enemy units with fireball landing damage.
						local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
						
						for i, individual_unit in ipairs(nearby_enemy_units) do
							ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballLandingDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
						end
						
						--Explode the fireball when it is set to expire.  By doing this here and not in modifier_invoker_retro_firestorm_fireball_duration_on_interval_think,
						--the spell can be made with one less dummy unit.
						Timers:CreateTimer({
							endTime = keys.FireballDuration,
							callback = function()
								ParticleManager:DestroyParticle(fireball_ground_particle_effect, false)
								local fireball_explosion_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball_explosion.vpcf", PATTACH_ABSORIGIN, fireball_unit)
										
								fireball_sound_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Destroy")
								
								--Damage nearby enemy units with fireball explosion damage.
								local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
								
								for i, individual_unit in ipairs(nearby_enemy_units) do
									ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballExplosionDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
								end
								
								fireball_unit:RemoveSelf()
							end
						})
					end
				end
			})
			
			fireballs_spawned_so_far = fireballs_spawned_so_far + 1
			if fireballs_spawned_so_far >= num_fireballs then 
				return
			else 
				return keys.FireballDelayBetweenSpawns
			end
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called regularly on fireballs that are lying around.  Removes some of the fireball's health to enforce the timer.
	Additional parameters: keys.FireballDuration
================================================================================================================= ]]
function modifier_invoker_retro_firestorm_fireball_duration_on_interval_think(keys)
	local new_health = keys.target:GetMaxHealth()
	
	if keys.target.firestorm_fireball_time_to_explode == nil then
		new_health = keys.target:GetHealth() - ((keys.target:GetMaxHealth() / keys.FireballDuration) * .03)
	else
		new_health = new_health * ((keys.target.firestorm_fireball_time_to_explode - GameRules:GetGameTime()) / keys.FireballDuration)
	end
		
	if new_health > 0 then  --Lower the health.
		keys.target:SetHealth(new_health)
	else
		keys.target:SetHealth(1)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called regularly on fireballs that are lying around.  Damages nearby enemy units.
	Additional parameters: keys.FireballDamageAoE, keys.FireballAoEDamageInterval, keys.FireballAoEDamagePerSecond
================================================================================================================= ]]
function modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_on_interval_think(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.FireballAoEDamagePerSecond * keys.FireballAoEDamageInterval, damage_type = DAMAGE_TYPE_MAGICAL,})
end
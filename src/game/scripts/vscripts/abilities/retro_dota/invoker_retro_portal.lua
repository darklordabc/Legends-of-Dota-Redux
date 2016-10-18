--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal's cast point begins.  Starts the particle effect and sound.
	Additional parameters: keys.CastPoint
================================================================================================================= ]]
if IsServer() then
	require('lib/timers')
end

function invoker_retro_portal_on_ability_phase_start(keys)
	local target_origin = keys.target:GetAbsOrigin()
	local distance_to_target = keys.caster:GetRangeToUnit(keys.target)

	local portal_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_portal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	
	local portal_particle_drain_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_portal_drain.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControlEnt(portal_particle_drain_effect, 1, keys.target, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", keys.target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(portal_particle_drain_effect, 2, Vector(distance_to_target * 3.5, 0, 0))
	
	--Remove the Portal particles after the duration is supposed to end.
	Timers:CreateTimer({
		endTime = keys.CastPoint + .2,
		callback = function()
			ParticleManager:DestroyParticle(portal_particle_effect, false)
			ParticleManager:DestroyParticle(portal_particle_drain_effect, false)
		end
	})
	
	keys.target:EmitSound("Hero_Meepo.Poof.Channel")
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal's cast point finishes.  Damages the target and moves them to Invoker.
================================================================================================================= ]]
function invoker_retro_portal_on_spell_start(keys)	
	--Portal's damage is dependent on the level of Wex.
	local portal_damage = 0

	
	--Instead of placing the target right on top of Invoker, place them a little away along the line between Invoker and the target.
	--This ensures that the target is not placed on the opposite side of Invoker.
	local caster_point = keys.caster:GetAbsOrigin()
	local point_difference_normalized = (keys.target:GetAbsOrigin() - caster_point):Normalized()
	local point_to_place_target = GetGroundPosition(caster_point + (point_difference_normalized * 64), nil)
	
	FindClearSpaceForUnit(keys.target, point_to_place_target, false)  --Move the target to Invoker's position.
	keys.target:EmitSound("Hero_Meepo.Poof.End")
	
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = portal_damage, damage_type = DAMAGE_TYPE_MAGICAL,})
end

--[[
	Author: Noya
	Date: April 5, 2015.
	FURION CAN YOU TP TOP? FURION CAN YOU TP TOP? CAN YOU TP TOP? FURION CAN YOU TP TOP? 
]]
function Teleport( event )
	local caster = event.caster
	local ability = event.ability
	local point = event.target_points[1]
	local teleport_distance = (caster:GetAbsOrigin() - point):Length2D()
	local teleport_range = ability:GetSpecialValueFor("range")
	if teleport_distance > teleport_range then
		local origin = caster:GetAbsOrigin()
		local direction = (point - origin):Normalized()
		point = origin + direction * teleport_range 
	end
	
    FindClearSpaceForUnit(caster, point, true)
    caster:Stop() 
    EndTeleport(event)   
end

function CreateTeleportParticles( event )
	local caster = event.caster
	local ability = event.ability
	local point = event.target_points[1]
	local teleport_distance = (caster:GetAbsOrigin() - point):Length2D()
	local teleport_range = ability:GetSpecialValueFor("range")
	if teleport_distance > teleport_range then
		local origin = caster:GetAbsOrigin()
		local direction = (point - origin):Normalized()
		point = origin + direction * teleport_range 
	end

	local particleName = "particles/units/heroes/hero_furion/furion_teleport_end.vpcf"
	caster.teleportParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.teleportParticle, 1, point)
end

function EndTeleport( event )
	local caster = event.caster
	ParticleManager:DestroyParticle(caster.teleportParticle, false)
	caster:StopSound("Hero_Furion.Teleport_Grow")
end

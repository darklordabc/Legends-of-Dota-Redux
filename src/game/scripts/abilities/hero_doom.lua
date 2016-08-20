function EatCreep ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if IsValidEntity(target) then
		local health = target:GetHealth()
		target:Kill(ability, caster)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_creep_eaten", {duration = health / 20})
	end
end

function CreepGold ( keys )
	local caster = keys.caster
	local target = keys.unit
	local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
	local ability = keys.ability
	local gold = ability:GetLevelSpecialValueFor("devour_gold", ability:GetLevel()) - 1

	if caster:IsAlive() then
	    caster:ModifyGold(gold, false, 0)
	
	    local value = gold
	    local symbol = 1 -- + Symbol
	    local color = Vector(255, 200, 33) -- Gold
	    local lifetime = 2.0
	    local digits = string.len(value) + 1
	    local particleName = "particles/msg_fx/msg_gold.vpcf"
	    local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
	    ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
	    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
	    ParticleManager:SetParticleControl( particle, 3, color )
	end 
end

--[[Author: igo95862, Noya
	Used by: Pizzalol
	Date: 27.01.2016.
	Disallows eating another unit while Devour is in progress]]
function DevourCheck( keys )
	local caster = keys.caster
	local modifier = keys.modifier
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	if caster:HasModifier(modifier) then
		caster:Interrupt()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)
		FireGameEvent('custom_error_show', {player_ID = keys.caster:GetPlayerID(), _error = "You can't eat with your mouth full"})
	end
end

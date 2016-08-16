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
	local ability = keys.ability
	local gold = ability:GetLevelSpecialValueFor("devour_gold", ability:GetLevel()) - 1

	if caster:IsAlive() then
	caster:ModifyGold(gold, false, 0)
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
	end
end
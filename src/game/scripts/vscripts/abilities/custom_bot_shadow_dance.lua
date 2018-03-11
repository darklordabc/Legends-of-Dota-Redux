
function CheckVisibility(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = "modifier_shadow_dance_bonus"
	local neutralDisable = ability:GetLevelSpecialValueFor("neutral_disable", ability:GetLevel() - 1)
	local visibleCheck = true

	for _, unit in ipairs(HeroList:GetAllHeroes()) do
		if unit:CanEntityBeSeenByMyTeam(caster) and unit:GetTeam() ~= caster:GetTeam() then
			caster:RemoveModifierByName(modifier)
			visibleCheck = false
			break	
		end
	end

	if visibleCheck == true and not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	end
end
--[[
	Author: Noya (modified by SwordBacon)
	Date: 9.1.2015.
	Checks if the caster HP dropped below the threshold
]]
function ShadowDanceActivate( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local threshold = ability:GetLevelSpecialValueFor( "hp_threshold" , ability:GetLevel() - 1  )
	local cooldown = ability:GetCooldown( ability:GetLevel() )
	local dur = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1  )

	-- Apply the modifier
	if caster:GetHealth() < 400 and ability:GetCooldownTimeRemaining() == 0  and caster:GetMana() >= ability:GetManaCost(ability:GetLevel() - 1) then

		caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
		ability:StartCooldown( cooldown )
		caster:Stop()
		caster:EmitSound("Hero_Slark.ShadowDance")
	end
end

function DummyMove( keys )
	local caster = keys.caster
	local target = keys.target

	target:SetAbsOrigin(caster:GetAbsOrigin())
end

--[[
	Author: Noya (modified by SwordBacon)
	Date: 9.1.2015.
	Checks if the caster HP dropped below the threshold
]]
function ChemicalRageActivate( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local cooldown = ability:GetCooldown( ability:GetLevel() )

	-- Cast the spell
	if caster:GetHealthPercent() < 90 and ability:GetCooldownTimeRemaining() == 0 and caster:GetMana() > ability:GetManaCost(ability:GetLevel() - 1) then
		caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
		ability:StartCooldown( cooldown )
		caster:Stop()
		caster:EmitSound("Hero_Alchemist.ChemicalRage.Cast")
	end
end

function RemoveLoop( keys )
	keys.caster:StopSound("Hero_Alchemist.ChemicalRage")
end

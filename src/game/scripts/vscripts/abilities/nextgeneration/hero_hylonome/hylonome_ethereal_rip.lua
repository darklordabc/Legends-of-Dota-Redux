function SpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	else
		ability:ApplyDataDrivenModifier(caster,target,"modifier_hylonome_eldritch_pull", {Duration = 0.1})
	end
end


function Interrupt( keys )
    local target = keys.target
    target:InterruptMotionControllers(false)
    keys.caster:SetAttacking(target)
end
--[[ ============================================================================================================
	Author: wFX
	Date: February 24, 2015
	Called when Disarm is cast.  Remove the attack command from a unit.
================================================================================================================= ]]
function invoker_retro_disarm_on_spell_start(event)
	local exort_ability = event.caster:FindAbilityByName("invoker_retro_exort")
	if exort_ability ~= nil then
		local duration = event.ability:GetLevelSpecialValueFor("duration", exort_ability:GetLevel() - 1) 
		event.ability:ApplyDataDrivenModifier(event.caster, event.target, "modifier_invoker_retro_disarm", {})
	end
end
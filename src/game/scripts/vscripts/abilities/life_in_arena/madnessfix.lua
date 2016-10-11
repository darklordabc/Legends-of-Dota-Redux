function MadnessFix(event)
	local caster = event.caster 
	local str = event.ability:GetSpecialValueFor("bonus_all_stats")
	caster:FindModifierByName("modifier_stats_bonus_fix"):OnRefresh({strFix = str})
	caster:RemoveModifierByName("modifier_berserker_madness")
end
--[[ ============================================================================================================
	Author: Rook
	Date: March 5, 2015
	Called when Deafening Blast is cast.  Mutes the unit.
================================================================================================================= ]]
function invoker_retro_deafening_blast_on_spell_start(keys)
	local deafening_blast = keys.caster:FindAbilityByName("invoker_retro_deafening_blast")
	if deafening_blast ~= nil then
		local deafening_blast_level = deafening_blast:GetLevel()
		local mute_duration = keys.ability:GetLevelSpecialValueFor("mute_duration", deafening_blast_level - 1) 
		local damage_to_deal = keys.ability:GetLevelSpecialValueFor("damage", deafening_blast_level - 1) 
		
		keys.target:EmitSound("Hero_Invoker.DeafeningBlast")
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_deafening_blast", {duration = mute_duration})
	end
end
--[[	Author: D2imba
		Date: 23.05.2015	]]
require('lib/util_imba')

function DegenAura( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_stacks = keys.modifier_stacks

	-- Parameters
	local stack_reduction_pct = ability:GetLevelSpecialValueFor("stack_reduction_pct", ability_level)
	
	-- Refreshes the debuff and adds stacks
	AddStacks(ability, caster, target, modifier_stacks, stack_reduction_pct, true)
end

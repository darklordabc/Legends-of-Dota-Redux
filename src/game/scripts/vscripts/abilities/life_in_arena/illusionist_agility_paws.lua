function remove_agi(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	--
	--if not caster.curr_agi then
	--	caster.curr_agi = 0
	--end
	--
	caster.curr_agi = caster.curr_agi - target.bonus_agi
	
	caster:ModifyAgility(-target.bonus_agi)
	caster:CalculateStatBonus()
	--
	--if caster.count_ill then
--	caster.count_ill = caster.count_ill -1
	--end
	
	
end

function stay_agi(event)
	local caster = event.caster
	local target = event.target
	--
	if not caster.all_agi then
		caster.all_agi = 0
	end
	--
	
	--local ability2 = caster:FindAbilityByName('illusionist_agility_paws')
	local modif = caster:FindModifierByName('modifier_illusionist_agility_paws_i')
	if modif then
		caster.all_agi = caster.all_agi + target.bonus_agi
		modif:SetStackCount(caster.all_agi)
	end
	--
	--if caster.count_ill then
--	caster.count_ill = caster.count_ill -1
	--end
end



--[[function init( event )
	local caster = event.caster
	caster.all_agi = 0
	caster.curr_agi = 0

end
]]
function illusions( event )
	local caster = event.caster
	local ability = event.ability
	local attacker = event.attacker
	
	if caster:IsIllusion() then 
		return 
	end

	if not caster.count_ill then
		caster.count_ill = 0
	end
	
	if string.find(attacker:GetUnitName(),"megaboss") then
		ability:RefundManaCost()
		ability:EndCooldown()
		--FireGameEvent( 'custom_error_show', { player_ID = event.caster:GetPlayerOwnerID(), _error = "#lia_hud_error_item_lia_staff_of_illusions_megaboss" } )
		return
	end

	local duration = ability:GetSpecialValueFor("time")
	local outgoingDamage = ability:GetSpecialValueFor("outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor("incoming_damage")

	local origin = attacker:GetAbsOrigin()

	local creep = CreateIllusion(attacker,caster,origin,duration,outgoingDamage,incomingDamage)
	--
	local ability3 = caster:FindAbilityByName('illusionist_whiff_of_deception')
	if ability3:GetLevel() > 0 then
		caster.count_ill = caster.count_ill +1
		-- отнимание коунтера по смерти иллюзии
		ability3:ApplyDataDrivenModifier(caster, creep, "modifier_illusionist_whiff_of_deception", {})
	end
	--
	if not caster.curr_agi then
		caster.curr_agi = 0
	end
	--
	-- дадим ловкость Антаро за каждую вызванную иллюзию: повесим модификатор, где будем все делать
	local ability2 = caster:FindAbilityByName('illusionist_agility_paws')
	if ability2:GetLevel() > 0 then
		local bonus_agi = ability2:GetLevelSpecialValueFor( "bonus_agility", ability2:GetLevel() - 1 )
		local max_bonus = ability2:GetLevelSpecialValueFor( "max_bonus", ability2:GetLevel() - 1 )
		--local modifier = FindModifierByName()
		if max_bonus > caster.curr_agi then
			if max_bonus < caster.curr_agi + bonus_agi then
				bonus_agi = max_bonus - caster.curr_agi
			end
			caster.curr_agi = caster.curr_agi + bonus_agi
			caster:ModifyAgility(bonus_agi)
			caster:CalculateStatBonus()
			creep.bonus_agi = bonus_agi -- чтобы каждый крип знал сколько он добавил ловки герою
			ability2:ApplyDataDrivenModifier(caster, creep, "modifier_illusionist_agility_paws", {})
		end
	end
end

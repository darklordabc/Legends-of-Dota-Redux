function AddModifier(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster

	if target:TriggerSpellAbsorb(ability) then
		return 
	end
		
	if not caster.count_ill then
		caster.count_ill=0
	end

	if string.find(target:GetUnitName(),"megaboss") then
		ability:RefundManaCost()
		ability:EndCooldown()
		--FireGameEvent( 'custom_error_show', { player_ID = event.caster:GetPlayerOwnerID(), _error = "#lia_hud_error_item_lia_staff_of_illusions_megaboss" } )
		return
	end
	
	local durationTarget
	if target:IsHero() then
		durationTarget = ability:GetSpecialValueFor("duration_hero")
	else
		durationTarget = ability:GetSpecialValueFor("duration_other")
	end
	target:EmitSound("Hero_Pugna.Decrepify")
	ability:ApplyDataDrivenModifier(caster, target, 'modifier_illusionist_mastery_of_illusions', {duration = durationTarget} )
	
	-- дадим ловкость Антаро за каждую вызванную иллюзию: повесим модификатор, где будем все делать
	local ability2 = caster:FindAbilityByName('illusionist_agility_paws')

	local bonus_agi = ability2:GetSpecialValueFor("bonus_agility")
	local max_bonus = ability2:GetSpecialValueFor("max_bonus")

	
	if not caster.curr_agi then
		caster.curr_agi = 0
	end

	local count_illusion = ability:GetSpecialValueFor("count_illusion")
	local duration = ability:GetSpecialValueFor("life_illusion")
	local outgoingDamage = ability:GetSpecialValueFor("outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor("incoming_damage")

	local origin = target:GetAbsOrigin()

	for i=1,count_illusion do
		local illus = CreateIllusion(target,caster,origin,duration,outgoingDamage,incomingDamage)

		local ability3 = caster:FindAbilityByName('illusionist_whiff_of_deception')
		if ability3:GetLevel() > 0 then
			caster.count_ill = caster.count_ill +1
			-- отнимание коунтера по смерти иллюзии
			ability3:ApplyDataDrivenModifier(caster, illus, "modifier_illusionist_whiff_of_deception", {})
		end

		if ability2:GetLevel() > 0 then
			if max_bonus > caster.curr_agi then
				if max_bonus < caster.curr_agi + bonus_agi then
					bonus_agi = max_bonus - caster.curr_agi
				end
				caster.curr_agi = caster.curr_agi + bonus_agi
				caster:ModifyAgility(bonus_agi)
				caster:CalculateStatBonus()
				illus.bonus_agi = bonus_agi -- чтобы каждый крип знал сколько он добавил ловки герою
				ability2:ApplyDataDrivenModifier(caster, illus, "modifier_illusionist_agility_paws", {})
			end
		end
	end
end
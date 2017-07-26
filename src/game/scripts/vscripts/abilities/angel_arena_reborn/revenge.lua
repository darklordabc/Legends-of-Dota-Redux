function takedamage(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local reduction_percentage = ability:GetLevelSpecialValueFor("reduce_percent", ability:GetLevel() - 1) / 100

	if not ability:IsCooldownReady() then return end

	if not hero then return end
	if not attacker then return end

	if hero:IsIllusion() then return end
	

	if attacker:IsInvulnerable() then return end

	if attacker == hero then return end

	if attacker:IsBuilding() then return end

	damage = hero:GetIntellect()

	-- Deals damage based on how much more int this hero has
	if attacker:IsHero() then
		local attackersInt = attacker:GetIntellect()
		local castersInt = hero:GetIntellect()
		if attackersInt >= castersInt then
			return
		end
		damage = castersInt - attackersInt
	else
		damage = hero:GetIntellect() * reduction_percentage
	end
	
	if hero:HasModifier("modifier_oracle_false_promise") then return end
	if attacker:HasModifier("modifier_item_blade_mail_reflect") then return end
	if attacker:HasModifier("modifier_nyx_assassin_spiked_carapace") then return end

	if hero:PassivesDisabled() then return end

	

	

	--if hero then 
	--	if hero:GetHealth() > damage - damage*reduction_percentage then
	--		print("HEAL:", damage*reduction_percentage)
	--		hero:Heal(damage * reduction_percentage, ability)
	--	end
	--end

	--local damage_int_pct_add = 1
	--if hero:IsRealHero() then
	--	damage_int_pct_add = hero:GetIntellect()
	--	damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	--end 

	ApplyDamage({ victim = attacker, attacker = hero, damage = damage, damage_type = DAMAGE_TYPE_PURE, abilityReturn = ability })


	--if damage > 2 then
	--	if attacker:GetHealth() < damage + 1 then
	--		attacker:Kill(ability, hero)
	--	else
	--		attacker:SetHealth(attacker:GetHealth() - damage - 1)
	--		attacker:Heal(1, ability) 
	--		ApplyDamage({ victim = attacker, attacker = hero, damage = 1, damage_type = DAMAGE_TYPE_PURE, abilityReturn = ability })
	--		print("apply damage", damage)
	--	end
	--end
	
	if attacker:GetHealth() < 0 then
		attacker:Kill(ability, hero)
	end
	
	local cooldown = ability:GetCooldown( ability:GetLevel() )
	ability:StartCooldown( cooldown )

end
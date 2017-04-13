function CheckLastHitGold( keys )
	local caster = keys.caster
	local target = keys.unit
	local attacker = keys.attacker
	local ability = keys.ability
	local duration = 20
	local Damage = keys.Damage

	local statueAbility = caster:FindAbilityByName("zeros_royal_statue")
	local bonus_gold = statueAbility:GetLevelSpecialValueFor("bonus_gold", ability:GetLevel() - 1)

	attacker.gold_counter = attacker.gold_counter or 0
	target.gold_bounty = target:GetGoldBounty()

	if attacker:GetTeam() == target:GetTeam() then
		target.gold_bounty = 0
	end

	if target:HasModifier("modifier_statue_effect_creep") then 
		target.gold_bounty = target.gold_bounty + bonus_gold 
	end
	
	if attacker:HasModifier("modifier_tax_counter")
	and not attacker:HasModifier("modifier_poverty")
	and not target:IsAlive() then
		attacker.gold_counter = attacker.gold_counter + target.gold_bounty
		Timers:CreateTimer(duration, function ()
			attacker.gold_counter = attacker.gold_counter - target.gold_bounty
			return nil
		end
		)
	end
end

function TaxReturn( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end

	local cpid = caster:GetPlayerID()
	local tpid = target:GetPlayerID()

	local player = PlayerResource:GetPlayer( cpid )
	local enemyPlayer = PlayerResource:GetPlayer( tpid )

	
	local goldPercent = ability:GetLevelSpecialValueFor("gold_loss_pct", ability:GetLevel() - 1) / 100.0
	local dmgPerGold = ability:GetLevelSpecialValueFor("damage_per_gold", ability:GetLevel() - 1)
	local gold_counter = target.gold_counter

	if gold_counter then
		if gold_counter > 0 then
			local cgold = PlayerResource:GetGold(cpid) - PlayerResource:GetReliableGold(cpid)
			local tgold = PlayerResource:GetGold(tpid) - PlayerResource:GetReliableGold(tpid)
			local goldModify = gold_counter * goldPercent

			local goldAdd = cgold + goldModify
			local goldSubtract = tgold - goldModify

			PlayerResource:SetGold(tpid, goldSubtract, false)
			PlayerResource:SetGold(cpid, goldAdd, false)

			DamageTable = {}
	    
		        DamageTable.victim = target
		        DamageTable.attacker = caster
		        DamageTable.damage = goldModify * dmgPerGold
		        DamageTable.damage_type = ability:GetAbilityDamageType()
		        DamageTable.ability = ability

		    ApplyDamage(DamageTable)

--[[		local amount = goldModify * dmgPerGold

		    amount = amount - (amount * target:GetMagicalArmorValue())

		    local lens_count = 0
		    for i=0,5 do
		        local item = caster:GetItemInSlot(i)
		        if item ~= nil and item:GetName() == "item_aether_lens" then
		            lens_count = lens_count + 1
		        end
		    end
		    amount = amount * (1 + (.08 * lens_count))

    		amount = math.floor(amount)
    		PopupNumbers(target, "damage", Vector(153, 0, 204), 2.0, amount, nil, POPUP_SYMBOL_POST_EYE)]]



		    local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, caster, player )
			ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )


			local value = math.floor(goldModify)
			local symbol = 0 -- "+" presymbol
			local color = Vector(255, 200, 33) -- Gold
			local lifetime = 2.0
			local digits = string.len(value) + 1
			local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, caster, player )
			ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
		    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
		    ParticleManager:SetParticleControl( particle, 3, color )


		    local value = math.floor(goldModify)
			local symbol = 1
			local color = Vector(255, 200, 33) -- Gold
			local lifetime = 2.0
			local digits = string.len(value) + 1
			local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
			ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
		    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
		    ParticleManager:SetParticleControl( particle, 3, color )
		end
	end
end

function StealBounty( keys )
	local caster = keys.caster
	local target = keys.unit
	local attacker = keys.attacker
	local ability = keys.ability

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end

	local Damage = keys.Damage
	local cpid = caster:GetPlayerID()
	local player = PlayerResource:GetPlayer( cpid )

	local bounty = target:GetGoldBounty()
	
	if attacker:HasModifier("modifier_poverty") 
	and Damage > target:GetHealth() 
	and target:IsCreep() then
		target:SetTeam(attacker:GetTeam())
		ability:ApplyDataDrivenModifier(caster, target, "modifier_poverty_remove", {duration = 0.1})

		target:Kill(ability, caster)
		attacker:StopSound("Hero_Silencer.LastWord.Target")
		attacker:RemoveModifierByName("modifier_poverty")
		attacker:RemoveModifierByName("modifier_poverty_debuff")

		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
		local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, caster, player )
		ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )


		local value = bounty
		local symbol = 0
		local color = Vector(255, 200, 33) -- Gold
		local lifetime = 2.0
		local digits = string.len(value) + 1
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
		local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, caster, player )
		ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
	    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
	    ParticleManager:SetParticleControl( particle, 3, color )
		
	end
end

function LoseGold( keys )
	local caster = keys.caster
	local target = keys.target
	local tpid = target:GetPlayerID()
	local player = PlayerResource:GetPlayer( tpid )

	local ability = keys.ability
	local goldPercent = ability:GetLevelSpecialValueFor("gold_loss_pct", ability:GetLevel() - 1)/100.0

	local gold = PlayerResource:GetGold(tpid)
	local goldLoss = target:GetDeathGoldCost() * goldPercent
	print(gold)
	print(goldLoss)
	local goldDifference = (gold - goldLoss) - PlayerResource:GetReliableGold(tpid)

	PlayerResource:SetGold(tpid, goldDifference, false)
end

function StackableSlow( keys )
	local caster = keys.caster
	local target = keys.target
	local tpid = target:GetPlayerID()
	local ability = keys.ability


	local stackCount = target:GetModifierStackCount("modifier_poverty_slow", ability)
	if stackCount == 0 then stackCount = 1 end
	print(stackCount)

	local gold = PlayerResource:GetGold(tpid)
	local goldLoss = math.floor(target:GetDeathGoldCost() / 10) + 1
	print(gold)
	print(goldLoss)
	local goldDifference = (gold - goldLoss) - PlayerResource:GetReliableGold(tpid)

	PlayerResource:SetGold(tpid, goldDifference, false)

	target:SetModifierStackCount("modifier_poverty_slow", ability, stackCount + 1)
	EmitSoundOnClient("General.Coins", PlayerResource:GetPlayer(tpid))

	local value = goldLoss
	local symbol = 1
	local color = Vector(255, 200, 33) -- Gold
	local lifetime = 2.0
	local digits = string.len(value) + 1
	local particleName = "particles/msg_fx/msg_gold.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
    ParticleManager:SetParticleControl( particle, 3, color )
end
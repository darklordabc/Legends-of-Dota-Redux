function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function SwapVicissitude( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SwapAbilities("suna_vicissitude", "suna_mind_control", false, true)
	caster:AddNoDraw()
	caster:Stop()

end

function SwapMindControl( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SwapAbilities("suna_mind_control", "suna_vicissitude", false, true)
	caster:RemoveNoDraw()
end

LinkLuaModifier( "vicissitude_super_illusion", "heroes/hero_suna/modifiers/vicissitude_super_illusion.lua", LUA_MODIFIER_MOTION_NONE )

function MindControlAdd( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		caster:Stop()
		return
	end

	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	caster:RemoveNoDraw()
	target:AddNoDraw()

	-- Taken from Skoros' Nexus ability
	target.nexusdouble = CreateUnitByName( target:GetUnitName(), target:GetAbsOrigin(), false, caster, caster:GetOwner(), caster:GetTeamNumber())
	--target.nexusdouble:MakeClone
	target.nexusdouble:SetAngles(0, target:GetAngles().y, 0)
	target.nexusdouble:AddNewModifier(caster, ability, "vicissitude_super_illusion", {duration = -1})
	ability:ApplyDataDrivenModifier(caster, target.nexusdouble, "modifier_vicissitude_dummy", {duration = -1})
	if caster:HasScepter() then
		target.nexusdouble:AddNewModifier(caster, nil, "modifier_rune_haste", {duration = -1})
		target.nexusdouble:AddNewModifier(caster, nil, "modifier_omniknight_repel", {duration = -1})
	end
	--ability:ApplyDataDrivenModifier(caster, target, "Nexus_Sync_Casts", {duration = -1})
	target.nexusdouble:SetControllableByPlayer(caster:GetPlayerID(), false)
	target.nexusdouble:MoveToPositionAggressive(caster:GetAbsOrigin())
	
	if target:IsHero() then
		local caster_level = caster:GetLevel()
		for i = 2, caster_level do
			target.nexusdouble:HeroLevelUp(false)
		end
		for ability_id = 0, 15 do
			local ability = target.nexusdouble:GetAbilityByIndex(ability_id)
			if ability then
				ability:SetLevel(caster:GetAbilityByIndex(ability_id):GetLevel())
			end
		end
		for item_id = 0, 5 do
			local item_in_caster = caster:GetItemInSlot(item_id)
			if item_in_caster ~= nil then
				local item_name = item_in_caster:GetName()
				if not (item_name == "item_aegis" or item_name == "item_smoke_of_deceit" or item_name == "item_recipe_refresher" or item_name == "item_refresher" or item_name == "item_ward_observer" or item_name == "item_ward_sentry" or item_name == "item_bottle" or item_name == "item_blink" or item_name == "item_travel_boots" or item_name == "item_travel_boots_2" or item_name == "item_tpscroll") then
					local item_created = CreateItem( item_in_caster:GetName(), target.nexusdouble, target.nexusdouble)
					target.nexusdouble:AddItem(item_created)
					item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
					item_created:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
				end
			end
		end
		target.nexusdouble:SetAbilityPoints(0)
		target.nexusdouble:SetHasInventory(false)
	end
	Timers:CreateTimer(0.01, function()  
		if not target.nexusdouble:IsNull() then
			target:SetAngles(0, target.nexusdouble:GetAngles().y, 0)
			target:SetAbsOrigin(target.nexusdouble:GetAbsOrigin())
		--else 
			--return -1
		end
	return 0.01
	end) 
end

function MindControlRemove( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:RemoveNoDraw()
	target.nexusdouble:RemoveSelf()

end

function SetBurrowLocation( keys )
	local caster = keys.caster
	local target = keys.target

	if caster:HasModifier("modifier_vicissitude_burrow") then
		target:SetAbsOrigin(caster:GetAbsOrigin())
	else
		target:ForceKill(false)
	end
end

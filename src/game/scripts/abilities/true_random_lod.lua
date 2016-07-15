local Timers = require('easytimers')

function RandomGet(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(caster.randomAb)
	if not IsValidEntity(randomAb) then
		randomAb = caster:AddAbility(caster.randomAb)
		if caster.subAb then
		    subAb = caster:AddAbility(caster.subAb)
		end
	end
	local maxLevel = randomAb:GetMaxLevel()
	
	-- Leveling filters; 1 is the ultimate type
	if randomAb:GetAbilityType() ~= 1 then
		local level = ability:GetLevel()
		if ability:GetLevel() > maxLevel then level = maxLevel end
		randomAb:SetLevel(level)
	else 
		-- Clamp level to lowest achievable level; if ability is level 1 always use level 1 ultimate; otherwise check for caster's level
		local clamp = ability:GetLevel()
		if ability:GetLevel() > math.floor(caster:GetLevel()/5) then clamp = math.floor(caster:GetLevel()/5) end
		if clamp > maxLevel then clamp = maxLevel end
		if clamp < 1 then clamp = 1 end
		print(ability:GetLevel(), math.floor(caster:GetLevel()/5), maxLevel)
		randomAb:SetLevel(clamp)
	end
	if caster.prevAbility then 
		local prevAb = caster:FindAbilityByName(caster.prevAbility)
		randomAb:StartCooldown(prevAb:GetCooldownTimeRemaining())
	end
	caster:SwapAbilities(randomAb:GetName(), ability:GetName(), true, false)
	StartSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
end

function GetAbilityCount(unit) 
	local count = 0
	for i=0,16 do
		if unit:GetAbilityByIndex(i) then
			count = count + 1
		end
	end
	return count
end

function RandomRemove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(caster.randomAb)
	
	-- Level main ability if random ability is leveled
	if randomAb:GetLevel() > ability:GetLevel() then ability:SetLevel(randomAb:GetLevel()) end
	if IsValidEntity(randomAb) then
		caster:SwapAbilities(ability:GetName(), randomAb:GetName(), true, false)
		randomAb:SetHidden(true) -- double check for flyout
	end
	if caster.safeRemoveList then 
		-- caster:RemoveAbility(caster.lastAbility)
		local abName = caster.randomAb
		if caster.randomKv["safe"][abName] then
			caster:RemoveAbility(abName)
			if caster.subAb then
			    subAb = caster:RemoveAbility(caster.subAb)
			end
		else
			caster.safeRemoveList[abName] = false
			local timer = randomAb:GetCooldownTime(-1)
			if timer < randomAb:GetDuration() then timer = randomAb:GetDuration() end
			Timers:CreateTimer(function()
				caster.safeRemoveList[abName] = true
	        	return nil
	    	end, abName..math.random(99999), timer)
		end

		for k,v in pairs(caster.safeRemoveList) do
	    	if v == true and caster:FindAbilityByName(k) and caster:FindAbilityByName(k):IsHidden() == true then
	    		caster:RemoveAbility(k)
	    	end
	    end
	end

	local picker = math.random(#caster.randomSelection)
	caster.randomAb = caster.randomSelection[picker]

	if GetAbilityCount(caster) > caster.initialAb then
		picker = math.random(#caster.randomSafeSelection)
		caster.randomAb = caster.randomSafeSelection[picker]
	end

	if caster.subList[caster.randomAb] then 
		caster.subAb = caster.subList[caster.randomAb]	
	else
		caster.subAb = nil
	end
end

function RandomInit(keys)
	local ability = keys.ability
	local caster = keys.caster
	caster.randomKv = LoadKeyValues('scripts/kv/randompicker.kv')
	caster.safeRemoveList = {}
	caster.random = ability
	caster.subList = LoadKeyValues('scripts/kv/abilityDeps.kv')
	-- find desired flags
	for k, v in pairs( caster.randomKv ) do
		if k == keys.value then
			-- change values to ascending sequence
			local i = 1
			for l,m in pairs(v) do
				v[l] = i
				i = i + 1
			end
			-- invert keys and values to make ability names the value; second step to turning table into array
			local s={}
			for l,m in pairs(v) do
				s[m]=l
			end
			caster.randomSelection = s
		end
		if k == "safe" then
			-- change values to ascending sequence
			local i = 1
			for l,m in pairs(v) do
				v[l] = i
				i = i + 1
			end
			-- invert keys and values to make ability names the value; second step to turning table into array
			local s={}
			for l,m in pairs(v) do
				s[m]=l
			end
			caster.randomSafeSelection = s
		end
	end
	local picker = math.random(#caster.randomSelection)
	caster.randomAb = caster.randomSelection[picker]
	if caster.subList[caster.randomAb] then caster.subAb = caster.subList[caster.randomAb] end
	caster.initialAb = GetAbilityCount(caster)
end

local Timers = require('easytimers')
local util = require('util')
local skillManager = require('skillmanager')

function RandomGet(keys)
	local caster = keys.caster
	local ability = keys.ability
	skillManager:precacheSkill(caster.randomAb, function() return 1 end) -- dynamic caching
	print(caster.randomAb, "wtf")
	local randomAb = caster:FindAbilityByName(caster.randomAb)
	if not randomAb then
		randomAb = caster:AddAbility(caster.randomAb)
		if caster.subAb then
		    subAb = caster:AddAbility(caster.subAb)
		end
	end
	
	-- SAFETY MEASURE UNTIL WEIRD NIL BUG IS FOUNF
	if not randomAb then
		local picker = math.random(#ability.randomSelection)
		caster.randomAb = ability.randomSelection[picker]
		if ability.subList[caster.randomAb] then caster.subAb = ability.subList[caster.randomAb] end
		local randomAb = caster:FindAbilityByName(caster.randomAb)
		if not randomAb then
			randomAb = caster:AddAbility(caster.randomAb)
			if caster.subAb then
				subAb = caster:AddAbility(caster.subAb)
			end
		end
	end
	--------- REMOVE ONCE BUG FOUND -------------
	
	-- Leveling filters; 1 is the ultimate type
	local maxLevel = randomAb:GetMaxLevel()
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
	if caster.subAb and caster.subActivated then randomAb = caster:FindAbilityByName(caster.subAb) end
	print(randomAb:GetName())
	-- Level main ability if random ability is leveled
	if randomAb:GetLevel() > ability:GetLevel() then ability:SetLevel(randomAb:GetLevel()) end
	if IsValidEntity(randomAb) then
		caster:SwapAbilities(ability:GetName(), randomAb:GetName(), true, false)
		randomAb:SetHidden(true) -- double check for flyout
	end
	if ability.safeRemoveList then 
		-- caster:RemoveAbility(caster.lastAbility)
		local abName = caster.randomAb
		if ability.randomKv["safe"..ability.type][abName] then
			caster:RemoveAbility(abName)
			if ability.subList[abName] then caster.subAb = ability.subList[abName] end
			if caster.subAb then
			    subAb = caster:RemoveAbility(caster.subAb)
			end
		else
			ability.safeRemoveList[abName] = false
		    local setdelay = randomAb:GetCooldown(-1)
		    local buffer = 2
            local timer = getAbilityDuration(randomAb, setdelay, buffer)
			Timers:CreateTimer(function()
				ability.safeRemoveList[abName] = true
				for k,v in pairs(ability.safeRemoveList) do
					if v == true and caster:FindAbilityByName(k) and caster:FindAbilityByName(k):IsHidden() == true then
						caster:RemoveAbility(k)
						if ability.subList[k] then caster:RemoveAbility(ability.subList[k]) end
						print(k, ability.subList[k])
					end
				end
	        	return nil
	    	end, abName..math.random(99999), timer)
		end
	end

	local picker = math.random(#ability.randomSelection)
	caster.randomAb = ability.randomSelection[picker]
	if 15 < GetAbilityCount(caster) then
		picker = math.random(#ability.randomSafeSelection )
		local pickedSkill = ability.randomSafeSelection [picker]
		if not caster.ownedSkill[pickedSkill] then
			caster.randomAb = pickedSkill
			print(picker,pickedSkill)
		else
			local pickedSkill
			while caster.ownedSkill[pickedSkill] do
				picker = math.random(#ability.randomSafeSelection )
				pickedSkill = ability.randomSafeSelection [picker]
				print(picker,pickedSkill)
			end
			caster.randomAb = pickedSkill
		end
	end
	caster.subAb = ability.subList[caster.randomAb]	
end

function RandomInit(keys)
	local ability = keys.ability
	local caster = keys.caster
	ability.type = keys.value
	ability.randomKv = LoadKeyValues('scripts/kv/randompicker.kv')
	ability.safeRemoveList = {}
	caster.random = ability
	ability.subList = LoadKeyValues('scripts/kv/abilityDeps.kv')
	-- check currently owned and visible skills to prevent repeats
	caster.ownedSkill={}
	for i = 0, GetAbilityCount(caster)-1 do
		local exclusion = caster:GetAbilityByIndex(i):GetName()
		if not caster:FindAbilityByName(exclusion):IsHidden() then
			caster.ownedSkill[exclusion] = true
		end
	end
	-- find desired flags
	for k, v in pairs( ability.randomKv ) do
		local x = {} -- xclusion
		if k == ability.type then
			-- change values to ascending sequence
			local i = 1
			for l,m in pairs(v) do
				if not caster.ownedSkill[l] then -- do not add already owned skills to possible set
					x[l] = i
					i = i + 1
				end
			end
			-- invert keys and values to make ability names the value; second step to turning table into array
			local s={}
			for l,m in pairs(x) do
				s[m]=l
			end
			ability.randomSelection = s
		end
		if k == "safe"..ability.type then
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
			ability.randomSafeSelection  = s
		end
	end
	local picker = math.random(#ability.randomSelection)
	caster.randomAb = ability.randomSelection[picker]
	if ability.subList[caster.randomAb] then caster.subAb = ability.subList[caster.randomAb] end
end

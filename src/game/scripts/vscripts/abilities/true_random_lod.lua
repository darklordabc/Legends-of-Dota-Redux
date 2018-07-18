--local timers = require('easytimers')
local skillManager = require('skillmanager')
local pregame = require('pregame')

function RandomGet(keys)
	print('get')
	local caster = keys.caster
	local ability = keys.ability
	
	skillManager:precacheSkill(ability.randomAb, function() return 1 end) -- dynamic caching
	
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	
	if not randomAb then
		randomAb = caster:AddAbility(ability.randomAb)
	end
	
	if not randomAb then
		ability.randomAb = GetNextAbility(caster.randomSelection)
		randomAb = caster:AddAbility(ability.randomAb)
		if not randomAb then
			if 3 <= caster:GetUnsafeAbilitiesCount() or caster:GetAbilityCount() > 13  then
				ability.randomAb = GetNextAbility(caster.randomSafeSelection)
				while caster.ownedSkill[ability.randomAb] do
					ability.randomAb = GetNextAbility(caster.randomSafeSelection)
				end
			randomAb = caster:AddAbility(ability.randomAb)
			end
		end
	end

	if randomAb then
		randomAb.randomRoot = ability:GetName()
	else
		return
	end

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
	local cooldown = ability:GetTrueCooldown()
	randomAb:StartCooldown(cooldown)
	caster:SwapAbilities(randomAb:GetName(), ability:GetName(), true, false)
	-- StopSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
	-- StartSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
end

function RandomRemove(keys)
	print('remove')
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	caster.cooldown = randomAb:GetCooldownTimeRemaining()
	-- if caster.subAb and caster.subActivated then randomAb = caster:FindAbilityByName(caster.subAb) end
	-- Level main ability if random ability is leveled
	if randomAb:GetLevel() > ability:GetLevel() then ability:SetLevel(randomAb:GetLevel()) end
	
	if IsValidEntity(randomAb) then
		
		caster:SwapAbilities(ability:GetName(), randomAb:GetName(), true, false)
		
		randomAb:SetHidden(true) -- double check for flyout
		
	end
	
	if caster.safeRemoveList then 
		-- caster:RemoveAbility(caster.lastAbility)
		local abName = ability.randomAb
		if caster.randomKv["Safe"][abName] then
			caster:RemoveAbility(abName)
		else
			caster.safeRemoveList[abName] = false
		    local buffer = 3
            local timer = randomAb:GetAbilityLifeTime(buffer)
			Timers:CreateTimer(function()
				caster.safeRemoveList[abName] = true
				for k,v in pairs(caster.safeRemoveList) do
					if v == true and caster:FindAbilityByName(k) and caster:FindAbilityByName(k):IsHidden() then
						caster:RemoveAbility(k)
						-- if ability.subList[k] then caster:RemoveAbility(ability.subList[k]) end
					end
				end
	        	return nil
	    	end, abName..math.random(99999), timer)
		end
	end
	-------- STANDARD CHECK ---------
	ability.randomAb = GetNextAbility(caster.randomSelection)
	
	
	
	if 3 <= caster:GetUnsafeAbilitiesCount() or caster:GetAbilityCount() >= 13  then
		local pickedSkill = GetNextAbility(caster.randomSafeSelection)
		while caster.ownedSkill[pickedSkill] do
			pickedSkill = GetNextAbility(caster.randomSafeSelection)
		end
		ability.randomAb = pickedSkill
	end
	----------- CHECK FOR DOUBLES ----------
	while caster:FindAbilityByName(ability.randomAb) do
		ability.randomAb = GetNextAbility(caster.randomSelection)
		if 3 <= caster:GetUnsafeAbilitiesCount() or caster:GetAbilityCount() > 13  then
			local pickedSkill = GetNextAbility(caster.randomSafeSelection)
			if not caster.ownedSkill[pickedSkill] then
				ability.randomAb = pickedSkill
			end
		end
	end
end

function GetNextAbility(input)
	local nextAbName = input[1]
	util:MoveArray(input)
	return nextAbName
end

function RandomInit(keys)
	local caster = keys.caster
	if caster:IsIllusion() then return end
	local ability = keys.ability
	if ability.isCreated then return end -- Prevent this from triggering on death
	caster.randomAbilityCount = caster.randomAbilityCount and caster.randomAbilityCount + 1 or 0
	-- ability.abCount = 1
	caster.randomKv = caster.randomKv or LoadKeyValues('scripts/kv/randompicker.kv')
	caster.safeRemoveList = caster.safeRemoveList or {}
	local subAbilities = LoadKeyValues('scripts/kv/abilityDeps.kv')
	local mainAbilities = {}
	for l,m in pairs(subAbilities) do
		mainAbilities[m]=l
	end
	-- check currently owned and visible skills to prevent repeats
	if not caster.ownedSkill then
		caster.ownedSkill={}
		for i = 0, caster:GetAbilityCount() -1 do
			local exclusion = caster:GetAbilityByIndex(i):GetName()
			local exAb = caster:FindAbilityByName(exclusion)
			if not exAb:IsHidden() then
				caster.ownedSkill[exclusion] = true
			elseif exAb:GetName() ~= "attribute_bonus" and mainAbilities[exclusion] == nil and OptionManager:GetOption('mapname') ~= "custom_bot" then -- do not remove attribute bonus or subabilities (exclude bots for now)
				caster:RemoveAbility(exclusion)
			end
		end
	end
	if not caster.randomSelection then
		for k, v in pairs( caster.randomKv ) do
			local x = {} -- xclusion
			if k == "All" then
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
				caster.randomSelection = s
				ShuffleArray(caster.randomSelection)
			end
			if k == "Safe" then
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
				ShuffleArray(caster.randomSafeSelection)
			end
		end
	end
	ability.randomAb = GetNextAbility(caster.randomSelection)
	ability.isCreated = true
	while caster:FindAbilityByName(ability.randomAb) do
		ability.randomAb = GetNextAbility(caster.randomSelection)
		if 3 <= caster:GetUnsafeAbilitiesCount() or caster:GetAbilityCount() > 13  then
			local pickedSkill = GetNextAbility(caster.randomSafeSelection)
			if not caster.ownedSkill[pickedSkill] then
				ability.randomAb = pickedSkill
			end
		end
	end
end

function Particles(keys)
	if not keys.caster:FindAbilityByName(keys.ability.randomAb) then return end
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	if randomAb:IsCooldownReady() and not ability.proc then
		StartSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
        particle_swap = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW  , keys.caster)
		ParticleManager:SetParticleControl(particle_swap, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_swap, 1, caster:GetAbsOrigin())
		ability.proc = true
	elseif not randomAb:IsCooldownReady() then
		ability.proc = false
    end
end

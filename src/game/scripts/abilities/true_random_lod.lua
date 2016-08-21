local Timers = require('easytimers')
local util = require('util')
local skillManager = require('skillmanager')

function RandomGet(keys)
	local caster = keys.caster
	local ability = keys.ability
	skillManager:precacheSkill(ability.randomAb, function() return 1 end) -- dynamic caching
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	if not randomAb then
		randomAb = caster:AddAbility(ability.randomAb)
		if ability.randomAb then caster.ownedSkill[ability.randomAb] = true end
	end
	if not randomAb then
		local picker = ability.abCount
		ability.randomAb = ability.randomSelection[picker]
		randomAb = caster:AddAbility(ability.randomAb)
		if ability.randomAb then caster.ownedSkill[ability.randomAb] = true end
	end
	-- if not randomAb then
	-- 	picker = math.random(#ability.randomSafeSelection)
	-- 	local pickedSkill = ability.randomSafeSelection[picker]
	-- 	while caster.ownedSkill[pickedSkill] or pickedSkill == nil do
	-- 		picker = math.random(#ability.randomSafeSelection)
	-- 		pickedSkill = ability.randomSafeSelection[picker]
	-- 	end
	-- 	randomAb = caster:AddAbility(pickedSkill)
	-- 	caster.ownedSkill[pickedSkill] = true
	-- end
	if not randomAb then 
		ShowGenericPopupToPlayer(caster:GetOwner(), "No slots available, try again later!","No slots available, try again later!", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	randomAb.randomRoot = ability:GetName()
	
	
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
	ability.abCount = ability.abCount + 1
	if ability.abCount >= #ability.randomSelection then
		ShuffleArray(ability.randomSelection)
		ability.abCount = 1
	end
	StartSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
end

function RandomRemove(keys)
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
	
	if ability.safeRemoveList then 
		-- caster:RemoveAbility(caster.lastAbility)
		local abName = ability.randomAb
		if ability.randomKv[ability.type.."Safe"][abName] then
			caster:RemoveAbility(abName)
			caster.ownedSkill[abName] = nil

			-- if ability.subList[abName] then caster.subAb = ability.subList[abName] end
			-- if caster.subAb then
			    -- subAb = caster:RemoveAbility(caster.subAb)
			-- end
		else
			caster.randomPool = caster.randomPool + 1
			ability.safeRemoveList[abName] = false
		    local buffer = 3
            local timer = randomAb:GetAbilityLifeTime(buffer)
			Timers:CreateTimer(function()
				ability.safeRemoveList[abName] = true
				for k,v in pairs(ability.safeRemoveList) do
					if v == true and caster:FindAbilityByName(k) and caster:FindAbilityByName(k):IsHidden() then
						caster:RemoveAbility(k)
						caster.ownedSkill[k] = nil
						caster.randomPool = caster.randomPool - 1
						-- if ability.subList[k] then caster:RemoveAbility(ability.subList[k]) end
					end
				end
	        	return nil
	    	end, abName..math.random(99999), timer)
		end
	end
	-------- STANDARD CHECK ---------
	local picker = ability.abCount
	ability.randomAb = ability.randomSelection[picker]
	if 15 - caster.randomAbilityCount < caster:GetAbilityCount()  then
		picker = math.random(#ability.randomSafeSelection)
		local pickedSkill = ability.randomSafeSelection[picker]
		while caster.ownedSkill[pickedSkill] do
			picker = math.random(#ability.randomSafeSelection)
			pickedSkill = ability.randomSafeSelection[picker]
		end
		ability.randomAb = pickedSkill
	end
	----------- CHECK FOR DOUBLES ----------
	while caster:FindAbilityByName(ability.randomAb) do
		ability.abCount = ability.abCount + 1 -- skip entries while they're owned
		local picker = ability.abCount
		ability.randomAb = ability.randomSelection[picker]
		if 15 - caster.randomAbilityCount < caster:GetAbilityCount()  then
			picker = math.random(#ability.randomSafeSelection)
			local pickedSkill = ability.randomSafeSelection[picker]
			if not caster.ownedSkill[pickedSkill] then
				ability.randomAb = pickedSkill
			end
		end
	end
end

function RandomInit(keys)
	local caster = keys.caster
	if caster:IsIllusion() then return end
	local ability = keys.ability
	if ability.randomSelection then return end -- Prevent this from triggering on death
	caster.randomAbilityCount = caster.randomAbilityCount and caster.randomAbilityCount + 1 or 0
	caster.randomPool = caster.randomPool and caster.randomPool + 1 or 0
	ability.abCount = 1
	ability.type = keys.value
	ability.randomKv = LoadKeyValues('scripts/kv/randompicker.kv')
	ability.safeRemoveList = {}
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
			elseif exAb:GetName() ~= "attribute_bonus" and mainAbilities[exclusion] == nil and GetMapName() ~= "custom_bot" then -- do not remove attribute bonus or subabilities (exclude bots for now)
				caster:RemoveAbility(exclusion)
			end
		end
	end
	-- find desired flags
	for k, v in pairs( ability.randomKv ) do
		local x = {} -- xclusion
		if k == keys.value then
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
			ShuffleArray(ability.randomSelection)
		end
		if k == ability.type.."Safe" then
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
	local picker = ability.abCount
	ability.randomAb = ability.randomSelection[picker]
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


function RandomGet(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(caster.randomAb)
	if not randomAb then
		randomAb = caster:AddAbility(caster.randomAb)
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

function RandomRemove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(caster.randomAb)
	
	-- Level main ability if random ability is leveled
	if randomAb:GetLevel() > ability:GetLevel() then ability:SetLevel(randomAb:GetLevel()) end
	if caster.lastAbility then 
		caster:RemoveAbility(caster.lastAbility)
	end
	if randomAb then
		caster:SwapAbilities(ability:GetName(), randomAb:GetName(), true, false)
		randomAb:SetHidden(true) -- double check for flyout
	end
	caster.lastAbility = caster.penultimateAbility
	caster.penultimateAbility = caster.prevAbility
	caster.prevAbility = caster.randomAb
	local picker = math.random(#caster.randomSelection)
	caster.randomAb = caster.randomSelection[picker]	
	if caster.subList[caster.randomAb] then 
		caster.subAb = caster.subList[caster.randomAb]	
	else
		caster.subAb = nil
	end
end

function RandomInit(keys)
	local kv = LoadKeyValues('scripts/kv/randompicker.kv')
	local ability = keys.ability
	local caster = keys.caster
	caster.random = ability
	caster.subList = LoadKeyValues('scripts/kv/abilityDeps.kv')
	-- find desired flags
	for k, v in pairs( kv ) do
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
	end
	local picker = math.random(#caster.randomSelection)
	caster.randomAb = caster.randomSelection[picker]
	if caster.subList[caster.randomAb] then caster.subAb = caster.subList[caster.randomAb] end
end
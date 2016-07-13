
function RandomGet(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:AddAbility(ability.randomAb)
	local maxLevel = randomAb:GetMaxLevel()
	
	-- Leveling filters
	if ability:GetAbilityType() ~= DOTA_ABILITY_TYPE_ULTIMATE then
		local level = ability:GetLevel()
		if ability:GetLevel() > maxLevel then level = maxLevel end
		randomAb:SetLevel(level)
	else 
		-- Clamp level to lowest achievable level; if ability is level 1 always use level 1 ultimate; otherwise check for caster's level
		local clamp = ability:GetLevel()
		if ability:GetLevel() > math.floor(caster:GetLevel()/5) then qualifier = math.floor(caster:GetLevel()/5) end
		if qualifier > maxLevel then qualifier = maxLevel end
		if qualifier < 1 then qualifier = 1 end
		randomAb:SetLevel(clamp)
	end
	
	caster:SwapAbilities(randomAb:GetName(), ability:GetName(), true, false)
	StartSoundEvent("Hero_VengefulSpirit.ProjectileImpact", caster)
end

function RandomRemove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	
	-- Level main ability if random ability is leveled
	if randomAb:GetLevel() > ability:GetLevel() then ability:SetLevel(randomAb:GetLevel()) end
	
	caster:SwapAbilities(ability:GetName(), randomAb:GetName(), true, false)
	ability.prevAbility = ability.randomAb
	local picker = math.random(1,#ability.randomSelection)
	ability.randomAb = ability.randomSelection[picker]	
end

function CooldownCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local randomAb = caster:FindAbilityByName(ability.randomAb)
	if not randomAb:IsCooldownReady() then
		ability.spellused = true
	end
	if randomAb:IsCooldownReady() and ability.spellused and not randomAb:IsChanneling() then
		if ability.prevAbility then caster:RemoveAbility(ability.prevAbility) end
		ability:OnChannelFinish(true)
		ability:OnAbilityPhaseStart()
		ability.spellused = false
	end	
end

function RandomInit(keys)
	local kv = LoadKeyValues('scripts/kv/randompicker.kv')
	local ability = keys.ability
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
			ability.randomSelection = s
		end
	end
	local picker = math.random(1,#ability.randomSelection)
	ability.randomAb = ability.randomSelection[picker]	
	ability:OnAbilityPhaseStart()
end
modifier_neutral_power = class({})

function modifier_neutral_power:IsHidden()
	return false	
end

function modifier_neutral_power:IsPermanent()
	return true	
end

function modifier_neutral_power:IsPurgable()
	return false	
end

function modifier_neutral_power:OnCreated(kv)
	if IsServer() then
		local unit = self:GetCaster()
		local interval_time = kv.interval_time	
		local dotaTime = GameRules:GetDOTATime(false, false)
		local initial_stacks = math.floor(dotaTime / interval_time)                                        

		self:SetStackCount(initial_stacks)	

		local time_to_next_level = interval_time - (dotaTime % interval_time)
		Timers:CreateTimer(time_to_next_level, function()
			self:IncrementStackCount()
			local stacks = self:GetStackCount()
			CalculateNewStats(unit, stacks)
			self:StartIntervalThink(interval_time)
		end)
	end
end

function modifier_neutral_power:OnIntervalThink()
	local unit = self:GetCaster()
	local stacks = self:GetStackCount()
	CalculateNewStats(unit, stacks)

	self:IncrementStackCount()
end

function modifier_neutral_power:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_neutral_power:DeclareFunctions()	
		local decFuncs = {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
						 MODIFIER_PROPERTY_MODEL_SCALE,
						 MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
		
		return decFuncs	
end

function modifier_neutral_power:GetModifierBaseAttack_BonusDamage()
	local stacks = self:GetStackCount()
	local damage_per_level = 5
	
	return damage_per_level * stacks
end

function modifier_neutral_power:GetModifierModelScale()
	local stacks = self:GetStackCount()
	local initial_scale = 1
	local model_scale_per_level = 0.02

	return initial_scale + model_scale_per_level * stacks
end

function modifier_neutral_power:GetModifierConstantHealthRegen()
	local stacks = self:GetStackCount()
	local regen_per_level = 0.1

	return regen_per_level * stacks
end

function CalculateNewStats(unit, stacks)
	local health_per_stack = 100	
	local extra_gold_per_stack = 5
	local extra_exp_per_stack = 5

	-- Modify Health
	unit:SetMaxHealth(unit:GetMaxHealth() + health_per_stack)	
	unit:SetHealth(unit:GetMaxHealth())

	-- Bounties
    unit:SetDeathXP(unit:GetDeathXP() + extra_exp_per_stack)    
    unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() + extra_gold_per_stack)
    unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() + extra_gold_per_stack)
end
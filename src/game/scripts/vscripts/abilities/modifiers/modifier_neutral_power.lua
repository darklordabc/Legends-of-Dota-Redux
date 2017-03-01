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

function modifier_neutral_power:GetTexture()
	return "custom/neutral_creep_power"
end

function modifier_neutral_power:OnCreated(kv)
	if IsServer() then
		local unit = self:GetCaster()
		local interval_time = kv.interval_time	
		local dotaTime = GameRules:GetDOTATime(false, false)
		local initial_stacks = math.floor(dotaTime / interval_time)                                        

		-- Wait one game tick for proper team assignments, then ask if the modifier still exists
		Timers:CreateTimer(0.03, function()
			if not self:IsNull() then
				print("new modifier was created")

				self:SetStackCount(initial_stacks)			
				CalculateNewStats(unit, initial_stacks, true)

				local time_to_next_level = interval_time - (dotaTime % interval_time)
				Timers:CreateTimer(time_to_next_level, function()
					if not self:IsNull() then
						self:IncrementStackCount()			
						self:StartIntervalThink(interval_time)
					end
					
				end)
			end			
		end)		
	end
end

function modifier_neutral_power:OnIntervalThink()
	if IsServer() then
		local unit = self:GetCaster()
		local stacks = self:GetStackCount()
		CalculateNewStats(unit, stacks, false)

		self:IncrementStackCount()
	end
end

function modifier_neutral_power:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_neutral_power:DeclareFunctions()	
		local decFuncs = {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
						 MODIFIER_PROPERTY_MODEL_SCALE,
						 MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
						 MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
		
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

function modifier_neutral_power:GetModifierIncomingDamage_Percentage()
	local unit = self:GetCaster()
	local damage_reduction = -1
	local stacks = self:GetStackCount()

	if unit:GetUnitName() == "npc_dota_roshan" then
		return damage_reduction * stacks
	end

	return 0
end

function CalculateNewStats(unit, stacks, firstInstance)
	if IsServer() then
		local health_per_stack = 100	
		local extra_gold_per_stack = 5
		local extra_exp_per_stack = 5

		-- Increase depending on initial call or interval
		if firstInstance then
			health_per_stack = health_per_stack * stacks
			extra_gold_per_stack = extra_gold_per_stack * stacks
			extra_exp_per_stack = extra_exp_per_stack * stacks
		end

		-- Modify Health
		unit:SetBaseMaxHealth(unit:GetBaseMaxHealth() + health_per_stack)	
		unit:SetMaxHealth(unit:GetMaxHealth() + health_per_stack)
		unit:SetHealth(unit:GetHealth() + health_per_stack)

		-- Bounties
	    unit:SetDeathXP(unit:GetDeathXP() + extra_exp_per_stack)    
	    unit:SetMinimumGoldBounty(unit:GetMinimumGoldBounty() + extra_gold_per_stack)
	    unit:SetMaximumGoldBounty(unit:GetMaximumGoldBounty() + extra_gold_per_stack)
	end
end
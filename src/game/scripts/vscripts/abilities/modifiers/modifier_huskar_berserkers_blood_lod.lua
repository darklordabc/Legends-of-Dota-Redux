if modifier_huskar_berserkers_blood_lod == nil then
    modifier_huskar_berserkers_blood_lod = class({})
end

--[[Author: Bude
	Date: 30.09.2015.
	Grants magical resistance and attackspeed and increases model size per modifier stack
	TODO: Particles and status effects need to be implemented correctly
	NOTE: Model size increase is probably inaccurate and also awfully jumpy
]]--

function modifier_huskar_berserkers_blood_lod:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

--As described: Could not get the particles to work ...
--[[
function modifier_huskar_berserkers_blood_lua:GetStatusEffectName()
	return "particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf"
end
function modifier_huskar_berserkers_blood_lua:GetStatusEffectPriority()
	return 16
end
]]--

function modifier_huskar_berserkers_blood_lod:IsPassive()
	return true
end

function modifier_huskar_berserkers_blood_lod:IsPurgable()
    return false
end

function modifier_huskar_berserkers_blood_lod:RemoveOnDeath()
	return false
end

function modifier_huskar_berserkers_blood_lod:IsHidden()
	
	if self:GetStackCount() > 1 then 
		return false
	else 
		return true
	end
end

function modifier_huskar_berserkers_blood_lod:OnCreated()
	-- Variables
	self.berserkers_blood_damage = self:GetAbility():GetSpecialValueFor( "damage_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
	-- self.berserkers_blood_model_size = self:GetAbility():GetSpecialValueFor("model_size_per_stack")
	self.berserkers_blood_hurt_health_ceiling = 0.87--self:GetAbility():GetSpecialValueFor("hurt_health_ceiling")
	self.berserkers_blood_hurt_health_floor = 0.03--self:GetAbility():GetSpecialValueFor("hurt_health_floor")
	self.berserkers_blood_hurt_health_step = 0.07--self:GetAbility():GetSpecialValueFor("hurt_health_step")


    if IsServer() then
        --print("Created")
        self:SetStackCount( 1 )
		self:GetParent():CalculateStatBonus()

		self:StartIntervalThink(0.1) 
    end
end

function modifier_huskar_berserkers_blood_lod:OnIntervalThink()
	if IsServer() then
		--print("Thinking")

		-- Variables
		local caster = self:GetParent()
		local oldStackCount = self:GetStackCount()
		local health_perc = caster:GetHealthPercent()/100
		local newStackCount = 1
		
		if caster:IsAlive() and caster:PassivesDisabled() == false then 
			-- local model_size = self.berserkers_blood_model_size
			local hurt_health_ceiling = self.berserkers_blood_hurt_health_ceiling
			local hurt_health_floor = self.berserkers_blood_hurt_health_floor
			local hurt_health_step = self.berserkers_blood_hurt_health_step


			for current_health=hurt_health_ceiling, hurt_health_floor, -hurt_health_step do
				if health_perc <= current_health then

					newStackCount = newStackCount+1
				else
					break
				end
			end
		   

			local difference = newStackCount - oldStackCount
			

			-- set stackcount
			if difference ~= 0 then
				--caster:SetModelScale(caster:GetModelScale()+difference*model_size)
				self:SetStackCount( newStackCount )
				self:ForceRefresh()
			end
		else
			self:SetStackCount( 0 )
		end
		
	end
end

function modifier_huskar_berserkers_blood_lod:OnRefresh()
	self.berserkers_blood_damage = self:GetAbility():GetSpecialValueFor( "damage_per_stack" )
	self.berserkers_blood_attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus_per_stack" )
	local StackCount = self:GetStackCount()
	local caster = self:GetParent()

    if IsServer() then
        self:GetParent():CalculateStatBonus()
    end
end


function modifier_huskar_berserkers_blood_lod:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT 
	}

	return funcs
end

function modifier_huskar_berserkers_blood_lod:GetModifierPreAttack_BonusDamage( params )
	return self:GetStackCount() * self.berserkers_blood_damage
end

function modifier_huskar_berserkers_blood_lod:GetModifierAttackSpeedBonus_Constant ( params )
	return self:GetStackCount() * self.berserkers_blood_attack_speed
end
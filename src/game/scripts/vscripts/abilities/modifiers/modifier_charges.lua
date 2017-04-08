modifier_charges = class({})

if IsServer() then
    function modifier_charges:Update()
        if self:GetDuration() == -1 then
			local octarine = 1
			if self:GetParent():HasModifier("modifier_item_octarine_core") or self:GetParent():HasModifier("modifier_item_octarine_core_consumable") then
				octarine = 0.75
			end
            self:SetDuration(self.kv.replenish_time*octarine, true)
            self:StartIntervalThink(self.kv.replenish_time*octarine)
        end
		
		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_charges:OnCreated(kv)
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end

    function modifier_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
        }

        return funcs
    end

    function modifier_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local octarine = 1
		if self:GetParent():HasModifier("modifier_item_octarine_core") or self:GetParent():HasModifier("modifier_item_octarine_core_consumable") then
			octarine = 0.75
		end

        if stacks < self.kv.max_count then
            self:SetDuration(self.kv.replenish_time*octarine, true)
            self:IncrementStackCount()

            if stacks == self.kv.max_count - 1 then
                self:SetDuration(-1, true)
                self:StartIntervalThink(-1)
            end
        end
    end
end

function modifier_charges:DestroyOnExpire()
    return false
end

function modifier_charges:IsPurgable()
    return false
end

function modifier_charges:RemoveOnDeath()
    return false
end
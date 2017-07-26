
if spell_lab_symbiotic_bonus == nil then
	spell_lab_symbiotic_bonus = class({})
end

function spell_lab_symbiotic_bonus:OnCreated( kv )
	if IsServer() then
		if kv.stacks ~= nil then
		    self:SetStackCount(kv.stacks)
  	else
  		self:SetStackCount(1)
  	end
	end
end

function spell_lab_symbiotic_bonus:OnRefresh( kv )
	if IsServer() then
		if kv.stacks ~= nil then
  		local stacks = self:GetStackCount() + kv.stacks
  		self:SetStackCount(stacks)
    end
	end
end

function spell_lab_symbiotic_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

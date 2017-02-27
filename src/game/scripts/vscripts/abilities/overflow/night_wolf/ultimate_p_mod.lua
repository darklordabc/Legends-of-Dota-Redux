if night_wolf_p_mod == nil then
	night_wolf_p_mod = class({})
end

function night_wolf_p_mod:IsHidden()
	return true
end

function night_wolf_p_mod:OnCreated()
	if IsServer() then
		self:StartIntervalThink( 1 )
	end
end

function night_wolf_p_mod:OnIntervalThink()
	if IsServer() then
		if self:GetAbility():GetLevel() < 1 then return end
		if self:GetParent():IsIllusion() then return end
		if not GameRules:IsDaytime() then
			if not self:GetParent():HasModifier("night_wolf_mod") then
				print("added night wolf")
				self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "night_wolf_mod",{} )
			end
		else
			if self:GetParent():HasModifier("night_wolf_mod") then
				print("removed night wolf")
				self:GetCaster():RemoveModifierByName("night_wolf_mod")
			end
		end
	end
end

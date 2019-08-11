if spell_lab_one_with_nothing == nil then
	spell_lab_one_with_nothing = class({})
end
if spell_lab_one_with_nothing_modifier == nil then
	spell_lab_one_with_nothing_modifier = class({})
end

LinkLuaModifier("spell_lab_one_with_nothing_modifier", "abilities/spell_lab/own/ability.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_one_with_nothing:GetIntrinsicModifierName() return "spell_lab_one_with_nothing_modifier" end
function spell_lab_one_with_nothing_modifier:IsPermanent() return true end
function spell_lab_one_with_nothing_modifier:IsHidden() return true end
function spell_lab_one_with_nothing_modifier:OnCreated(kv)
		if IsServer() then
			self:StartIntervalThink(0.03)
		end
end
function spell_lab_one_with_nothing_modifier:OnIntervalThink()
	if IsServer() then
		if (self:GetAbility():IsCooldownReady()) then
			self:SetStackCount(self:GetCaster():GetMana())
		end
	end
end


function spell_lab_one_with_nothing:GetManaCost(level)
	if self:GetCaster().FindModifierByName ~= nil then
		local hMod = self:GetCaster():FindModifierByName("spell_lab_one_with_nothing_modifier")
		if hMod ~= nil then
			iCount = hMod:GetStackCount()
			return iCount
		end
	end
	return 0
end

function spell_lab_one_with_nothing:OnSpellStart()
	local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/one_with_nothing.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0,self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl( nFXIndex, 3,self:GetCaster():GetAbsOrigin())
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "n_creep_SatyrTrickster.Cast", self:GetCaster())
--  self:GetCaster():SpendMana(self:GetCaster():GetMana(),self)
end

function spell_lab_one_with_nothing:GetAbilityTextureName ()
	return "custom/spell_lab_one_with_nothing"
end

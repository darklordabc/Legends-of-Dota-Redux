if spell_lab_one_with_nothing == nil then
	spell_lab_one_with_nothing = class({})
end

function spell_lab_one_with_nothing:OnSpellStart()
	local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/one_with_nothing.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0,self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl( nFXIndex, 3,self:GetCaster():GetAbsOrigin())
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "n_creep_SatyrTrickster.Cast", self:GetCaster())
  self:GetCaster():SpendMana(self:GetCaster():GetMana(),self)
end

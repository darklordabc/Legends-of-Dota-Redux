alchemist_transmuted_scepter = class({})
LinkLuaModifier("modifier_alchemist_transmuted_scepter", "abilities/alchemist_transmuted_scepter", LUA_MODIFIER_MOTION_NONE)


function alchemist_transmuted_scepter:OnSpellStart()
   local caster = self:GetCaster()
   local ability = self
   local target = self:GetCursorTarget()   
   local sound_cast = "Hero_Alchemist.Scepter.Cast"
   local particle_midas = "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf"

   -- Play cast sound
   EmitSoundOn(sound_cast, caster)

   -- Apply effect   
   local particle_midas_fx = ParticleManager:CreateParticle(particle_midas, PATTACH_ABSORIGIN_FOLLOW, caster) 
  ParticleManager:SetParticleControlEnt(particle_midas_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)

   ParticleManager:ReleaseParticleIndex(particle_midas_fx)

   target:AddNewModifier(caster, ability, "modifier_alchemist_transmuted_scepter", {})
 end 


-- scepter modifier
modifier_alchemist_transmuted_scepter = class({})

function modifier_alchemist_transmuted_scepter:IsDebuff()
  return false  
end

function modifier_alchemist_transmuted_scepter:IsHidden()
  return false
end

function modifier_alchemist_transmuted_scepter:IsPurgable()
  return false
end

function modifier_alchemist_transmuted_scepter:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_alchemist_transmuted_scepter:RemoveOnDeath()
  return false  
end

function modifier_alchemist_transmuted_scepter:DeclareFunctions()  
    local decFuncs = {MODIFIER_PROPERTY_IS_SCEPTER}
    
    return decFuncs  
end

function modifier_alchemist_transmuted_scepter:GetModifierScepter()
  return 1
end
alchemist_transmuted_scepter = class({})
LinkLuaModifier("modifier_alchemist_transmuted_scepter", "abilities/alchemist_transmuted_scepter", LUA_MODIFIER_MOTION_NONE)


function alchemist_transmuted_scepter:OnSpellStart()
   local caster = self:GetCaster()
   local ability = self
   local target = self:GetCursorTarget()   

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

function modifier_alchemist_transmuted_scepter:DeclareFunctions()  
    local decFuncs = {MODIFIER_PROPERTY_IS_SCEPTER}
    
    return decFuncs  
end

function modifier_alchemist_transmuted_scepter:GetModifierScepter()
  return 1
end
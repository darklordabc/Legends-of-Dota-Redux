basic_gpm_bonus=class({})
modifier_basic_gpm_bonus = class({})
LinkLuaModifier("modifier_basic_gpm_bonus","abilities/basic_gold_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_gpm_bonus:OnUpgrade()
 self:GetCaster():RemoveModifierByName("modifier_basic_gpm_bonus")
 self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_basic_gpm_bonus",{})
end

function modifier_basic_gpm_bonus:IsPermanent() return true end
function modifier_basic_gpm_bonus:IsHidden() return true end

function modifier_basic_gpm_bonus:OnCreated() 
  if IsServer() then
    self:StartIntervalThink(60/self:GetAbility():GetSpecialValueFor("gold_bonus"))
  end
end

function modifier_basic_gpm_bonus:OnIntervalThink()
  self:GetCaster():ModifyGold(1,true,DOTA_ModifyGold_GameTick)
end


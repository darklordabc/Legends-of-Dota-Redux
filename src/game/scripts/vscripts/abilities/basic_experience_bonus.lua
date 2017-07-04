basic_xpm_bonus=class({})
basic_xpm_bonus_op=class({})
modifier_basic_xpm_bonus = class({})
modifier_basic_xpm_bonus_op = class({})
LinkLuaModifier("modifier_basic_xpm_bonus","abilities/basic_experience_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_xpm_bonus_op","abilities/basic_experience_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_xpm_bonus:OnUpgrade()
 self:GetCaster():RemoveModifierByName("modifier_basic_xpm_bonus")
 self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_basic_xpm_bonus",{})
end

function basic_xpm_bonus_op:OnUpgrade()
 self:GetCaster():RemoveModifierByName("modifier_basic_xpm_bonus_op")
 self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_basic_xpm_bonus_op",{})
end

function modifier_basic_xpm_bonus:IsPermanent() return true end
function modifier_basic_xpm_bonus:IsHidden() return true end

function modifier_basic_xpm_bonus:OnCreated() 
  if IsServer() then
    self:StartIntervalThink(60/self:GetAbility():GetSpecialValueFor("experience_bonus"))
  end
end

function modifier_basic_xpm_bonus:OnIntervalThink()
  self:GetCaster():AddExperience(1,DOTA_ModifyXP_Unspecified,false,true)
end

function modifier_basic_xpm_bonus_op:IsPermanent() return true end
function modifier_basic_xpm_bonus_op:IsHidden() return true end

function modifier_basic_xpm_bonus_op:OnCreated() 
  if IsServer() then
    self:StartIntervalThink(60/self:GetAbility():GetSpecialValueFor("experience_bonus"))
  end
end

function modifier_basic_xpm_bonus_op:OnIntervalThink()
  self:GetCaster():AddExperience(1,DOTA_ModifyXP_Unspecified,false,true)
end



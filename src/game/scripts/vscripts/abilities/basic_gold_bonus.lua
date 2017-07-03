basic_gpm_bonus=class({})
basic_gpm_bonus_op=class({})
modifier_basic_gpm_bonus = class({})
modifier_basic_gpm_bonus_op = class({})
LinkLuaModifier("modifier_basic_gpm_bonus","abilities/basic_gold_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_gpm_bonus_op","abilities/basic_gold_bonus.lua",LUA_MODIFIER_MOTION_NONE)

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

function basic_gpm_bonus_op:OnUpgrade()
 self:GetCaster():RemoveModifierByName("modifier_basic_gpm_bonus_op")
 self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_basic_gpm_bonus_op",{})
end

function modifier_basic_gpm_bonus_op:IsPermanent() return true end
function modifier_basic_gpm_bonus_op:IsHidden() return true end

function modifier_basic_gpm_bonus_op:OnCreated() 
  if IsServer() then
    self:StartIntervalThink(60/self:GetAbility():GetSpecialValueFor("gold_bonus"))
  end
end

function modifier_basic_gpm_bonus_op:OnIntervalThink()
  self:GetCaster():ModifyGold(1,true,DOTA_ModifyGold_GameTick)
end


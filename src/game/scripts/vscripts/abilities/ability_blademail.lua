ability_blademail=class({})
ability_blademail_op=class({})
--modifier_basic_health_bonus = class({})
--LinkLuaModifier("modifier_basic_health_bonus","abilities/basic_health_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function ability_blademail:OnSpellStart()
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_item_blade_mail_reflect",{duration = self:GetSpecialValueFor("duration")}) 
end

function ability_blademail_op:OnSpellStart()
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_item_blade_mail_reflect",{duration = self:GetSpecialValueFor("duration")}) 
end


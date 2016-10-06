--------------------------------------------------------------------------------------------------------
--
--		Hero: Weaver
--		Perk: If Weaver has Time Lapse, he will automatically cast it upon taking fatal damage. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_weaver_perk", "abilities/hero_perks/npc_dota_hero_weaver_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_weaver_perk == nil then npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_weaver_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_weaver_perk == nil then modifier_npc_dota_hero_weaver_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:IsHidden()
	if IsClient() then
		if not self.check then
			local netTable = CustomNetTables:GetTableValue( "heroes", self:GetParent():GetName().."_perk" )
			if netTable then
				self.hasValidAbility = netTable.hasValidAbility
			end
			self.check = true
		end
	end
	return (not self.hasValidAbility)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_weaver_perk:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end
if IsServer() then
    function modifier_npc_dota_hero_weaver_perk:OnCreated()
        self.lapse = self:GetParent():FindAbilityByName("weaver_time_lapse")
		self.hasValidAbility = self.lapse
		if self.hasValidAbility then 
			CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { hasValidAbility = self.hasValidAbility } )
		end
    end
    
    function modifier_npc_dota_hero_weaver_perk:OnTakeDamage(params)
        if params.unit == self:GetParent() then
            if params.damage > self:GetParent():GetHealth() and self.lapse and self.lapse:IsCooldownReady() and self.lapse:GetLevel() > 0 then
                if self:GetParent():HasScepter() then
                    self:GetParent():SetCursorCastTarget(self:GetParent())
                    self.lapse:OnSpellStart()
                    self.lapse:StartCooldown(self.lapse:GetTrueCooldown())
                    self:GetParent():SpendMana(self.lapse:GetManaCost(-1),self.lapse)
                else
                    self.lapse:OnSpellStart()
                    self.lapse:StartCooldown(self.lapse:GetTrueCooldown())
                    self:GetParent():SpendMana(self.lapse:GetManaCost(-1),self.lapse)
                end
            end
        end
    end

    function modifier_npc_dota_hero_weaver_perk:GetMinHealth(params)
        if self.lapse and self.lapse:GetLevel() > 0 and self.lapse:IsCooldownReady() then
            return 1
        else
            return 0
        end
    end
end

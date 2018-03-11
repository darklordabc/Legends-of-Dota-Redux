--------------------------------------------------------------------------------------------------------
--
--      Hero: Elder Titan
--      Perk: Increased movement speed by 3% for every aura Elder Titan is carrying. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_elder_titan_perk", "abilities/hero_perks/npc_dota_hero_elder_titan_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_elder_titan_perk ~= "" then npc_dota_hero_elder_titan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_elder_titan_perk               
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_elder_titan_perk ~= "" then modifier_npc_dota_hero_elder_titan_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:OnCreated(keys)
    if IsServer() then
        self.auras = 0
        self.auraItems = {}
        self:StartIntervalThink(0.5)
    end

    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:OnIntervalThink()
    if IsServer() then
        self.auras = 0
        local caster = self:GetCaster()
        for i = 0, 15 do 
            local ability = caster:GetAbilityByIndex(i)
            if ability and ability:HasAbilityFlag("aura") and ability:GetLevel() > 0 then
                self.auras = self.auras + 1
            end
        end
        self.auraItems = {}
        for i = 0, 5 do 
            local item = caster:GetItemInSlot(i)
            local addItem = true
            if item and item:HasAbilityFlag("aura") then
                for _, v in ipairs(self.auraItems) do 
                    if v == item:GetName() then
                        addItem = false
                        break
                    end
                end

                if addItem then
                    table.insert(self.auraItems, item:GetName())
                end
            end
        end
        self.auras = self.auras + #self.auraItems
        caster:SetModifierStackCount(self:GetName(), self:GetAbility(), self.auras)
    end

    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_elder_titan_perk:GetModifierMoveSpeedBonus_Percentage()
    return self:GetStackCount() * 3
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--
--      Hero: Medusa
--      Perk: Medusa gains +0.5 mana regeneration per active Toggle effect. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_medusa_perk", "abilities/hero_perks/npc_dota_hero_medusa_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_medusa_perk ~= "" then npc_dota_hero_medusa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_medusa_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_medusa_perk ~= "" then modifier_npc_dota_hero_medusa_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:IsPurgable()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:OnCreated(keys)
    self.manaRegenPerToggle = 0.5
    self.toggles = 0
    if IsServer() then
        self.toggleItems = {}
        self:StartIntervalThink(0.2)
    end

    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:OnIntervalThink()
    if IsServer() then
        self.toggles = 0
        local caster = self:GetCaster()
        for i = 0, 15 do 
            local ability = caster:GetAbilityByIndex(i)
            if ability and ability:GetToggleState() and ability:GetLevel() > 0 then
                self.toggles = self.toggles + 1
            end
        end
        self.toggleItems = {}
        for i = 0, 5 do 
            local item = caster:GetItemInSlot(i)
            local addItem = true
            -- All toggle items except Armlet are active by default, but their toggle state is false
            if item and item:IsToggle() and ( (not item:GetToggleState() and item:GetAbilityName() ~= "item_armlet") or (item:GetToggleState() and item:GetAbilityName() == "item_armlet") ) then
                for _, v in ipairs(self.toggleItems) do 
                    if v == item:GetName() then
                        addItem = false
                        break
                    end
                end

                if addItem then
                    table.insert(self.toggleItems, item:GetName())
                end
            end
        end
        self.toggles = self.toggles + #self.toggleItems
        self:SetStackCount(self.toggles)
    end

    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_medusa_perk:GetModifierConstantManaRegen()
    self.toggles = self:GetStackCount()
    return self.toggles * self.manaRegenPerToggle
end
--------------------------------------------------------------------------------------------------------

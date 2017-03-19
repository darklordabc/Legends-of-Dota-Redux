--------------------------------------------------------------------------------------------------------
--
--      Hero: Clockwork
--      Perk: Fires a random flare to any part of the map every 15 seconds. Scales with Rocket Flare.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_rattletrap_perk", "abilities/hero_perks/npc_dota_hero_rattletrap_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_rattletrap_flare_delay", "abilities/hero_perks/npc_dota_hero_rattletrap_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_rattletrap_perk ~= "" then npc_dota_hero_rattletrap_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_rattletrap_perk                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_rattletrap_perk ~= "" then modifier_npc_dota_hero_rattletrap_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsHidden()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:RemoveOnDeath()
    return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()

        self.flare = caster:AddAbility("rattletrap_rocket_flare_perk")
	for i=0,24 do
            local abil = caster:GetAbilityByIndex(i)
            if not abil then
		self.flare:SetAbilityIndex(i)
	    end
     	end	
        self.thinkInterval = 15

        self.flare:SetHidden(true)
        self.flare:UpgradeAbility(false)
        self:StartIntervalThink(self.thinkInterval)
        caster:AddNewModifier(caster, self.flare, "modifier_npc_dota_hero_rattletrap_flare_delay", {Duration = self.thinkInterval})
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_perk:OnIntervalThink(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local flare = self.flare
        local rocketFlare = caster:FindAbilityByName("rattletrap_rocket_flare")

        if rocketFlare then
            flare:SetLevel(rocketFlare:GetLevel() + 1)
        end

        if flare and caster:IsAlive() and caster:IsRealHero() then
            local findFowLocation = false
            while findFowLocation == false do
                local randomX = RandomInt(-7136, 7136)
                local randomY = RandomInt(-7136, 7136)
                local vector = Vector(randomX, randomY, 0)
                caster:SetCursorPosition(vector)
                flare:OnSpellStart()
                caster:AddNewModifier(caster, flare, "modifier_npc_dota_hero_rattletrap_flare_delay", {Duration = self.thinkInterval})
                findFowLocation = true
            end
        end
        return true
    end
end
--------------------------------------------------------------------------------------------------------
--      Modifier: modifier_npc_dota_hero_rattletrap_flare_delay                
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_rattletrap_flare_delay ~= "" then modifier_npc_dota_hero_rattletrap_flare_delay = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rattletrap_flare_delay:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------

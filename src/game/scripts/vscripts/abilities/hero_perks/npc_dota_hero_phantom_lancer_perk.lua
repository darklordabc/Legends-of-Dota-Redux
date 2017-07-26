--------------------------------------------------------------------------------------------------------
--
--		Hero: Phantom Lancer
--		Perk: Phantom Lancer gains Phantum Rush as a free ability.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_phantom_lancer_perk", "abilities/hero_perks/npc_dota_hero_phantom_lancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_phantom_lancer_cooldown", "abilities/hero_perks/npc_dota_hero_phantom_lancer_perk.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------------------------------
if npc_dota_hero_phantom_lancer_perk ~= "" then npc_dota_hero_phantom_lancer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_phantom_lancer_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_phantom_lancer_perk ~= "" then modifier_npc_dota_hero_phantom_lancer_perk = class({}) end

if modifier_npc_dota_hero_phantom_lancer_cooldown ~= "" then modifier_npc_dota_hero_phantom_lancer_cooldown = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_lancer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_phantom_lancer_perk:OnCreated()
	if IsServer() then
		self:PhantomRushCheck(params)
	end
end

function modifier_npc_dota_hero_phantom_lancer_perk:OnIntervalThink()
	if not self.rush:IsCooldownReady() and not self.cd then
		local cd = self.rush:GetCooldownTimeRemaining()
		self:GetParent():AddNewModifier(self:GetParent(), self.rush, "modifier_npc_dota_hero_phantom_lancer_cooldown", {duration = cd})
		self.cd = true
	elseif self.rush:IsCooldownReady() and self.cd then
		self.cd = false
	end
end

function modifier_npc_dota_hero_phantom_lancer_perk:PhantomRushCheck()
	local caster = self:GetCaster()
	local rush = caster:FindAbilityByName("phantom_lancer_phantom_edge") or nil

	if rush then
		self.freeRush = false
		rush:UpgradeAbility(false)
	else 
		self.freeRush = true
		rush = caster:AddAbility("phantom_lancer_phantom_edge")
		--rush:SetStolen(true)
        rush:SetActivated(true)
		--rush:SetLevel(1)
		self.rush = rush
		self:StartIntervalThink(0.1)
	end
end

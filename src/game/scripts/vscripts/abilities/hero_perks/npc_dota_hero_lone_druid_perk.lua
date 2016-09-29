--------------------------------------------------------------------------------------------------------
--
--		Hero: Lone Druid
--		Perk: Damage is redirected to Bear if available
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_lone_druid_perk", "abilities/hero_perks/npc_dota_hero_lone_druid_perk.lua" ,LUA_MODIFIER_MOTION_NONE )


--------------------------------------------------------------------------------------------------------
if npc_dota_hero_lone_druid_perk == nil then npc_dota_hero_lone_druid_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_lone_druid_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lone_druid_perk == nil then modifier_npc_dota_hero_lone_druid_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lone_druid_perk:IsHidden()
	if IsClient() then
		if not self.bear and not self.check then
			local netTable = CustomNetTables:GetTableValue( "heroes", self:GetParent():GetName().."_perk" )
			if netTable then
				self.bear = netTable.bear
			end
			self.check = true
		end
		return (not self.bear)
	end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_lone_druid_perk:OnCreated()
		self.bear = self:GetCaster():FindAbilityByName("lone_druid_spirit_bear")
		if self.bear then 
			CustomNetTables:SetTableValue( "heroes", self:GetParent():GetName().."_perk", { bear = self.bear } )
		end
		self.damageTaken = 0.5
		self.damageRedirect = 1 - self.damageTaken
		self.suicide = {item_bloodstone = true,
						techies_suicide = true}
		self.leash = 1100
	end

	function modifier_npc_dota_hero_lone_druid_perk:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
		return funcs
	end

	function modifier_npc_dota_hero_lone_druid_perk:OnTakeDamage(params)
		if params.unit == self:GetParent() then
			if params.inflictor and self.suicide[params.inflictor:GetName()] then return end
			if self.bear then
				for _,bear in pairs ( Entities:FindAllByName( "npc_dota_lone_druid_bear*")) do
					if bear:GetOwnerEntity() == self:GetParent() and bear:IsAlive() then
						local distance = (bear:GetAbsOrigin() - self:GetParent()):Length2D()
						if distance < self.leash then
							if bear:GetHealth() > params.damage*self.damageRedirect then
								self:GetParent():SetHealth( self:GetParent():GetHealth() + params.damage*self.damageTaken )
								bear:SetHealth( bear:GetHealth() - params.damage*self.damageRedirect )
							else
								self:GetParent():SetHealth( self:GetParent():GetHealth() + bear:GetHealth() - 1 )
								bear:SetHealth(1)
							end
						end
					end
				end
			end
		end
	end
end

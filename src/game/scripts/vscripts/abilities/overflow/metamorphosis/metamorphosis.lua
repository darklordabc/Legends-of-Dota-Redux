if metamorphosis == nil then
	metamorphosis = class({})
end

LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "metamorphosis_mod", "abilities/overflow/metamorphosis/metamorphosis_mod.lua", LUA_MODIFIER_MOTION_NONE )

function metamorphosis:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	if self:GetCaster():HasItemInInventory("item_aegis") then
		behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
	return behav
end

function metamorphosis:OnSpellStart()
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "RoshanDT.Scream", self:GetCaster() )
	local dur = self:GetDuration()
	if self:hasAegis() then dur = -1 end
	self.hModifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "metamorphosis_mod", { duration = dur } )
end

function metamorphosis:OnInventoryContentsChanged()
	if self:hasAegis() and self.hadAegis ~= true then
		self.hadAegis = true
		if self:GetLevel() > 0 then
			if self:GetCaster():HasModifier("metamorphosis_mod") then
				self.hModifier:SetDuration(-1,true)
			else
				self:OnSpellStart()
			end
			self:EndCooldown()
		end
	else
		self.hadAegis = false
		if self.hadAegis and self:GetCaster():HasModifier("metamorphosis_mod") then
			self.hModifier:SetDuration(self:GetDuration(),true)
		end
	end
end

function metamorphosis:OnUpgrade()
	if self:hasAegis() then
		if self:GetLevel() == 1 then
			self:OnSpellStart()
		end
	end
end

function metamorphosis:hasAegis ()
		return self:GetCaster():HasModifier("modifier_item_aegis")
end

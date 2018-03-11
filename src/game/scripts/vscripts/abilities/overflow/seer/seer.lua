if seer == nil then
	seer = class({})
end

LinkLuaModifier( "seer_mod", "abilities/overflow/seer/seer_mod.lua", LUA_MODIFIER_MOTION_NONE )

function seer:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
	return behav
end

function seer:OnSpellStart()
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Dark_Seer.Wall_of_Replica_Start", self:GetCaster() )
	self.herolist = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO , DOTA_UNIT_TARGET_FLAG_NO_INVIS , FIND_ANY_ORDER , false)

		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_dark_seer/dark_seer_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl(self.nFXIndex, 0, self:GetCaster():GetOrigin())
	if self.herolist[1] then
		for k,v in pairs(self.herolist) do
			if v then
				v:AddNewModifier( self:GetCaster(), self, "seer_mod", {} )
			end
		end
	end
		self:StartCooldown(self:GetTrueCooldown(self:GetLevel()))
end

function seer:OnChannelFinish(bInterrupted)
	if self.herolist[1] then
		for k,v in pairs(self.herolist) do
			if v then
				v:RemoveModifierByNameAndCaster("seer_mod", self:GetCaster())
			end
		end
	end
	self.herolist = nil
end

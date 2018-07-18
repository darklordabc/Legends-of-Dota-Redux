makemeleecreeps_lua = class({})
--local timers = require('easytimers')

--------------------------------------------------------------------------------

function makemeleecreeps_lua:OnSpellStart()

    if self:GetCaster():PassivesDisabled() then return end

    -- Illusions can't use this ability
    if not self:GetCaster():IsRealHero() then return end

	if not self:GetCaster():HasAbility('phase_datadriven') then
		local phaseAbility = self:GetCaster():AddAbility('phase_datadriven')
		phaseAbility:UpgradeAbility(true)
	end
		
	if self:GetCaster():GetModelName() ~= "models/props_structures/tower_bad.vmdl" then
		self:GetCaster():SetModel("models/props_structures/tower_bad.vmdl")
		self:GetCaster():SetOriginalModel("models/props_structures/tower_bad.vmdl")
	end

	self.meleecreeps = self.meleecreeps + 1

	local unit = CreateUnitByName("npc_dota_creep_badguys_melee", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
	unit:SetDeathXP( 0 )
	unit:SetControllableByPlayer(self:GetCaster():GetPlayerOwnerID(), true)

	FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)

	unit.Owner = self:GetCaster();
	unit.Ismeleecreep = true;

	Timers:CreateTimer(function()
        unit:MoveToNPC(self:GetCaster())
        return
    end, DoUniqueString('move_creep'), 0.1)

end

function makemeleecreeps_lua:OnUpgrade()
	if not self:GetCaster():IsRealHero() then return end
	if not self.Init then

		self.Init = true

		self.meleecreeps = 0;
		ListenToGameEvent("entity_killed", makemeleecreeps_lua.WatchmeleecreepDeaths, self)

	end

	self:StartSpawner()

end

function makemeleecreeps_lua:OnOwnerSpawned()
	if not self:GetCaster():IsRealHero() then return end
	self:StartSpawner()

end

function makemeleecreeps_lua:StartSpawner()
	if not self:GetCaster():IsRealHero() then return end
	self:SetThink("Makemeleecreeps", self, self:GetCooldownTimeRemaining())

end

function makemeleecreeps_lua:ShouldSpawn()
	if not self:GetCaster():IsRealHero() then return end
	if not self:GetCaster():IsAlive() then return false end

	local maxmeleecreeps = self:GetLevelSpecialValueFor("maxmeleecreeps", (self:GetLevel() - 1))

	return self.meleecreeps <= maxmeleecreeps

end

function makemeleecreeps_lua:Makemeleecreeps()
	if not self:GetCaster():IsRealHero() then return end
	if self:ShouldSpawn() then

		self:CastAbility()

	end

	if self:ShouldSpawn() then return self:GetCooldownTimeRemaining() end

end

function makemeleecreeps_lua:WatchmeleecreepDeaths( event )
	if not self:GetCaster():IsRealHero() then return end
	local ent = EntIndexToHScript(event.entindex_killed)

	if ent.Ismeleecreep and ent.Owner and ent.Owner == self:GetCaster() then

		self.meleecreeps = self.meleecreeps - 1

		if self:ShouldSpawn() then self:StartSpawner() end

	end

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
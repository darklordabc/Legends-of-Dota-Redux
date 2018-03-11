spawnTable = LoadKeyValues('scripts/kv/camps.kv').small

function FindTableLength(inputTable)
	local kvLen = 0
	for k,v in pairs(inputTable) do
		kvLen = kvLen + 1
	end
	return kvLen
end

spawn_small_camp = spawn_small_camp or class({})
spawn_small_camp_op = spawn_small_camp_op or class({})

if IsServer() then
	function spawn_small_camp:OnSpellStart()
		self.campTable = spawnTable[tostring( RandomInt( 1, FindTableLength(spawnTable) ) )]
		EmitSoundOn("channelsound", self:GetCaster())
	end

	function spawn_small_camp:OnChannelFinish( bInterrupted )
		if not bInterrupted then
			for i = 1, self:GetSpecialValueFor("camps_spawned") do
				self:SpawnTable(self.campTable, self:GetSpecialValueFor("spawn_radius"))
				EmitSoundOn("spawnsound", self:GetCaster())
			end
		end
		StopSoundOn("channelsound", self:GetCaster())
	end
	
	function spawn_small_camp:SpawnTable(campTable, radius)
		for creep, amount in pairs(campTable) do
			for i = 1, amount do
				PrecacheUnitByNameAsync( creep, function() 
					local spawnOrigin = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(radius/2,radius))
					local unit = CreateUnitByName( creep , spawnOrigin, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
					unit:SetForwardVector(self:GetCaster():GetForwardVector())
					unit:SetOwner(self:GetCaster())
					unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
					local spawnFX = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport_flash_end.vpcf", PATTACH_ABSORIGIN, unit)
					ParticleManager:SetParticleControl(spawnFX, 1, spawnOrigin)
					ParticleManager:ReleaseParticleIndex(spawnFX)
				end)
			end
		end
	end

	function spawn_small_camp_op:OnSpellStart()
		self.campTable = spawnTable[tostring( RandomInt( 1, FindTableLength(spawnTable) ) )]
		EmitSoundOn("channelsound", self:GetCaster())
	end

	function spawn_small_camp_op:OnChannelFinish( bInterrupted )
		if not bInterrupted then
			for i = 1, self:GetSpecialValueFor("camps_spawned") do
				self:SpawnTable(self.campTable, self:GetSpecialValueFor("spawn_radius"))
				EmitSoundOn("spawnsound", self:GetCaster())
			end
		end
		StopSoundOn("channelsound", self:GetCaster())
	end
	
	function spawn_small_camp_op:SpawnTable(campTable, radius)
		for creep, amount in pairs(campTable) do
			for i = 1, amount do
				PrecacheUnitByNameAsync( creep, function() 
					local spawnOrigin = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(radius/2,radius))
					local unit = CreateUnitByName( creep , spawnOrigin, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
					unit:SetForwardVector(self:GetCaster():GetForwardVector())
					unit:SetOwner(self:GetCaster())
					unit:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
					local spawnFX = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_teleport_flash_end.vpcf", PATTACH_ABSORIGIN, unit)
					ParticleManager:SetParticleControl(spawnFX, 1, spawnOrigin)
					ParticleManager:ReleaseParticleIndex(spawnFX)
				end)
			end
		end
	end
end

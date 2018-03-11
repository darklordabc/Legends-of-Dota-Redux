modifier_light_blade = class ({})

--------------------------------------------------------------------------------

function modifier_light_blade:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_light_blade:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_light_blade:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
function modifier_light_blade:OnCreated( kv )
	self.fade_id = kv.fade_id or GameRules:GetGameTime()
end

function modifier_light_blade:OnDestroy()
	if IsServer() then
		local nDamageType = DAMAGE_TYPE_MAGICAL
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		--local tDamage = {
		--	victim = self:GetParent(),
		--	attacker = hCaster,
		--	damage = hAbility:GetSpecialValueFor( "damage" ),
		--	damage_type = nDamageType,
		--	ability = hAbility
		--}
		local nFireDamage = hAbility:GetSpecialValueFor( "damage" )
		local nScepterBonus = hAbility:GetSpecialValueFor( "bonus_scepter" )
		day = GameRules:IsDaytime()
		if self:GetCaster():HasScepter() and day then nFireDamage = nFireDamage + nScepterBonus end
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "element_fire", {
			stacks = nFireDamage
		})
		local chain_fade = hAbility:GetSpecialValueFor( "chain_fade" )
		local damage_delay = hAbility:GetSpecialValueFor( "damage_delay" )
		
		if self:GetCaster():HasScepter() then
			chain_fade = hAbility:GetSpecialValueFor( "fade_scepter" )
		--	damage_delay = hAbility:GetSpecialValueFor( "scepter_delay" )
		end
		
		if self:GetParent():IsAlive() then
			self:GetParent():AddNewModifier( self:GetCaster(), hAbility, "modifier_light_blade_fade", { duration = chain_fade, fade_id = self.fade_id } )
		end
		local nFlag = hAbility:GetAbilityTargetFlags() or DOTA_UNIT_TARGET_FLAG_NONE
		local nTeam = hAbility:GetAbilityTargetTeam() or DOTA_UNIT_TARGET_TEAM_BOTH
		local nType = hAbility:GetAbilityTargetType() or DOTA_UNIT_TARGET_ALL
		if nTeam == DOTA_UNIT_TARGET_TEAM_CUSTOM then nTeam = DOTA_UNIT_TARGET_TEAM_BOTH end
		if nType == DOTA_UNIT_TARGET_CUSTOM  then nType = DOTA_UNIT_TARGET_ALL  end
		local nRange = hAbility:GetLevelSpecialValueFor("aoe_range", hAbility:GetLevel())
       local tTargets = FindUnitsInRadius(hCaster:GetTeam(),
           self:GetParent():GetOrigin(),
           nil,
           nRange,
           nTeam,
           nType,
           nFlag,
           FIND_ANY_ORDER,
           false
       )
		
		local hTarget = self:GetParent()
		if tTargets and tTargets[2] then
			local n = 1
			for k,v in pairs(tTargets) do
				if v ~= self:GetParent() and not self:HasRightFade(v) then
					hTarget = v
					break
				end
			end
		end
		if hTarget ~= nil and hTarget ~= self:GetParent() then
			--if ( not hTarget:TriggerSpellAbsorb( self ) ) then
				hTarget:AddNewModifier( self:GetCaster(), hAbility, "modifier_light_blade", { duration = damage_delay, fade_id = self.fade_id} )
				EmitSoundOnLocationWithCaster(hTarget:GetOrigin(),  "Hero_Phoenix.FireSpirits.Launch", self:GetCaster()) 
			--end
	
			local nFXIndex = ParticleManager:CreateParticle( "particles/lina_spell_laguna_chain.vpcf", PATTACH_CUSTOMORIGIN, nil );
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin() + Vector( 0, 0, 96 ), true );
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
			local Colour = {255,150,50}
			ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3])) 
		end
		
		
	end
end

function modifier_light_blade:GetAttributes() 
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_light_blade:HasRightFade(hTarget)
	if IsServer() then
		if hTarget:HasModifier("modifier_light_blade_fade") then
			local tFades = hTarget:FindAllModifiersByName("modifier_light_blade_fade")
			if tFades then
				for k, v in pairs(tFades) do
					if v.fade_id == self.fade_id then
					return true
					end
				end
			end
		end
		return false
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

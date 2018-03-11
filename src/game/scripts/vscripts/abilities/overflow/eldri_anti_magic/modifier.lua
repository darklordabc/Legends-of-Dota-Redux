if anti_magic_mod == nil then
	anti_magic_mod = class({})
end


function anti_magic_mod:GetEffectName()
	return "particles/eldri_sentryvpcf.vpcf"
end
 
function anti_magic_mod:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
 
function anti_magic_mod:OnCreated( kv )	
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function anti_magic_mod:OnIntervalThink()
	if IsServer() then
		if not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), 10, false) then
			self:Destroy()
		end
	end
end
 
function anti_magic_mod:OnRefresh( kv )	
	if IsServer() then
	end
end

function anti_magic_mod:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end
 
function anti_magic_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

function anti_magic_mod:OnAbilityStart(kv)
	if IsServer() then
		if kv.ability.IsItem and kv.ability:IsItem() then return end
		if kv.unit and kv.unit:GetTeam() ~= self:GetCaster():GetTeam() then
			if (self:GetParent():GetAbsOrigin() - kv.unit:GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("radius") then
				if not kv.unit:IsMagicImmune() then
					self:SpellZap(kv.unit)
				end
			end
		end
	end
end

function anti_magic_mod:SpellZap(hTarget)
		local absorb = hTarget:TriggerSpellAbsorb( self )
		if not absorb then
			hTarget:Interrupt()
			local damage = self:GetAbility():GetSpecialValueFor( "d_damage" ) 
			local stun_dur = self:GetAbility():GetSpecialValueFor( "stun_duration" ) 
			EmitSoundOnLocationWithCaster( hTarget:GetOrigin(), "Hero_Omniknight.GuardianAngel", self:GetCaster() )
			hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "generic_lua_stun", { duration = stun_dur , stacking = 1 } )
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
			}
			ApplyDamage( damage )
			self:GetCaster():Heal(ApplyDamage( damage ), self:GetAbility() )
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/black_laguna.vpcf", PATTACH_WORLDORIGIN , nil );
		ParticleManager:SetParticleControl(nFXIndex, 0,  self:GetParent():GetAbsOrigin() + Vector( 0, 0, 160 )) 
		ParticleManager:SetParticleControl(nFXIndex, 1,  hTarget:GetAbsOrigin() + Vector( 0, 0, 50 )) 
		local Colour = {150,255,0}
		ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3])) 
		ParticleManager:ReleaseParticleIndex( nFXIndex );
end

function anti_magic_mod:IsHidden()
	return true
end

function anti_magic_mod:IsPurgable() 
	return false
end

function anti_magic_mod:IsPurgeException()
	return false
end

function anti_magic_mod:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function anti_magic_mod:AllowIllusionDuplicate() 
	return false
end

if spell_lab_symbiotic_modifier == nil then
	spell_lab_symbiotic_modifier = class({})
end

function spell_lab_symbiotic_modifier:OnCreated( kv )
	if IsServer() then
    --self.hHost = kv.target:GetParent()
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("update_rate"))
    self.scale = self:GetParent():GetModelScale()
    self:GetParent():SetModelScale(0.001)
	end
	--self.hasScepter = self:GetParent():HasScepter()
end

function spell_lab_symbiotic_modifier:SetHost (hTarget,hMod)
  self.hHost = hTarget
	self.hMod = hMod
	--local pos = self.hHost:GetAbsOrigin()
	--local up = Vector(0,0,300)
--	self:GetParent():SetAbsOrigin(pos+up)
	--self:GetParent():SetParent(self.hHost,"overhead_follow")
end

function spell_lab_symbiotic_modifier:OnDestroy()
	if IsServer() then
	  if self.hMod ~= nil then
	    self.hMod:Destroy()
	  end
    self:GetParent():SetModelScale(self.scale)
		--self:GetParent():SetParent(nil,"symbiotic_attachment")
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Bane.Nightmare.End", self:GetParent() )
	end
end

function spell_lab_symbiotic_modifier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  --  MODIFIER_PROPERTY_MODEL_SCALE,
    MODIFIER_EVENT_ON_SPENT_MANA,
    MODIFIER_EVENT_ON_SET_LOCATION,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function spell_lab_symbiotic_modifier:IsHidden()
	return false
end

function spell_lab_symbiotic_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function spell_lab_symbiotic_modifier:AllowIllusionDuplicate()
	return false
end

function spell_lab_symbiotic_modifier:CheckState()
local state = {
[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
[MODIFIER_STATE_MAGIC_IMMUNE] = true,
[MODIFIER_STATE_INVULNERABLE] = true,
[MODIFIER_STATE_UNSELECTABLE] = true,
[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
[MODIFIER_STATE_NO_HEALTH_BAR] = true,
[MODIFIER_STATE_FROZEN] = true,
[MODIFIER_STATE_DISARMED] = true,
[MODIFIER_STATE_OUT_OF_GAME] = true,
[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
[MODIFIER_STATE_INVISIBLE] = true,
}
if (self.hHost ~= nil) then
	state[MODIFIER_STATE_STUNNED] = self.hHost:IsStunned()
	state[MODIFIER_STATE_SILENCED] = self.hHost:IsSilenced()
	state[MODIFIER_STATE_MUTED] = self.hHost:IsMuted()
	state[MODIFIER_STATE_COMMAND_RESTRICTED] = self.hHost:IsCommandRestricted()
end
	return state
end

function spell_lab_symbiotic_modifier:OnDeath (kv)
	if IsServer() then
	  if kv.unit ~= self:GetParent() then return end
		self:Destroy()
	end
end

function spell_lab_symbiotic_modifier:OnTakeDamage (kv)
	if IsServer() then
		if kv.unit ~= self.hHost then return end
		if self:GetAbility():GetCooldownTimeRemaining() < 3 then
			self:GetAbility():StartCooldown(3)
		end
	end
end
function spell_lab_symbiotic_modifier:OnSetLocation (kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
    --DeepPrintTable(kv)
		local nCasterID = self:GetCaster():GetPlayerOwnerID()
		local nTargetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(nTargetID,nCasterID) then
			if self:GetAbility():IsCooldownReady() then
				self:Terminate(nil)
			end
		else
	    if self.hHost ~= nil and not self.hHost:HasModifier("modifier_life_stealer_infest") then
				ProjectileManager:ProjectileDodge(self.hHost)
	      FindClearSpaceForUnit(self.hHost,self:GetParent():GetOrigin(),true)
	    end
		end
  end
end
function spell_lab_symbiotic_modifier:OnSpentMana (kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
    if self.hHost == nil then return end
		local nCasterID = self:GetCaster():GetPlayerOwnerID()
		local nTargetID = self:GetParent():GetPlayerOwnerID()
		if PlayerResource:IsDisableHelpSetForPlayerID(nTargetID,nCasterID) then
			if self:GetAbility():IsCooldownReady() then
				self:Terminate(nil)
			end
		else
	    local hParent = self:GetParent()
	    
	    -- Tether semi-nerf, prevent players having hearts and giving massive health regen constantly
	    local tether = hParent:FindAbilityByName("wisp_tether")
	    if tether then
	    	tether:StartCooldown(60)
	    end

			--DeepPrintTable(kv)
			local mana = self.hHost:GetMana()
			if self.hHost:GetMana() >= kv.cost then
				self.hHost:SpendMana(kv.cost, kv.ability)
				hParent:SetMana(hParent:GetMaxMana())
			else
				-- Using spells when the host has no mana burns the hosts health, either the cost of the spell or 20% of max health, whichever is higher
				local hpcost = kv.cost - mana
				if hpcost < self.hHost:GetMaxHealth() / 5 then
					hpcost = self.hHost:GetMaxHealth() / 5
				end

				-- If hero is below 25% of health, you cannot use hosts health
				if self.hHost:GetHealth() < self.hHost:GetMaxHealth() / 4 then
					hParent:SetMana(1)
				else
					hParent:SetMana(hParent:GetMaxMana())
					local damage = {
						victim = self.hHost,
						attacker = self:GetParent(),
						damage = hpcost,
						damage_type = DAMAGE_TYPE_PURE,
						ability = kv.ability
					}
						ApplyDamage(damage)
				end

			end
	   -- local mana = (hParent:GetMana() / hParent:GetMaxMana()) * self.hHost:GetMaxMana()
	    --self.hHost:SetMana(mana);
		end
	end
end

function spell_lab_symbiotic_modifier:Terminate (attacker)
  if attacker then
    self:GetParent():Kill(self:GetAbility(),attacker)
  end
  self:Destroy()
end

function spell_lab_symbiotic_modifier:OnAttackLanded (kv)
	if IsServer() then
		if kv.attacker ~= self:GetParent() then return end
    if self.hHost == nil then return end
		self.hMod:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end

function spell_lab_symbiotic_modifier:OnAbilityExecuted (kv)
	if IsServer() then
		if kv.unit ~= self:GetParent() then return end
    if self.hHost == nil then return end
		self.hMod:Show(self:GetAbility():GetSpecialValueFor("vis_duration"))
	end
end


function spell_lab_symbiotic_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsAlive() then self:Terminate(nil) end
    if self.hHost == nil then return end
    local hParent = self:GetParent()
    --local mana = (self.hHost:GetMana() / self.hHost:GetMaxMana()) * hParent:GetMaxMana()
    --hParent:SetMana(mana)
    local pos = self.hHost:GetAbsOrigin()
    local up = Vector(0,0,300)
    hParent:SetAbsOrigin(pos+up)
	end
end

function spell_lab_symbiotic_modifier:GetModifierModelChange() return "models/items/bane/slumbering_terror/slumbering_terror_nightmare_model.vmdl" end
function spell_lab_symbiotic_modifier:GetModifierInvisibilityLevel()
  return 1
end

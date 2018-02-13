pudge_flesh_heap_minion_damage = class({})

LinkLuaModifier("modifier_flesh_heap_minion_damage", "abilities/deathtal/pudge_flesh_heap_minion_damage.lua" ,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flesh_heap_minion_damage_creep", "abilities/deathtal/pudge_flesh_heap_minion_damage.lua" ,LUA_MODIFIER_MOTION_NONE)



function pudge_flesh_heap_minion_damage:GetIntrinsicModifierName()
	return "modifier_flesh_heap_minion_damage"
end


modifier_flesh_heap_minion_damage = class({})


function modifier_flesh_heap_minion_damage:IsHidden()
	if self:GetAbility():GetLevel() == 0 then
		return true
	end
	return false
end


function modifier_flesh_heap_minion_damage:RemoveOnDeath()
	return false
end


function modifier_flesh_heap_minion_damage:IsPurgable()
	return false
end


function modifier_flesh_heap_minion_damage:IsPassive()
	return true
end

function modifier_flesh_heap_minion_damage:GetFleshHeapKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end
 

function modifier_flesh_heap_minion_damage:OnCreated(kv)
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_minion_damage")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.flesh_heap_minion_damage_amount = self:GetAbility():GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	if IsServer() then
		self:SetStackCount(self:GetFleshHeapKills())
	end
end


function modifier_flesh_heap_minion_damage:OnRefresh()
	if not self:GetAbility() then
		self:GetParent():RemoveModifierByName("modifier_flesh_heap_minion_damage")
		self:GetParent():CalculateStatBonus()
		return
	end
	self.flesh_heap_minion_damage_amount = self:GetAbility():GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	if IsServer() then
		self:SetStackCount(self:GetFleshHeapKills())
	end
end


function modifier_flesh_heap_minion_damage:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	MODIFIER_EVENT_ON_ATTACK_START,
	MODIFIER_EVENT_ON_ABILITY_START,
	MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function modifier_flesh_heap_minion_damage:OnDeath(keys)
	if not keys.unit or not keys.attacker then 
		return 
	end

	if not keys.unit:IsRealHero() then
		return 
	end

	if keys.unit:IsTempestDouble() then
		return
	end

	if not IsServer() then 
		return 
	end
	

	local hKiller = keys.attacker:GetPlayerOwner()
	local hVictim = keys.unit

	if self:GetCaster():GetTeamNumber() ~= hVictim:GetTeamNumber() then
		self.fleshHeapRange = self:GetAbility():GetSpecialValueFor("flesh_heap_range")
		local vToCaster = self:GetCaster():GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D() - (self:GetCaster():GetCollisionPadding() + hVictim:GetCollisionPadding())
		if hKiller == self:GetCaster():GetPlayerOwner() or self.fleshHeapRange >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1

			local hBuff = self:GetCaster():FindModifierByName("modifier_flesh_heap_minion_damage")
			if hBuff ~= nil then
				hBuff:SetStackCount(self.nKills)
			else
				self:GetCaster():AddNewModifier(self:GetCaster(), self,	"modifier_flesh_heap_minion_damage", {})
			end

			local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
			ParticleManager:ReleaseParticleIndex(nFXIndex)
		end
	end
end

function modifier_flesh_heap_minion_damage:OnAttackStart(keys)
	if not keys.attacker then
		return
	end

	if not IsServer() then
		return
	end

	if keys.attacker:GetPlayerOwner() == self:GetCaster():GetPlayerOwner() and keys.attacker ~= self:GetParent() then
		keys.attacker:AddNewModifier(self:GetCaster(), self, "modifier_flesh_heap_minion_damage_creep", {})
		self.flesh_heap_minion_damage_amount = self:GetAbility():GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	end
end

function modifier_flesh_heap_minion_damage:OnAbilityStart(keys)
	if not keys.attacker then
		return
	end

	if not IsServer() then 
		return 
	end

	if keys.attacker:GetPlayerOwner() == self:GetCaster():GetPlayerOwner() and keys.attacker ~= self:GetParent() then
		keys.attacker:AddNewModifier(self:GetCaster(), self, "modifier_flesh_heap_minion_damage_creep", {})
		self.flesh_heap_minion_damage_amount = self:GetAbility():GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	end
end

function modifier_flesh_heap_minion_damage:OnTakeDamage(keys)
	if not keys.attacker then
		return
	end

	if not IsServer() then
		return 
	end

	if keys.attacker:GetPlayerOwner() == self:GetCaster():GetPlayerOwner() and keys.attacker ~= self:GetParent() then
		keys.attacker:AddNewModifier(self:GetCaster(), self, "modifier_flesh_heap_minion_damage_creep", {})
		self.flesh_heap_minion_damage_amount = self:GetAbility():GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	end
end

function modifier_flesh_heap_minion_damage:OnTooltip(keys)
	return self.flesh_heap_minion_damage_amount * self:GetStackCount()
end


modifier_flesh_heap_minion_damage_creep = class({})


function modifier_flesh_heap_minion_damage_creep:IsPurgable()
	return false
end


function modifier_flesh_heap_minion_damage_creep:IsPassive()
	return true
end


function modifier_flesh_heap_minion_damage_creep:IsHidden()
	return true
end


function modifier_flesh_heap_minion_damage_creep:DeclareFunctions()
	local funcs = {
	MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_flesh_heap_minion_damage_creep:GetModifierTotalDamageOutgoing_Percentage(keys)
	local attacker = keys.attacker
	local target = keys.target
	local damage = keys.damage
	local owner = attacker:GetOwner()

	if not attacker or not owner then
		return 0
	end

	local flesh_heap = owner:FindModifierByName("modifier_flesh_heap_minion_damage")
	local flesh_heap_minion_damage_amount = flesh_heap.flesh_heap_minion_damage_amount

	if IsServer() and attacker == self:GetParent() and not attacker:IsIllusion() then
		if damage > 100 and flesh_heap:GetAbility():GetLevel() > 0 then
			local displayNumber = flesh_heap:GetStackCount() * flesh_heap_minion_damage_amount * damage * 0.01
			SendOverheadEventMessage(nil,4, attacker, displayNumber, nil)
		end
	return flesh_heap:GetStackCount() * flesh_heap_minion_damage_amount
	end
end

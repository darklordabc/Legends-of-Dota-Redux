BATTLE_THIRST_TIME = 45.0

if spell_lab_survivor_cooldown == nil then
	spell_lab_survivor_cooldown = class({})
end

LinkLuaModifier("spell_lab_survivor_cooldown_modifier", "abilities/spell_lab/survivor/cooldown.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_cooldown:GetIntrinsicModifierName() return "spell_lab_survivor_cooldown_modifier" end


if spell_lab_survivor_cooldown_modifier == nil then
	spell_lab_survivor_cooldown_modifier = class({})
end

function spell_lab_survivor_cooldown_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_cooldown_modifier:GetModifierPercentageCooldownStacking()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end

function spell_lab_survivor_cooldown_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_cooldown_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_cooldown_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_cooldown_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_cooldown_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		if not self:GetParent():IsRealHero() then
  local hOwner = self:GetParent():GetOwner()
  if hOwner ~= nil then
    local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName("spell_lab_survivor_cooldown_modifier")
    if hOriginModifier ~= nil then
      self:SetStackCount(hOriginModifier:GetStackCount())
    end
  end
end
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_cooldown_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsRealHero() then
			self:StartIntervalThink( -1 )
			return
		end
    if not self:GetParent():IsAlive() and not self:GetParent():IsReincarnating() then
  		self.lastdeath = GameRules:GetGameTime()
  		self:SetStackCount(0)
      return
    end
  	if self:GetAbility():GetLevel() > 0 then
      local stacks = (GameRules:GetGameTime() - self.lastdeath)*self:GetAbility():GetSpecialValueFor("bonus")*0.0166667
  		self:SetStackCount(stacks)
  	end

    local parent = self:GetParent()

    local parentTeam = parent:GetTeamNumber()
    local enemyTeam = 3

    if parentTeam == 3 then
      enemyTeam = 2
    end

    parent.counter = parent.counter or 0
    

    if parent.counter > BATTLE_THIRST_TIME then
      self.lastdeath = self.lastdeath + 1
      -- Little alert above players to indicate they are not gaining stacks
      parent.alertTicker = parent.alertTicker or 3
      if parent.alertTicker == 3 then
        SendOverheadEventMessage( parent, OVERHEAD_ALERT_DENY , parent, 1, nil )
        parent.alertTicker = 0
      else
        parent.alertTicker = parent.alertTicker + 1
      end

    end
    
    for _,v in pairs(FindUnitsInRadius( parentTeam, parent:GetAbsOrigin(), nil, 2000.0, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )) do
      local check = (IsValidEntity(v) and v:IsNull() == false and v.GetPlayerOwnerID and not v:IsClone() and not v:HasModifier("modifier_arc_warden_tempest_double") and not string.match(v:GetUnitName(), "ward") and parent:CanEntityBeSeenByMyTeam(v) and v:GetTeamNumber() == tonumber(enemyTeam) and v:CanEntityBeSeenByMyTeam(parent))

      if check then
        parent.counter = 0
        return 1.0
        end
    end

    parent.counter = parent.counter + 1
    return 1.0
	end
end

function spell_lab_survivor_cooldown_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function isInBase(hero)
      local foutain = nil -- Search for fountain, if its not nearby, they do not gain stacks
      local searchRange = 4400 -- 4400 is the range that makes heros have to leave their base (the higher ground) to gain stacks

      if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
          foutain = Entities:FindAllByNameWithin("ent_dota_fountain_good", hero:GetAbsOrigin(), searchRange)
      else
          foutain = Entities:FindAllByNameWithin("ent_dota_fountain_bad", hero:GetAbsOrigin(), searchRange)
      end

      if #foutain > 0 then
          -- GameRules:SendCustomMessage('near fountain!', 0, 0)
          return true
      end
end
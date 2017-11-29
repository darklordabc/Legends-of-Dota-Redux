TIMERS_THINK = 0.01

if Timers == nil then
  print ( '[Timers] creating Timers' )
  Timers = {}
  Timers.__index = Timers
end

function Timers:new( o )
  o = o or {}
  setmetatable( o, Timers )
  return o
end

function Timers:start()
  Timers = self
  self.timers = {}

  local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
  ent:SetThink("Think", self, "timers", TIMERS_THINK)
end

function Timers:Think()
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()

  -- Process timers
  for k,v in pairs(Timers.timers) do
    local bUseGameTime = true
    if v.useGameTime ~= nil and v.useGameTime == false then
      bUseGameTime = false
    end
    local bOldStyle = false
    if v.useOldStyle ~= nil and v.useOldStyle == true then
      bOldStyle = true
    end

    local now = GameRules:GetGameTime()
    if not bUseGameTime then
      now = Time()
    end

    if v.endTime == nil then
      v.endTime = now
    end
    -- Check if the timer has finished
    if now >= v.endTime then
      -- Remove from timers list
      Timers.timers[k] = nil

      -- Run the callback
      local status, nextCall = pcall(v.callback, GameRules:GetGameModeEntity(), v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change its end time

          if bOldStyle then
            v.endTime = v.endTime + nextCall - now
          else
            v.endTime = v.endTime + nextCall
          end

          Timers.timers[k] = v
        end

        -- Update timer data
        --self:UpdateTimerData()
      else
        -- Nope, handle the error
        Timers:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return TIMERS_THINK
end

function Timers:HandleEventError(name, event, err)
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Tell everyone there was an error
  --Say(nil, name .. ' threw an error on event '..event, false)
  --Say(nil, err, false)

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true
  end
end

function Timers:CreateTimer(name, args)
  if type(name) == "function" then
    args = {callback = name}
    name = DoUniqueString("timer")
  elseif type(name) == "table" then
    args = name
    name = DoUniqueString("timer")
  elseif type(name) == "number" then
    args = {endTime = name, callback = args}
    name = DoUniqueString("timer")
  end
  if not args.callback then
    print("Invalid timer created: "..name)
    return
  end


  local now = GameRules:GetGameTime()
  if args.useGameTime ~= nil and args.useGameTime == false then
    now = Time()
  end

  if args.endTime == nil then
    args.endTime = now
  elseif args.useOldStyle == nil or args.useOldStyle == false then
    args.endTime = now + args.endTime
  end

  Timers.timers[name] = args

  return name
end

function Timers:RemoveTimer(name)
  Timers.timers[name] = nil
end

function Timers:RemoveTimers(killAll)
  local timers = {}

  if not killAll then
    for k,v in pairs(Timers.timers) do
      if v.persist then
        timers[k] = v
      end
    end
  end

  Timers.timers = timers
end


if not Timers.timers then Timers:start() end

function SpellEcho(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability:IsCooldownReady() then return end
	local echo = keys.event_ability
	if echo:IsItem() then return end
	if echo:GetChannelTime() > 0 then return end -- ignore channeled abilities because theyre obnoxious
 	local cursor_pos = echo:GetCursorPosition()
	
	local delay = ability:GetLevelSpecialValueFor("delay",ability:GetLevel()-1)
  ability:StartCooldown(ability:GetLevelSpecialValueFor("delay",ability:GetLevel()-1))
  local tempBanList = LoadKeyValues('scripts/kv/bans.kv')
  local no_echo = tempBanList.noSpellEcho
	if echo and caster:IsRealHero() and not no_echo[ echo:GetName() ] then
		local cooldown = ability:GetTrueCooldown()
		Timers:CreateTimer(delay + echo:GetChannelTime(), function()
							if bit.band(echo:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET and keys.target ~= nil then
								caster:SetCursorCastTarget(keys.target)
							elseif bit.band(echo:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT then
								caster:SetCursorPosition(cursor_pos)
							else
								caster:SetCursorTargetingNothing(true)
							end
							local echo_effect = ParticleManager:CreateParticle("particles/rubick_spell_echo.vpcf", PATTACH_ABSORIGIN , caster)
							local fullManacost = echo:GetManaCost(echo:GetLevel() - 1) 
							--print(halfManacost)
							if caster:GetMana() >= fullManacost then 
								ParticleManager:SetParticleControl(echo_effect, 0, caster:GetAbsOrigin())
								ParticleManager:SetParticleControl(echo_effect, 1, Vector(1,0,0))
								caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
	                            echo:OnSpellStart()
								
                -- If its an ultimate, it uses the cooldown of the ultimate             
                local isUltimate = false
                
                if echo:GetAbilityType() == 1 then
                  isUltimate = true
                end

                -- If its the OP version of the ability then disable the extra long cooldown
                if ability:GetName() == "ebf_rubick_arcane_echo_OP" then
                  isUltimate = false
                end

                if isUltimate == false then
                  ability:StartCooldown(cooldown)
                else
                  ability:StartCooldown(echo:GetTrueCooldown())
                end

	            	ParticleManager:ReleaseParticleIndex(echo_effect)
								--print("not enough mana to echo")
								caster:SpendMana(fullManacost, ability)
							end
							
      end, DoUniqueString('ebf_rubick_spell_echo'))
	end
end

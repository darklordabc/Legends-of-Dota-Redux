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
	local delay = ability:GetLevelSpecialValueFor("delay",ability:GetLevel()-1)
	local no_echo = {["shredder_chakram"] = true,
					 ["shredder_chakram_return"] = true,
					 ["shredder_chakram_2"] = true,
					 ["shredder_return_chakram_2"] = true,
					 ["arc_warden_tempest_double"] = true,
					 ["alchemist_unstable_concoction"] = true,
					 ["alchemist_unstable_concoction_throw"] = true,
					 ["vengefulspirit_nether_swap"] = true,
					 ["juggernaut_omni_slash"] = true,
					 ["rubick_telekinesis_land"] = true,
					 ["antimage_blink"] = true,
					 ["queenofpain_blink"] = true,
					 ["phoenix_icarus_dive"] = true,
					 ["phoenix_icarus_dive_stop"] = true,
					 ["phoenix_fire_spirits"] = true,
					 ["phoenix_sun_ray_stop"] = true,
					 ["phoenix_sun_ray"] = true,
					 ["phoenix_sun_ray_toggle_move"] = true,
					 ["phoenix_supernova"] = true,
					 ["phoenix_launch_fire_spirit"] = true
					}
	if echo and caster:IsRealHero() and not no_echo[ echo:GetName() ] then
		local cooldown = ability:GetTrueCooldown()
		Timers:CreateTimer(delay + echo:GetChannelTime(),
                        function()
							if keys.target then
								caster:SetCursorCastTarget(keys.target)
								print("target")
							elseif echo:GetCursorPosition() then
								local position = keys.target_points[1] + Vector(math.random(150), math.random(150), 0)
								if (position - caster:GetAbsOrigin()):Length2D() > echo:GetCastRange() then
									position = caster:GetAbsOrigin() + Vector(math.random(echo:GetCastRange()/2), math.random(echo:GetCastRange()/2), 0)
								end
								print(position, caster:GetAbsOrigin())
								caster:SetCursorPosition(position)
							else
								caster:SetCursorTargetingNothing(true)
								print("nothing")
							end
							local echo_effect = ParticleManager:CreateParticle("particles/rubick_spell_echo.vpcf", PATTACH_ABSORIGIN , caster)
							ParticleManager:SetParticleControl(echo_effect, 0, caster:GetAbsOrigin())
							ParticleManager:SetParticleControl(echo_effect, 1, Vector(1,0,0))
							caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                            echo:OnSpellStart()
							ability:StartCooldown(cooldown)
                        end, DoUniqueString('ebf_rubick_spell_echo'))
	end
end

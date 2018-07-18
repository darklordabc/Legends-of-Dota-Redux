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
  --local timers = {}

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

function Fervor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local standard_cap = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)
	local chance = ability:GetLevelSpecialValueFor("chance_per_stack", ability_level)
	local duration = ability:GetSpecialValueFor("stack_duration")
	if caster:PassivesDisabled() or caster:IsIllusion() then return end
	if not ability.prng then ability.prng = 0 end
	-- Check if we have an old target
	if caster.fervor_target then
		-- Check if that old target is the same as the attacked target
		if caster.fervor_target == target then
			-- Check if the caster has the attack speed modifier
			if caster:HasModifier(modifier) then
				-- Get the current stacks
				local stack_count = caster:GetModifierStackCount(modifier, ability)

				-- Check if the current stacks are lower than the maximum allowed
				if stack_count < max_stacks then
					-- Increase the count if they are
					if not caster.stuntattack then
						ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
						caster:SetModifierStackCount(modifier, ability, stack_count + 1)
						if chance*(stack_count + 1) > math.random(100 - ability.prng) then
							caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
							Timers:CreateTimer(caster:GetAttacksPerSecond() / 2,
							function()
								caster.stuntattack = true
								caster:PerformAttack(target, true, true, true, false, true, false, true)	
							end, DoUniqueString('ebf_troll_warlord_multistrike'))
							ability.prng = 0
						end
					else
						caster.stuntattack = false
						ability.prng = ability.prng + 1
					end
				else
					if not caster.stuntattack then
						ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
						caster:SetModifierStackCount(modifier, ability, stack_count)
						if chance*stack_count > math.random(100 - ability.prng) then
							caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
							Timers:CreateTimer(caster:GetAttacksPerSecond() / 2,
							function()
								caster.stuntattack = true
								caster:PerformAttack(target, true, true, true, false, true, false, true)	
							end, DoUniqueString('ebf_troll_warlord_multistrike'))
							ability.prng = 0
						end
					else
						caster.stuntattack = false
						ability.prng = ability.prng + 1
					end
				end
			else
				-- Apply the attack speed modifier and set the starting stack number
				ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
				caster:SetModifierStackCount(modifier, ability, 1)
				if chance > math.random(100 - ability.prng) and not caster.stuntattack then
					caster.stuntattack = true
					caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, (2*caster:GetAttacksPerSecond()))
					Timers:CreateTimer(0.2,function()
								caster:PerformAttack(target, true, true, true, false, true, false, true)
								ability.prng = 0
							end)
				else
					caster.stuntattack = false
				end
			end
		else
			-- If its not the same target then set it as the new target and remove the modifier
			caster:RemoveModifierByName(modifier)
			caster.fervor_target = target
		end
	else
		caster.fervor_target = target
	end
end

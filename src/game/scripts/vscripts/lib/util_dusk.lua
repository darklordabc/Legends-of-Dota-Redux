print("[UTIL] Loading KV files...")
contributors = LoadKeyValues("scripts/kv/contributors.kv") --[[Returns:table
Creates a ''table'' from the specified keyvalues text file
]]
if contributors then print("[UTIL] Loaded Contributors, with "..#contributors.." keys.") end
hints = LoadKeyValues("scripts/kv/hints.kv") --[[Returns:table
Creates a ''table'' from the specified keyvalues text file
]]
if hints then print("[UTIL] Loaded Hints and Tips, with "..#hints.." keys.") end

learn = LoadKeyValues("scripts/kv/learn.kv")
if learn then print("[UTIL] Loaded Learn, with "..#learn.." keys.") end

hero_ids = LoadKeyValues("scripts/kv/hero_ids.kv")
if hero_ids then print("[UTIL] Loaded Hero IDs, with "..#hero_ids.." keys.") end

skills = LoadKeyValues("scripts/kv/skills.kv")
if skills then print("[UTIL] Loaded Skillbuilds, with "..#skills.." keys.") end

function DebugPrint(...)
  local spew = Convars:GetInt('duskdota_spew') or -1
  if spew == -1 and DUSKDOTA_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('duskdota_spew') or -1
  if spew == -1 and DUSKDOTA_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function GlobalSound(event)
  local sound = event.sound or event
  print("[GlobalSound] Playing global sound "..sound)
  EmitGlobalSound(sound)
end


-- CheckTable(table, expression, returnall, allowpartialmatches)
-- Goes through a table's contents to see if any of its values match the expression given.
-- Returns the first key it finds with the value, and nil if the value does not exist.
-- table: the table
-- expression: the expression to search for
-- returnall: if true, returns a table with all the keys that match the value specified (optional)
-- allowpartialmatches: if true, counts partial matches as valid entries (only works for strings) (optional)
-- NOTE: returnall will return an empty instead of nil if it is used and there are no values

function CheckTable(table, expression, returnall, allowpartialmatches)
  local table = table
  local expression = expression
  local returnall = returnall or false
  local allowpartialmatches = allowpartialmatches or false
  if allowpartialmatches then -- check if the expression is a string
    if not type(expression) == "string" then error("[ERROR - CheckTable] CheckTable requires a string argument to allow partial matches.") return nil end
  end
  if not returnall then
    for k,v in pairs(table) do -- search through the table
      if allowpartialmatches then
        if type(v) == "string" then -- we need to make sure that v is a string
          if string.find(v, expression) then return k end -- found an expression that matches
        end
      else
        if v == expression then return k end -- found an expression that matches
      end
    end
  else
    local returntable = {}
    for k,v in pairs(table) do
      if allowpartialmatches then
        if type(v) == "string" then -- we need to make sure that v is a string
          if string.find(v, expression) then table.insert(returntable,k) end -- found an expression that matches
        end
      else
        if v == expression then
          table.insert(returntable,k)
        end
      end
      return returntable
    end
  end
  return nil -- we didn't find anything, so we return nil
end

-- CheckClass(input handle, class string, is partial)
-- The unit is tested to see if its class matches the string given
-- Can pass a table to it to check against all the available classname values, will return true if at least one match is found
-- When passed "npc_dota_building" it compiles all the possible classnames for building units into one table and checks for those.
function CheckClass(input, class)
  -- building exception:
  if class == "npc_dota_building" then -- since we want to include all buildings, we add the tower class as well
    class = {
      [1] = "npc_dota_building",
      [2] = "npc_dota_tower",
      [3] = "npc_dota_fort",
      [4] = "npc_dota_barracks",
    }
  end
  if type(class) == "table" then
    for k,v in pairs(class) do
      if input:GetClassname() == v then return true end
    end
    return false -- the loop ended without finding anything so we return false 
  end
  print("[CheckClass] Class check for input, class found is: "..input:GetClassname()) -- only prints if not a table of course
  
  if input:GetClassname() == class then return true else return false end
end

-- CheckName(input handle, name string, is partial)
-- The unit is tested to see if its class matches the string given
-- Can pass a table to it to check against all the available classname values, will return true if at least one match is found
-- When passed "npc_dota_building" it compiles all the possible classnames for building units into one table and checks for those.
function CheckName(input, name)
print("[CheckName] Name check for input, name found is: "..input:GetUnitName()) -- only prints if not a table of course
  if type(name) == "table" then
    for k,v in pairs(name) do
      if input:GetUnitName() == v then return true end
    end
    return false -- the loop ended without finding anything so we return false 
  end
  
  if input:GetUnitName() == name then return true else return false end
end


-- -- Initialises and updates our health in the current frame and the previous frame
-- -- Allows us to keep track of damage and reverse it without the glitches caused by Heal()
-- -- Needs to either be called from KV every 0.03s with a ThinkInterval or from LUA without an event
-- function DamageTables(event)
--   local target = nil
--   if event.target ~= nil then
--     target = event.target
--   else -- since event.target is nil, we assume a unit handle has been passed to the function, probably from Lua somewhere
--     target = event
--   end
--   if not target then return end
  
--   target.lasthp = target.lasthp or {} -- if the table exists, we simply leave it alone.  Otherwise, we initialise the variable as an empty table.
  
--   if target.lasthp.old == nil or target.lasthp.new == nil then
--     target.lasthp.old = target:GetMaxHealth()
--     target.lasthp.new = target:GetMaxHealth()
--   end
  
--   target.lasthp.old = target.lasthp.new
--   target.lasthp.new = target:GetHealth()
-- end


-- -- Reverts our health to what it was in the last frame.
-- function NegateDamage(target)
--   local target = target
  
--   if not IsValidEntity(target) then error("[ERROR - NegateDamage] INVALID ENTITY") return end
  
--   print("[NegateDamage] Negated the last frame of damage that occurred on "..target:GetName())
  
--   target:SetHealth(target.lasthp.old)
-- end

-- DealDamage(target or targets,attacker,damageAmount,damageType,damageFlags)
-- Deals damage to the target, with the attacker as source, damageAmount as damage, damageType as type, and damageFlags as flags.
-- passing a table as the target will deal damage to all entities found within the table
-- must be called from Lua
function DealDamage(target,attacker,damageAmount,damageType,damageFlags,ability)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local type = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  -- Damage Flags are:
  -- DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_BLOCK
  -- DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY
  -- DOTA_DAMAGE_FLAG_HPLOSS
  -- DOTA_DAMAGE_FLAG_IGNORS_COMPOSITE_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR
  -- DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
  -- DOTA_DAMAGE_FLAG_NONE
  -- DOTA_DAMAGE_FLAG_NON_LETHAL
  -- DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
  -- DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT
  -- DOTA_DAMAGE_FLAG_REFLECTION
  -- DOTA_DAMAGE_FLAG_USE_COMBAT_PROFICIENCY
  
  if not IsValidEntity(target) and type(target) == "table" then -- assume a table was passed
  print("[DealDamage] Dealing "..dmg.." of type "..type.." from attacker "..attacker:GetName().." to the following targets: ")
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
      print("==[DealDamage] Target "..k..": "..v:GetName())
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = type,
          damage_flags = flags
        })
      end
    end
    return
  end
  
  print("[DealDamage] Dealing "..dmg.." of type "..type.." to "..target:GetName().." from attacker "..attacker:GetName())
  
  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = type,
    damage_flags = flags
  })
end

function DealDamageThroughMagicImmunity(target,attacker,damageAmount,damageType)
  
  DealDamage(target,attacker,damageAmount,damageType,DOTA_DAMAGE_FLAG_BYPASSES_MAGIC_IMMUNITY)
end

function DealDamageThroughInvulnerability(target,attacker,damageAmount,damageType)
  
  DealDamage(target,attacker,damageAmount,damageType,DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY)
end

function DealReflectionDamage(target,attacker,damageAmount,damageType)
  
  DealDamage(target,attacker,damageAmount,damageType,DOTA_DAMAGE_FLAG_REFLECTION)
end

function DealNonLethalDamage(target,attacker,damageAmount,damageType)
  
  DealDamage(target,attacker,damageAmount,damageType,DOTA_DAMAGE_FLAG_NON_LETHAL)
end

function DealStaticDamage(target,attacker,damageAmount,damageType)
  
  DealDamage(target,attacker,damageAmount,damageType,DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS)
end

function FastDummy(target, team, duration, vision)
  duration = duration or 0.03
  vision = vision or  250
  local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
  if dummy ~= nil then
    dummy:SetAbsOrigin(target) -- CreateUnitByName uses only the x and y coordinates so we have to move it with SetAbsOrigin()
    dummy:SetDayTimeVisionRange(vision)
    dummy:SetNightTimeVisionRange(vision)
    dummy:AddNewModifier(dummy, nil, "modifier_phased", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", { duration = 9999})
    dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = duration+0.03})
      Timers:CreateTimer(duration,function()
        if not dummy:IsNull() then
          print("=====================Destroying UNIT=====================")
          dummy:ForceKill(true)
          --dummy:Destroy()
          UTIL_Remove(dummy)
        else
          print("=====================UNIT is already REMOVED=====================")
        end
      end
      )
    
  end
  return dummy
end

function Purge(keys)
    local target = keys.target
    local caster = keys.caster
    local purgeStuns = keys.stuns or true
    if purgeStuns == 0 then purgeStuns = false end

    target:Purge(true,true,false,purgeStuns,false)
end

function PurgeAlly(keys)
    local target = keys.target
    local caster = keys.caster
    local purgeStuns = keys.stuns or true
    if purgeStuns == 0 then purgeStuns = false end

    target:Purge(false,true,false,purgeStuns,false)
end

function PurgeEnemy(keys)
    local target = keys.target
    local caster = keys.caster
    local purgeStuns = keys.stuns or false
    if purgeStuns == 0 then purgeStuns = false end

    target:Purge(true,false,false,purgeStuns,false)
end

function PurgeDynamic(keys)
    local target = keys.target
    local caster = keys.caster
    local purgeStuns = keys.stuns or true
    if purgeStuns == 0 then purgeStuns = false end

    if target:GetTeam() == caster:GetTeam() then
      target:Purge(false,true,false,true,false)
    else
      target:Purge(true,false,false,purgeStuns,false)
    end
end

function ModelSwap( keys )
  local caster = keys.caster
  local model = keys.model
  local projectile_model = keys.projectile_model

  -- Saves the original model and attack capability
  if caster.caster_model == nil then 
    caster.caster_model = caster:GetModelName()
  end
  caster.caster_attack = caster:GetAttackCapability()

  -- Sets the new model and projectile
  caster:SetOriginalModel(model)
  caster:SetRangedProjectileName(projectile_model)
  caster:SetModelScale(0.75)
end

function GetDistance(vector1,vector2)
  local v1 = vector1:Normalized()
  local v2 = vector2:Normalized()

  local x1 = vector1["x"]
  local y1 = vector1["y"]
  local x2 = vector2["x"]
  local y2 = vector2["y"]

  local distance = math.sqrt(((x2-x1)^2)+((y2-y1)^2))

  return distance
end

-- UnitLoc(keys)
-- Print the position and forward vector of a unit.  Good for debugging.
function UnitLoc(keys)
  local caster = keys.caster

  local l = caster:GetAbsOrigin()
  local f = caster:GetForwardVector()

  print("Location is "..l['x']..","..l['y']..","..l['z'])
  print("Forwardvector is "..f['x']..","..f['y']..","..f['z'])

  GameRules:SetTimeOfDay(0.75)
end

function stopSound(keys)
  local caster = keys.caster
  local unit = keys.unit or keys.target
  local sound = keys.sound

  if not unit or not sound or not caster then print("ERROR - Values are nil for stopSound.") return end
  print("Stopping sound "..sound.." on unit "..unit:GetName())
  unit:StopSound(sound)
  
end

function addSoundToIndex(keys)
  local caster = keys.caster
  local unit = keys.unit
  local index = keys.index
  local sound = keys.sound

  if unit.soundIndexes == nil then
    unit.soundIndexes = {}
  end

  unit.soundIndexes[index] = sound
end

function playSoundFromIndex(keys)
  local caster = keys.caster
  local unit = keys.unit
  local index = keys.index

  if unit.soundIndexes == nil then return end

  if unit.soundIndexes[index] == nil then return end

  unit:EmitSound(unit.soundIndexes[index]) --[[Returns:void
   
  ]]
end

function playerIsContributor(playerID)
  return checkContributor(playerID) > 0
end

function checkContributor(playerID)
  local steamID = PlayerResource:GetSteamAccountID(playerID) --[[Returns:<>
  No Description Set
  ]]
  local conData = contributors[tostring(steamID)]

  local merit = 0

  if conData then
      if conData.merit then
        merit = merit + conData.merit
      end
  end

  return merit
end

function emitSoundForAllPlayers(soundString)
  local sound = soundString

  local playerCount = PlayerResource:GetPlayerCount()

  for i=0, playerCount, 1 do
    local player = PlayerResource:GetPlayer(i)
    if player then
      if not player:IsFakeClient() then
        EmitSoundOnClient(sound, player) --[[Returns:void
        Play named sound only on the client for the passed in player
        ]]
      end
    end
  end
end

function showHint(entity,hintNumber)
  local entity = entity
  local hintsList = hints
  if not hintsList then print("[KV ERROR] Hints KV was not found.") return end
  local max = hintsList["last_index"]
  print("Table size is "..max)
  local r = RandomInt(0, max) --[[Returns:int
  Get a random ''int'' within a range
  ]]
  local n = 0
  while tostring(entity.showingHint) == tostring(r) and n < 10 do r = RandomInt(0,max) n = n+1 end
  if hintNumber ~= nil then r = hintNumber end

  print("Random number is "..r)
  local hint = hintsList[tostring(r)]

  if hint then
    print("Found hint at "..r..", '"..hint.."'.")
  else
    print("Hint could not be extracted from the hints KV file.")
    hint = "Error"
  end

  if entity then
    print("Setting hint.")
    entity:SetCustomHealthLabel(hint,RandomInt(75,205),RandomInt(75,205),RandomInt(75,205))
    entity.showingHint = r
  end
end

function hasHint(entity)
  local entity = entity
  if entity then
    if entity.showingHint ~= nil then
      if entity.showingHint >= 0 or type(entity.showingHint) == "string"  then
        return true
      end
    end
  end
  return false
end

function hideHint(entity)
  local entity = entity

  if entity then
    entity:SetCustomHealthLabel("",255,255,255)
    entity.showingHint = -1
  end
end

function onHelperIsAttacked(keys)
  local attacker = keys.attacker
  print("ATTACKED!!!")

  if attacker:GetTeam() == keys.caster:GetTeam() and not attacked then
    showHint(keys.caster,"sadface")
    keys.caster.attacked = true
    attacker:Stop()
    if keys.caster.attacked_number then
      keys.caster.attacked_number = keys.caster.attacked_number+1
    else
      keys.caster.attacked_number = 1
    end

    for i=0,50,1 do
      if i < 49 then
        Timers:CreateTimer(i*0.02,function()
          keys.caster:SetModelScale((50-i)*0.02)
        end)
      else
        Timers:CreateTimer(i*0.02,function()
          keys.caster:AddNoDraw()
          keys.caster:SetModelScale(1)
        end)
      end

    end

  end

end

function changeModelSizeOverTime(entity,time,iterations,targetSize)
  for i=iterations,0,-1 do

  end
end

function resetLabel(entity)
  local unit = entity
  if entity.target ~= nil then -- the function was called from KV
    unit = entity.target
  end
  unit:SetCustomHealthLabel("",255,255,255)
end

if not Orders then
  Orders = class({})
end

function Orders:IssueAttackOrder(unit,target)
  if unit and target then
    local order = 
    {
      UnitIndex = unit:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
      TargetIndex = target:entindex()
    }

    ExecuteOrderFromTable(order)
  end
end

-- Attaches a prop to the unit, adding it to a list of props to attach.
-- This allows quick equipping and unequipping of attachments.
-- If the prop entry already exists, it's overridden anyway.
function attachPropToUnit(unit,attach_point_string,vmdl_string,scale,attachment_name)

    local attachment = Attachments:AttachProp(unit, attach_point_string, vmdl_string, scale)

    if not unit.hero_attachments then
      unit.hero_attachments = {

      }
    end

    unit.hero_attachments[attachment_name] = {
      ["attachment"] = attachment,
      ["attach_point"] = attach_point_string,
      ["vmdl"] = vmdl_string,
      ["scale"] = scale
    }
end

function KVRefreshProps(keys)
  local unit = keys.target

  refreshPropsOnUnit(unit)
end

function KVEnableProps(keys)
  local unit = keys.target or keys.unit

  enablePropsOnUnit(unit)
end

-- Use "all" to remove all props
function removePropFromUnit(unit,attachment_name)

  if unit.hero_attachments then
    if attachment_name == "all" then
      for k,v in pairs(unit.hero_attachments) do
        v["attachment"]:RemoveSelf()
        unit.hero_attachments[k] = nil
      end
      return true
    end
    
    for k,v in pairs(unit.hero_attachments) do
      if k == attachment_name then
        v["attachment"]:RemoveSelf()
        unit.hero_attachments[k] = nil
        break
      end
      return true
    end
  end
  return false
end

-- Disables all props on the unit, but doesn't remove the unit's prop table entries.
-- They can be re-enabled with enablePropsOnUnit().
function disablePropsOnUnit(unit)
  if unit.hero_attachments then
    for k,v in pairs(unit.hero_attachments) do
      if v["attachment"] then
        v["attachment"]:RemoveSelf()
      else
        return false
      end
    end
    return true
  end
  return false
end

function enablePropsOnUnit(unit)
  if unit.hero_attachments then
    for k,v in pairs(unit.hero_attachments) do
      local a = v["attachment"]
      local ap = v["attach_point"]
      local vmdl = v["vmdl"]
      local s = v["scale"]
      attachPropToUnit(unit,ap,vmdl,s,k)
    end
    return true
  end
  return false
end

-- Detaches and reattaches all props in the unit's hero_attachments table
-- If the table does not exist, returns false.
function refreshPropsOnUnit(unit)
  if unit.hero_attachments then
    for k,v in pairs(unit.hero_attachments) do
      local a = v["attachment"]
      local ap = v["attach_point"]
      local vmdl = v["vmdl"]
      local s = v["scale"]
      removePropFromUnit(unit,k)
      attachPropToUnit(unit,ap,vmdl,s,k)
    end
    return true
  end
  return false
end

function populateHeroIDS()
  for k,v in pairs(hero_ids) do
    local id = v["id"]
    CustomNetTables:SetTableValue("hero_ids",k,{value=id})
    print("Set "..k.." to ID "..id)
  end
end

function populateLearnValues_deprecated()
  local learn = learn
  if not learn then print("Table not loaded from KV.") return end
  print("Learn: populating values into the net tables")
  print("this is done once at the start of the game.")

  for k,v in pairs(learn) do
    local overview = v["lanes"]["general"]["overview"]

    local hero_long = v["hero_long"] -- used to identify the Hero in JS

    local hero_name = v["hero_name"]

    local hero_id = v["hero_id"]

    local midlane = v["lanes"]["midlane"]["overview"]
    local midlane_r = v["lanes"]["midlane"]["rating"]

    local offlane = v["lanes"]["offlane"]["overview"]
    local offlane_r = v["lanes"]["offlane"]["rating"]

    local safelane = v["lanes"]["safelane"]["overview"]
    local safelane_r = v["lanes"]["safelane"]["rating"]

    local jungle = v["lanes"]["jungle"]["overview"]
    local jungle_r = v["lanes"]["jungle"]["rating"]

    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_name",{value=hero_name})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_id",{value=hero_id})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_overview",{value=overview})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_midlane",{value=midlane})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_offlane",{value=offlane})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_safelane",{value=safelane})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_jungle",{value=jungle})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_midlane_r",{value=midlane_r})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_offlane_r",{value=offlane_r})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_safelane_r",{value=safelane_r})
    CustomNetTables:SetTableValue("learn_heroes",hero_long.."_jungle_r",{value=jungle_r})
  end
end

function populateLearnValues()
  local n = 0
  local hero_support = {}
  for k,v in pairs(learn) do
    CustomNetTables:SetTableValue("learn_heroes",k,v) -- sets the net table value to a table filled with details of the hero
    extraprint = v["hero_name"]
    prefix = "[LEARN] [X] "
    if v["hero_name"] ~= "None" then
      extraprint = string.upper(v["hero_name"])
      n = n+1
      table.insert(hero_support,extraprint)
      prefix = "[LEARN] [SUPPORTED] "
    end
    print(prefix.."Set Learn net table at "..k..", "..extraprint)

  end
  print("[LEARN] "..n.." heroes are supported.")
  print("[LEARN] Here are the names of supported Heroes:")
  for k,v in pairs(hero_support) do
    print(v)
  end

end

function populateSkillValues()
  populateValues(skills,"skillbuild_heroes")
end

function populateValues(table,nettable)
  local n = 0
  for k,v in pairs(table) do
    n = n+1
    CustomNetTables:SetTableValue(nettable,k,v)
    print("[POPULATE] Populated table key "..k.." into NetTable: "..nettable)
  end
  print("[POPULATE] Populated "..n.." keys into the table "..nettable)
end

function ApplyModTargeted(keys)
  local caster = keys.caster
  local target = keys.target
  local mod = keys.modifier
  local duration = keys.duration

  keys.ability:ApplyDataDrivenModifier(caster, target, mod, {Duration=duration}) --[[Returns:void
  No Description Set
  ]]
end

function tgt(target) -- triggers Lotus and Linken's on the target, returns true if linkens was popped (as Lotus doesn't need a return state)
  target:TriggerSpellReflect(target)
  if target:TriggerSpellAbsorb(target) then print("Spell blocked.") return true end
  print("Spell not blocked.")
  return false
end

function StopUnit(keys)
  local caster = keys.caster
  local target = keys.target or nil

  if not target then caster:Stop() else target:Stop() end
end

function StopCaster(keys)
  keys.caster:Stop()
end

function FindEnemies(caster,point,radius)
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_CLOSEST,
                            false)
end
function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol, forplayer)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = nil
    if forplayer ~= nil and IsValidEntity(forplayer) then
      print("===========POPUP CREATED FOR PLAYER")
      pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target, forplayer) -- target:GetOwner()
    else
      pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
    end

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function PopupGoldGain(target, amount)
    PopupNumbers(target, "gold", Vector(255, 200, 33), 1.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

function alchemist_alchemise_transmute_target(keys)
  if keys.target:GetName() == "npc_dota_roshan" then EndCooldown() return end
  keys.caster:ModifyGold(keys.gold, true, 0)  --Give the player a flat amount of reliable gold.
  
  --Start the particle and sound.
  keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
  local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)  
  ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)
  
  local player = PlayerResource:GetPlayer(keys.caster:GetPlayerID())
  
  PopupGoldGain(keys.target,keys.gold,player)

  --Remove default gold/XP on the creep before killing it so the caster does not receive anything more.
  if not keys.target:IsRealHero() then 
    keys.target:SetMinimumGoldBounty(0)
    keys.target:SetMaximumGoldBounty(0)
    keys.target:Kill(keys.ability, keys.caster) --Kill the creep.  This increments the caster's last hit counter.
  else
    keys.caster:EmitSound("DOTA_Item.Hand_Of_Midas")
    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)  
    ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)
    return
  end
end

function alchemist_grant_to_hero(event)
  local caster = event.caster
  local target = event.target
  
  local percent = event.pt / 100
  
  caster:EmitSound("DOTA_Item.Hand_Of_Midas")
  local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)  
  ParticleManager:SetParticleControlEnt(midas_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
  
  if caster == target then
    local gold = caster:GetGold()
    local stacks = gold/200
    caster:SpendGold(500+gold*0.04,0)
    event.ability:ApplyDataDrivenModifier(caster,caster,"alchemist_gold_armor_mod",{})
    caster:SetModifierStackCount("alchemist_gold_armor_mod",event.ability,stacks)
    return
  end
  
  caster:SpendGold(caster:GetGold()*percent,0)
  target:ModifyGold(caster:GetGold()*percent,true,0)
end

function alchemist_alchemise_tick_gold(keys)
  keys.target:ModifyGold(keys.gold, false, 0)
  print("Adding "..keys.gold.." gold to modifier owner")
end

function alchemist_multiply_gold_tgt(keys)
  local target = keys.unit
  local attacker = keys.attacker or nil
  local mult = (keys.gold-100)/100
  local caster = keys.attacker or nil
  local player = PlayerResource:GetPlayer(caster:GetPlayerID())
  
  local gold = math.floor(target:GetGoldBounty()*mult)
  
--  target:SetMaximumGoldBounty(gold+(gold*0.1))
--  target:SetMinimumGoldBounty(gold-(gold*0.1))
  print("============================== GAINING "..gold.." BONUS GOLD")
  attacker:ModifyGold(gold,true,0)
  target:EmitSound("DOTA_Item.Hand_Of_Midas")
  local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)  
  ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), false)
  if gold <= 0 then return end
  -- Message Particle, has a bunch of options
  -- Similar format to the popup library by soldiercrabs: http://www.reddit.com/r/Dota2Modding/comments/2fh49i/floating_damage_numbers_and_damage_block_gold/
  local symbol = 0 -- "+" presymbol
  local color = Vector(255, 200, 33) -- Gold
  local lifetime = 2
  local digits = string.len(gold) + 1
  local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
  local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
  ParticleManager:SetParticleControl(particle, 1, Vector(symbol, gold, symbol))
  ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
  ParticleManager:SetParticleControl(particle, 3, color)
end

function alchemist_increase_bounty_tgt(keys)
  local target = keys.target
  local mult = keys.gold/100
  
  target.bounty_table = {}
  
  table.insert(target.bounty_table,target:GetGoldBounty())
  
  local gold = target:GetGoldBounty()*mult
  
  target:SetMaximumGoldBounty(gold+(gold*0.1))
  target:SetMinimumGoldBounty(gold-(gold*0.1))
end

function alchemist_reset_bounty_tgt(keys)
  local target = keys.target
  
  local bt = target.bounty_table[1]
  
  target:SetMaximumGoldBounty(bt)
  target:SetMinimumGoldBounty(bt)
end

function alchemist_bottle_throw_start(keys)
  local caster = keys.caster
  local target = keys.target
  
  for i=0,5 do
    local item = caster:GetItemInSlot(i)
    
    if item ~= nil then
      keys.ability:ApplyDataDrivenModifier(caster,caster,"alchemist_bt_"..item:GetName(),{})
      if caster:HasModifier("alchemist_bt_"..item:GetName()) then
        if item:GetCurrentCharges() > 1 then
          item:SetCurrentCharges(item:GetCurrentCharges()-1)
        else
          caster:RemoveItem(item)
        end
        break
      end -- We found an item with a corresponding modifier, so we end the loop, and the projectile fires
    end
  end
  
    local info = 
    {
    Target = target,
    Source = caster,
    Ability = keys.ability,  
    EffectName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_projectile.vpcf",
    vSpawnOrigin = target:GetAbsOrigin(),
    fDistance = 2000,
    fStartRadius = 64,
    fEndRadius = 64,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime() + 10.0,
    bDeleteOnHit = true,
    iMoveSpeed = 600,
    bProvidesVision = true,
    iVisionRadius = 300,
    iVisionTeamNumber = caster:GetTeamNumber(),
    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    }
  
  local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function alchemist_bottle_throw_boom(keys)
  local caster = keys.caster
  local target = keys.target
  
  local modifier_list = {
    [1] = "item_tango",
    [2] = "item_clarity",
    [3] = "item_flask",
    [4] = "item_smoke_of_deceit",
    [5] = "item_dust"
  }
  
  for i =1,5 do
    if caster:HasModifier("alchemist_bt_"..modifier_list[i]) then
      print("=========== Caster has modifier alchemist_bt_"..modifier_list[i])
      keys.ability:ApplyDataDrivenModifier(caster,target,"alchemist_bt_effect_"..modifier_list[i],{})
      caster:RemoveModifierByName("alchemist_bt_"..modifier_list[i])
      break
    elseif
      caster:HasModifier("alchemist_bt_"..modifier_list[i].."_enhanced") then
      print("=========== Caster has modifier alchemist_bt_"..modifier_list[i].."_enhanced")
      keys.ability:ApplyDataDrivenModifier(caster,target,"alchemist_bt_effect_"..modifier_list[i].."_enhanced",{})
      caster:RemoveModifierByName("alchemist_bt_"..modifier_list[i].."_enhanced")
      break
    end
  end
end

function alchemist_enhance(keys)
  local caster = keys.caster
  for i=0,5 do
    local item = caster:GetItemInSlot(i)
    
    if item ~= nil then
      keys.ability:ApplyDataDrivenModifier(caster,caster,"alchemist_enhance_"..item:GetName(),{})
      print("APPLYING MODIFIER alchemist_enhance_"..item:GetName())
      if caster:HasModifier("alchemist_enhance_"..item:GetName()) then
        print("CASTER HAS CORRECT MODIFIER")
        if not caster:HasAnyAvailableInventorySpace() then keys.ability:EndCooldown() keys.ability:RefundManaCost() return end
        local name = item:GetName()
        if item:GetCurrentCharges() > 1 then
          item:SetCurrentCharges(item:GetCurrentCharges()-1)
        else
          caster:RemoveItem(item)
        end
        local int = RandomInt(1,100)
        print("Trying to add item: "..name.."_enhanced, with integer "..int)
        local entity = nil
        if int > 10 then entity = CreateItem(name.."_enhanced",caster,caster) else
          entity = CreateItem("item_cake",caster,caster)
        end
        
        local newitem = caster:AddItem(entity)
        break
      end
    end
  end
end

function alchemist_bottle_throw_mana_burn(keys)
  local caster = keys.caster
  local target = keys.target
  local mana_burn = keys.mana_burn
  local s = keys.sp or 0
  
  if s == 1 then
    mana_burn = mana_burn*3
  end
  
  target:ReduceMana(mana_burn)
  
  local damage_table = {
    victim = target,
    attacker = caster,
    damage = mana_burn*0.5,
    damage_type = DAMAGE_TYPE_MAGICAL,
    } 
    ApplyDamage(damage_table)
end
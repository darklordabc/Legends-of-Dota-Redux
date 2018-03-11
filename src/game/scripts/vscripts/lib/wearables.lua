if Wearables == nil then
    _G.Wearables = class({})
end

Wearables.DEFAULT_WEARABLES = LoadKeyValues('scripts/kv/wearables.kv')

-- Credits: 
-- @DoctorGester
-- @TideSofDarK

function Wearables:AttachWearable(unit, modelPath)
    local wearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelPath, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})

    wearable:FollowEntity(unit, true)

    unit.wearables = unit.wearables or {}
    table.insert(unit.wearables, wearable)

    return wearable
end

function Wearables:Remove(unit)
    if not unit.wearables or #unit.wearables == 0 then
        return
    end

    for _, part in pairs(unit.wearables) do
        if not part:IsNull() then
            part:RemoveSelf()
        end
    end

    unit.wearables = {}
end

function Wearables:HideDefaultWearables( event )
  local hero = event.caster
  local ability = event.ability

  hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function Wearables:ShowDefaultWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function Wearables:AttachWearableList( unit, list )
    if not list then return end
    for k,v in pairs(list) do
        Wearables:AttachWearable(unit, v)
        print("go!!")
    end
end

function Wearables:HasDefaultWearables( unit )
    return Wearables:GetDefaultWearablesList( unit ) ~= nil
end

function Wearables:GetDefaultWearablesList( unit )
    local t = Wearables.DEFAULT_WEARABLES[unit]
    if t and t["attach"] then
        return t["attach"]
    end
    return nil
end
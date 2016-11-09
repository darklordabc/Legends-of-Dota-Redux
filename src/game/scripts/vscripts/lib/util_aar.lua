local Timers = require('easytimers')

AAR_SMALL_ARENA = {[1] = Vector(1561.12, -5262.92, 295.968), [2] = Vector(1555.84, -4122.01, 257), [3] = Vector(4348.23, -4122.07, 257), [4] = Vector(4358.79, -5207.59, 282.345)}
AAR_BIG_ARENA = {[1] = Vector(-235.689, -6139.83, 262.252), [2] = Vector(-226.721, -3866.71, 291.518), [3] = Vector(5519, -3839.78, 257), [4] = Vector(5526.66, -6118.56, 271.501)}

function initDuel(hero)
	hero:SetAbsOrigin(getMidPoint( AAR_BIG_ARENA ))

	Timers:CreateTimer(function()
    	if not isPointInsidePolygon(hero:GetAbsOrigin(), AAR_BIG_ARENA) then
    		FindClearSpaceForUnit(hero,getMidPoint( AAR_BIG_ARENA ),true)
    	end
        return 1.0
    end, 'duel_timer', 1.0)

    spawnEntitiesAlongPath( "models/props_rock/badside_rocks002.vmdl", AAR_BIG_ARENA )
end

function spawnEntitiesAlongPath( model, path )
	local j = #path
	for i = 1, #path do
		local offset = 128

		local direction = (path[i] - path[j]):Normalized()
		local distance = (path[j] - path[i]):Length2D()

		for x=0,distance,128 do
			local obstacle = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
			obstacle:SetAbsOrigin(GetGroundPosition(path[j] + (direction * x),obstacle))
			obstacle:SetModelScale(4.0)
		end

	    j = i
	end
end

function isPointInsidePolygon(point, polygon)
	local oddNodes = false
	local j = #polygon
	for i = 1, #polygon do
	    if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
	        if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
	            oddNodes = not oddNodes
	        end
	    end
	    j = i
	end
	return oddNodes
end

function getMidPoint( points )
	local midPoint = Vector(0,0,0)
    for i=1,#points do
    	midPoint = midPoint + points[i]
    end
    midPoint = midPoint / #points
    return midPoint
end
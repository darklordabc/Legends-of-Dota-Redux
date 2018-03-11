function OnTriggerStartTouch(trigger)
	if trigger.activator then
		-- PanoramaShop.UnitsInShop[trigger.activator] = true
	end
end

function OnTriggerEndTouch(trigger)
	if trigger.activator then
		-- PanoramaShop.UnitsInShop[trigger.activator] = nil
	end
end

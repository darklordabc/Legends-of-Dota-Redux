function OnTriggerStartTouch(trigger)
	if trigger.activator then
		print('Start:', trigger.activator:GetUnitName())
		PanoramaShop.UnitsInShop[trigger.activator] = true
	end
end

function OnTriggerEndTouch(trigger)
	if trigger.activator then
		print('End:', trigger.activator:GetUnitName())
		PanoramaShop.UnitsInShop[trigger.activator] = nil
	end
end

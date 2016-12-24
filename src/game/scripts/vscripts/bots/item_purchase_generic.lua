require( GetScriptDirectory().."/item_manipulation_generic" )

function ItemPurchaseThink()
	
end

function BootsProtocol()

--	print("BootsProtocol called");

	if ( IsItemOnBot( "item_recipe_travel_boots" ) ) then
--		print("BootsProtocol travels on bot, buying");
		return true;--travels recipe already on bot, good to go
	elseif ( IsItemInBackorStash( "item_recipe_travel_boots" ) )  then
		--travels recipe in backpack/stash
		if not ( HasSpareSlot() ) then
			if ( IsItemOnBot("item_tpscroll") ) then
--				print("BootsProtocol selling tp");
				SellItemByName("item_tpscroll");
				return false; --wait until tp is sold and slot free
			else
--				print("BootsProtocol selling boots");
				SellOldBoots();
				return false; --wait until old boots are sold and slot free
			end
		elseif ( CanSell() ) then
--			print("BootsProtocol spare slot, buying boots");
			return true;
		else
--			print("BootsProtocol waiting");
			--await travels getting into inv
			return false;
		end
	elseif ( CourierValue() > 1999 ) then
--		print("BootsProtocol on courier");
		--likely has travels on courier, await acquiring them
		return false;
	elseif not ( HasSpareSlot() ) then
--		print("BootsProtocol clearspace");
		--attempt to make room
		ClearSpaceAttempt();
		return false;
	else
--		print("BootsProtocol buying regular boots");
		--no travels, space in inv, get some boots
		return true;
	end

--	print("Boots protocol special circumstances");
--	ListInv();
	
	return false;
end


function DoStuff()
	
	if ( CurrentHP() < 121 ) then
		UseItemByName( "item_faerie_fire" );
	end
	
	if ( CurrentMP() < 121 ) then
		UseItemByName( "item_enchanted_mango" );
	end
--[[
	if ( MissingHP() >= 400 and GameTime() < 700 ) then
		GiveHP();
	end
	
	if ( MissingMP() >= 200 and GameTime() < 700 ) then
		GiveMana();
	end
--]]	
	if ( ( CanSell() and GameTime() > 750 ) and not HasSpareSlot() ) then
		ItemRotation();
	end

	C9Prevention();

end

function TravelsDone()

--	print("TravelsDone called");

	if ( IsItemOnBot( "item_recipe_travel_boots") or IsItemOnBot( "item_travel_boots" ) or IsItemOnBot( "item_travel_boots_2" ) ) then 
		if not ( HasSpareSlot() ) then
			if ( IsItemOnBot("item_tpscroll") ) then
--				print("TravelsDone tp sale");
				SellItemByName("item_tpscroll");
				return false; --wait until tp is sold and slot free
			else
--				print("TravelsDone boots sale");
				SellOldBoots();
				return false; --wait until old boots are sold and slot free
			end
		else
--			print("TravelsDone returning true");
			--travels on bot, spare slot, good to go
			return true;
		end
	elseif ( IsItemInBack( "item_travel_boots" ) or IsItemInBack( "item_travel_boots_2" ) )  then
		--travels in backpack! ( fix to this is coming soon(tm) )
--		print("TravelsDone goofed");
		ListInv();
		return false;
	elseif ( IsItemInStash( "item_travel_boots" ) or IsItemInStash( "item_travel_boots_2" ) ) then
		--travels in stash, check for a spare slot and await getting them onto bot
		if not ( HasSpareSlot() ) then
			if ( IsItemOnBot("item_tpscroll") ) then
--				print("TravelsDone tp sale bots in stash");
				SellItemByName("item_tpscroll");
				return false; --wait until tp is sold and slot free
			else
--				print("TravelsDone boots sale travels in stash");
				SellOldBoots();
				return false; --wait until old boots are sold and slot free
			end
		else
--			print("TravelsDone awaiting bots");
			--do nothing, await bot aquiring travels
			return false;
		end
	else
--		print("TravelsDone awaiting bots");
		return false;--do nothing, await bot aquiring travels
	end

--	print("TravelsDone special circumstances");
--	ListInv();
	
	return false;

end
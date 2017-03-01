

function C9Prevention()
	--thanks nostrademous !
	
--	print("C9Prevention called");
	local npcBot = GetBot();
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == "item_tpscroll" or sCurItem:GetName() == "item_recipe_travel_boots" or sCurItem:GetName() == "item_travel_boots" or sCurItem:GetName() == "item_travel_boots_2" ) then
--				print("C9Prevention tp / travels found");
				return; --we are done, no need to check further
			end
			if ( ( i == 6 or i == 7 or i == 8 ) and ( sCurItem:GetName() == "item_tpscroll" and CanSell() ) ) then
--				print("C9Prevention tp in backpack");			
				npcBot:Action_SellItem( sCurItem );
				return; --attempt to buy tp on next loop
			end
			if ( i > 5 and ( sCurItem:GetName() == "item_tpscroll" and npcBot:DistanceFromSideShop() == 0 ) ) then
--				bot in side shop with tp in back/stash, likely wants to buy one to join a fight
--				pity this doesn't work, bots will only sell items that are on them, not stuff in stash
--				print("C9Prevention at side shop no tp in slots");
				npcBot:Action_SellItem( sCurItem );
				return; --attempt to buy tp on next loop
			end
		end
	end
	
	if ( npcBot:GetCourierValue() >= GetItemCost( "item_tpscroll" ) ) then
--		print("C9Prevention on cour");
		return; --likely on courier, we are done, no need to check further
	end
	
	if ( npcBot:GetGold() >= GetItemCost( "item_tpscroll" ) ) then
		if ( npcBot:DistanceFromFountain() == 0 and GameTime() > 60 ) then
--			Bot died or retreated in lane
			if ( HasSpareSlot() ) then
				npcBot:Action_PurchaseItem( "item_tpscroll" );
				return;
			else
				ClearSpaceAttempt();
				return;
			end
		end
		if ( GameTime() < 600 ) then
			return; --bit early for tp's
		end
		if not ( HasSpareSlot() ) then
--			print("C9Prevention no space, attempting to make room and buy on next loop");
			ClearSpaceAttempt();
			return;
		else
			npcBot:Action_PurchaseItem( "item_tpscroll" );
		end
	end
	
	
end


function CanSell()
	
--	print("CanSell called");
	local npcBot = GetBot();
	
	if ( npcBot:DistanceFromFountain() == 0 or npcBot:DistanceFromSideShop() == 0 or npcBot:DistanceFromSecretShop() == 0 ) then return true;
	end

	return false;
	
end


function ClearSpaceAttempt()
	
--	print("ClearSpaceAttempt called");
--	make sure to check inv is full before calling this!

	local npcBot = GetBot();
	local slotNum = 11;
	local hp = npcBot:GetMaxHealth() - npcBot:GetHealth();
	local mp = npcBot:GetMaxMana() - npcBot:GetMana();
	
	if ( CanSell() ) then
		ItemRotation();
		return;
	else
		if ( hp > 60 and hp < 350 ) then
--			print("ClearSpaceAttempt using faerie");
			UseItemByName( "item_faerie_fire" );
			return;
		elseif ( hp > 350 ) then
--			print("ClearSpaceAttempt using flask");
			UseItemByName ( "item_flask" );
			return;
		elseif ( mp > 140 ) then
--			print("ClearSpaceAttempt using mango");
			UseItemByName( "item_enchanted_mango" );
			return;
		else
			for i=0,5 do
				local sCurItem = npcBot:GetItemInSlot( i );
				if ( sCurItem:GetName() == "item_faerie_fire" ) then
					npcBot:Action_UseAbility( sCurItem );
					return;
				elseif ( sCurItem:GetName() == "item_flask" ) then
					slotNum = i;
				elseif ( sCurItem:GetName() == "item_enchanted_mango" and slotNum > 10 ) then
					slotNum = i;
				end
			end
			if ( slotNum < 10 ) then
				local iDump = npcBot:GetItemInSlot( slotNum );
				npcBot:Action_UseAbility( iDump );
				npcBot:Action_UseAbilityOnEntity( iDump , npcBot );
			else
				--no space can be made
			end
		end
	end
	
end


function ConsumablePurge()

--	print("ConsumablePurge called");

	SellItemByName( "item_tango" );
	SellItemByName( "item_tango_single" );
	SellItemByName( "item_flask" );
	SellItemByName( "item_clarity" );
	SellItemByName( "item_faerie_fire" );
	SellItemByName( "item_enchanted_mango" );
	SellItemByName( "item_flying_courier" ); -- because sometimes 2 get bought

end


function CourierValue()

--	print("CourierValue called");
	local npcBot = GetBot();
	
	return ( npcBot:GetCourierValue() );

end


function CurrentHP()

--	print("CurrentHP called");
	local npcBot = GetBot();
	
	return ( npcBot:GetHealth() );

end


function CurrentMP()

--	print("CurrentMP called");
	local npcBot = GetBot();
	
	return ( npcBot:GetMana() );

end


function DitchItem( item )
--	don't know why bots refuse to drop items

	print("DitchItem called");
	local npcBot = GetBot();
	local drop = npcBot:GetLocation();
	drop[1] = RandomFloat( (drop[1]-50) , (drop[1]+50) );
	drop[2] = RandomFloat( (drop[2]-50) , (drop[2]+50) );
	print(drop[1]);
	print(drop[2]);
	
	if ( item ~= nil and not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) ) then
		print("DitchItem dropping item");
		print(item:GetName());
		npcBot:Action_DropItem( item , drop );
	end
	
end


function DitchItemByName( itemName )
--	don't know why bots refuse to drop items

	print("DitchItemByName called");
	local npcBot = GetBot();
	local drop = npcBot:GetLocation();
	drop[1] = RandomFloat( (drop[1]-10) , (drop[1]+10) );
	drop[2] = RandomFloat( (drop[2]-10) , (drop[2]+10) );
	print(drop[1]);
	print(drop[2]);
	
	if not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) then
		for i=0,5 do
			local sCurItem = npcBot:GetItemInSlot( i );
			if ( sCurItem ~= nil ) then
				if ( sCurItem:GetName() == itemName ) then
					print("DitchItemByName dropping item");
					print(sCurItem:GetName());
					npcBot:Action_DropItem( sCurItem , drop );
				end
			end
		end
	end
	
end


function DoFullPurge()

	print("DoFullPurge called");

	DitchItemByName("item_tango");
	DitchItemByName("item_tango_single");
	SellorUseItemByName("item_flask");
	SellorUseItemByName("item_clarity");
	SellorUseItemByName("item_faerie_fire");
	SellorUseItemByName("item_enchanted_mango");
	DitchItemByName("item_quelling_blade");
	DitchItemByName("item_iron_talon");
	DitchItemByName("item_stout_shield");
	DitchItemByName("item_poor_mans_shield");
	DitchItemByName("item_orb_of_venom");
	DitchItemByName("item_infused_raindrop");
	DitchItemByName("item_magic_stick");
	DitchItemByName("item_magic_wand");
	DitchItemByName("item_bottle");
	
end


function DropYourStick()

	print("DropYourStick DropYourStick DropYourStick DropYourStick");
	
	DitchItemByName("item_magic_stick");
	DitchItemByName("item_magic_wand");

end


function EarlyItemPurge()

	print("EarlyItemPurge called");

	DitchItemByName("item_quelling_blade");
	DitchItemByName("item_iron_talon");
	DitchItemByName("item_stout_shield");
	DitchItemByName("item_poor_mans_shield");
	DitchItemByName("item_orb_of_venom");
	DitchItemByName("item_infused_raindrop");

end


function GetItemByName( itemName )

--	print("GetItemByName called");
	local npcBot = GetBot();
	
	for i=0,5 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then
--				print("GetItemByName found match");
				return sCurItem;
			end
		end
	end
	
	return nil;
	
end


function GiveHP()

--	print("GiveHP called");
	local npcBot = GetBot();
	
	if ( npcBot:GetCourierValue() >= GetItemCost( "item_flask" ) ) then	return; --likely on courier
	elseif not ( HasTwoSpareSlots() ) then return; -- no room
	end
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == "item_flask" ) then return; --we already have one
			end
		end
	end

	if ( npcBot:GetGold() >= GetItemCost( "item_flask" ) ) then
--		print("GiveHP buying flask");
		npcBot:Action_PurchaseItem( "item_flask" );
	end

end


function GiveMana()

--	print("GiveMana called");
	local npcBot = GetBot();
	
	if ( npcBot:GetCourierValue() >= GetItemCost( "item_clarity" ) ) then return; --likely on courier
	elseif not ( HasTwoSpareSlots() ) then return; -- no room
	end
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == "item_clarity" or sCurItem:GetName() == "item_enchanted_mango" ) then return; --we already have mana items
			end
		end
	end

	if ( npcBot:GetGold() >= GetItemCost( "item_clarity" ) ) then
--		print("GiveMana buying clarity");
		npcBot:Action_PurchaseItem( "item_clarity" );
	end

end


function HasSpareSlot()

--	print("HasSpareSlot called");
	local npcBot = GetBot();
	
	for i=0,5 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem == nil ) then return true;
		end
	end
	
	return false;
	
end


function HasTwoSpareSlots()

--	print("HasTwoSpareSlots called");
	local npcBot = GetBot();
	local slots = 0;
	
	for i=0,5 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem == nil ) then
			slots = slots + 1;
		end
	end
	
	if ( slots > 1 ) then return true;
	end
	
	return false;
	
end


function IsInFountain()

--	print("IsInFountain called");
	local npcBot = GetBot();
	
	if ( npcBot:DistanceFromFountain() == 0 ) then return true;
	else return false;
	end
	
	return false;
	
end


function IsItemInBack( itemName )

--	print("IsItemInBack called");
	local npcBot = GetBot();
	
	for i=6,8 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then 
			if ( sCurItem:GetName() == itemName ) then return true;
			end
		end
	end
	
	return false;

end


function IsItemInBackorStash( itemName )

--	print("IsItemInBackorStash called");
	local npcBot = GetBot();
	
	for i=6,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then return true;
			end
		end
	end
	
	return false;

end


function IsItemInInv( itemName )

--	print("IsItemInInv called");
	local npcBot = GetBot();
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then return true;
			end
		end
	end
	
	return false;

end


function IsItemInStash( itemName )

--	print("IsItemInStash called");
	local npcBot = GetBot();
	
	for i=9,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then return true;
			end
		end
	end

	return false;

end


function IsItemOnBot( itemName )

--	print("IsItemOnBot called");
	local npcBot = GetBot();
	
	for i=0,5 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then return true;
			end
		end
	end
	
	return false;

end


function ItemRotation()

--	print("ItemRotation called");
--	makes sure to check inv is full before calling this!
	local npcBot = GetBot();
	local slotNum = 11;
	
	for i=0,8 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == "item_clarity" ) then
				npcBot:Action_SellItem( sCurItem );
				return;
			end
			if ( sCurItem:GetName() == "item_flying_courier" ) then
				npcBot:Action_SellItem( sCurItem );
				return;
			end
			if ( ( i == 6 or i == 7 or i == 8 ) and ( sCurItem:GetName() == "item_tpscroll" or sCurItem:GetName() == "item_clarity" or sCurItem:GetName() == "item_flask" ) ) then
--				print("ItemRotation tp/consumable in backpack");			
				npcBot:Action_SellItem( sCurItem );
				return;
			end
			if ( sCurItem:GetName() == "item_tango" ) then
				slotNum = i;
			elseif ( sCurItem:GetName() == "item_faerie_fire" ) then
				if ( slotNum > 10 ) then
					slotNum = i;
				else
					local item = npcBot:GetItemInSlot( slotNum );
					if ( item:GetName() == "item_tango" ) then
						--rather sell the tango
					else
						slotNum = i;
					end
				end
			elseif ( sCurItem:GetName() == "item_flask" ) then
				if ( slotNum > 10 ) then
					slotNum = i;
				else
					local item = npcBot:GetItemInSlot( slotNum );
					if ( item:GetName() == "item_tango" or item:GetName() == "item_faerie_fire" ) then
						--rather sell the tango or faerie
					else
						slotNum = i;
					end
				end
			elseif ( sCurItem:GetName() == "item_enchanted_mango" ) then
				if ( slotNum > 10 ) then
					slotNum = i;
				else
					local item = npcBot:GetItemInSlot( slotNum );
					if ( item:GetName() == "item_tango" or item:GetName() == "item_faerie_fire" or item:GetName() == "item_flask" ) then
						--rather sell the tango / faerie / flask
					else
						slotNum = i;
					end
				end
			elseif ( sCurItem:GetName() == "item_stout_shield" or sCurItem:GetName() == "item_poor_mans_shield" ) then
				if ( slotNum > 10 ) then
					slotNum = i;
				else
					--rather sell anything else first
				end
			end
		end
	end
	
	if ( slotNum < 10 ) then
		local item = npcBot:GetItemInSlot( slotNum );
		npcBot:Action_SellItem( item );
	else
		--no items in inv to be rotated out
--		ListInv();
	end
	
	
end


function ListInv()

	print("Listing Inventory:");
	local npcBot = GetBot();
	print(npcBot:GetUnitName());
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			print(sCurItem:GetName());
		else
			print("no item");
		end
	end
	
end


function MissingHP()

--	print("MissingHP called");
	local npcBot = GetBot();

	return ( npcBot:GetMaxHealth() - npcBot:GetHealth() );
	
end


function MissingMP()

--	print("MissingMP called");
	local npcBot = GetBot();
	
	return ( npcBot:GetMaxMana() - npcBot:GetMana() );
	
end


function SellItem( item )

--	print("SellItem called");
	local npcBot = GetBot();
	
	if ( item ~= nil ) then
--		print("SellItem selling");
--		print(item:GetName());
		npcBot:Action_SellItem( item );
	end
	
end


function SellItemByName( itemName )
	
--	print("SellItemByName called");
	local npcBot = GetBot();
	
	for i=0,14 do
		local sCurItem = npcBot:GetItemInSlot( i );
		if ( sCurItem ~= nil ) then
			if ( sCurItem:GetName() == itemName ) then
--				print("SellItemByName selling");
--				print(sCurItem:GetName());
				npcBot:Action_SellItem( sCurItem );
			end
		end
	end

end


function SellOrUseItem( item )

--	print("SellOrUseItem called");
	local npcBot = GetBot();
	
	if ( item ~= nil and not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) ) then
--		print("SellOrUseItem sell/use item");
--		print(item:GetName());
		npcBot:Action_SellItem( item );
		npcBot:Action_UseAbility( item );
		npcBot:Action_UseAbilityOnEntity( item , npcBot );
	end

end


function SellOrUseItemByName( itemName )

--	print("SellOrUseItemByName called");
	local npcBot = GetBot();
	
	if not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) then
		for i=0,5 do
			local sCurItem = npcBot:GetItemInSlot( i );
			if ( sCurItem ~= nil ) then
				if ( sCurItem:GetName() == itemName ) then
--					print("SellOrUseItemByName selling or using item");
--					print(sCurItem:GetName());
					npcBot:Action_SellItem( sCurItem );
					npcBot:Action_UseAbility( sCurItem );
					npcBot:Action_UseAbilityOnEntity( sCurItem , npcBot );
				end
			end
		end
	end

end


function SellOldBoots()

--	print("OldBootsPurge called");

	SellItemByName("item_tranquil_boots");
	SellItemByName("item_power_treads");
	SellItemByName("item_phase_boots");
	
end


function UseItem( item )

--	print("UseItem called");
	local npcBot = GetBot();
	
	if ( item ~= nil and not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) ) then
--		print("UseItem using item");
--		print(item:GetName());
		npcBot:Action_UseAbility( item );
		npcBot:Action_UseAbilityOnEntity( item , npcBot );
	end
	
end


function UseItemByName( itemName )

--	print("UseItemName called");
	local npcBot = GetBot();
	
	if not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) then
		for i=0,5 do
			local sCurItem = npcBot:GetItemInSlot( i );
			if ( sCurItem ~= nil ) then
				if ( sCurItem:GetName() == itemName ) then
--					print("UseItemName using item");
--					print(sCurItem:GetName());
					npcBot:Action_UseAbility( sCurItem );
					npcBot:Action_UseAbilityOnEntity( sCurItem , npcBot );
				end
			end
		end
	end
	
end


function UseTango()
--	this technically works, but no function to find trees yet

	print("UseTango called");
	local npcBot = GetBot();
	local tongo = GetItemByName("item_tango");
	local tree = RandomInt( 0, 300 );
	print(tree);
	
	if ( tongo ~= nil and not ( npcBot:IsUsingAbility() or npcBot:IsChanneling() ) ) then
		print("UseTango good to go");
		npcBot:Action_UseAbilityOnTree( tongo , tree );
	end
	
end

"use strict";
function UpdateTalentTree( msg )
{
  var DotaHud = $.GetContextPanel().GetParent().GetParent().GetParent();
  var hud = DotaHud.FindChild("Hud");
  var hudelements = hud.FindChild("HUDElements");
  var lower_hud = hudelements.FindChild("lower_hud");
  var center_with_stats =lower_hud.FindChild("center_with_stats");
  var center_block = center_with_stats.FindChild("center_block");
  var StatBranch = center_block.FindChild("StatBranch");
  var StatBranchGraphics = StatBranch.FindChild("StatBranchGraphics");
  var StatBranchChannel = StatBranchGraphics.FindChild("StatBranchChannel");
  var StatPipContainer = StatBranchChannel.FindChild("StatPipContainer");

  // Remove all the talent visualisations first
  var StatRow = StatPipContainer.FindChild("StatRow10");
  var right = StatRow.GetChild(1)
  var left = StatRow.GetChild(0)  
  right.style.opacity= "0"
  left.style.opacity= "0"
  var StatRow = StatPipContainer.FindChild("StatRow15");
  var right = StatRow.GetChild(1)
  var left = StatRow.GetChild(0)  
  right.style.opacity= "0"
  left.style.opacity= "0"
  var StatRow = StatPipContainer.FindChild("StatRow20");
  var right = StatRow.GetChild(1)
  var left = StatRow.GetChild(0)  
  right.style.opacity= "0"
  left.style.opacity= "0"
  var StatRow = StatPipContainer.FindChild("StatRow25");
  var right = StatRow.GetChild(1)
  var left = StatRow.GetChild(0)  
  right.style.opacity= "0"
  left.style.opacity= "0"
  
  var selectedUnit = Players.GetQueryUnit(Players.GetLocalPlayer());
  var selectedUnit = selectedUnit
  if (selectedUnit == -1) { 
    selectedUnit = Players.GetSelectedEntities(Players.GetLocalPlayer())
    selectedUnit=  selectedUnit[0]
  }
  if (selectedUnit) {
    var stringSelectedUnit = selectedUnit.toString()
   
    if (Entities.IsConsideredHero( selectedUnit )) {
        var talentTable = CustomNetTables.GetTableValue("heroes",stringSelectedUnit)
        //$.Msg(talentTable)
        if (talentTable ) { 
        var talentOne = talentTable["talentOne"] +1
        var talentTwo = talentTable["talentTwo"] +1 
        var talentThree = talentTable["talentThree"] +1
        var talentFour = talentTable["talentFour"] +1
        if (talentOne) {
          var StatRow = StatPipContainer.FindChild("StatRow10");
          var side = StatRow.GetChild(talentOne-1)
          side.style.opacity = "1"
        }
        if (talentTwo) {
          var StatRow = StatPipContainer.FindChild("StatRow15");
          var side = StatRow.GetChild(talentTwo-1)
          side.style.opacity = "1"
        }
        if (talentThree) {
          var StatRow = StatPipContainer.FindChild("StatRow20");
          var side = StatRow.GetChild(talentThree-1)
          side.style.opacity = "1"
        }
        if (talentFour) {
          var StatRow = StatPipContainer.FindChild("StatRow25");
          var side = StatRow.GetChild(talentFour-1)
          side.style.opacity = "1"
        }
      }
    }
  }
}


(function () {
    GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateTalentTree );
    GameEvents.Subscribe( "dota_player_update_query_unit", UpdateTalentTree );
})();


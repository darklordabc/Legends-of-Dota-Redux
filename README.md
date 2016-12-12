Dota 2 Redux
=====

**Make Modding Great Again.**

###About###
 - Choose from a huge selection of gamemodes and mutators to make every experience unique!
 - Pick your skills or select a random build!
 - Take advantage of hero perks and custom abilities to further enhance your hero! 

###Github Issues###
 - Feel free to post an [issue](https://github.com/darklordabc/Dota-2-Redux/issues) on any subject. Improvements, bugs, ideas or to start a discussion, its all good.
 - There are two major lists of issues, ordered by priority, the bug list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/4), and the improvement list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/5). 

###Steam Workshop###
 - Click [here](https://steamcommunity.com/sharedfiles/filedetails/?id=717356279) to view Dota 2 Redux on the steam workshop.
 
###Discord Chat Server###
 - Click [here](https://discordapp.com/channels/242335821426851842/242335821426851842).

###Requirements to Compile and Run###
 - Dota 2 Workshop Tools
 - Nodejs

###How to extract from Github to Steam###
 - Download the Git repository from either using the manual option from website or from using Source (recommended method)
 
![Manual Method](http://i.imgur.com/wUGrQRg.png)

 - Unzip the file, and go to `\script_generator folder` and open `settings_example.json`. The `dotaDir` setting is not necesarry to be filled out because the script finds your dota folder via registry entries. The `addonName` is the name of your mod folder you want to create, THERE MUST BE NO FOLDER WITH THAT NAME THERE ALREADY, if there is a folder existing the compiling will fail. 
 - Once you have set an `addonName`, use `compile.bat`, and it should compile all the necessary files into a dota folder, these files will also be mklinked to the steam folder counterparts. 
 - These two folders should now exist in steam `SteamApps\common\dota 2 beta\game\dota_addons\<addonName>` and `SteamApps\common\dota 2 beta\content\dota_addons\<addonName>`

###Running Dota 2 Redux###
 - Start the Dota 2 Mod Tools by Right-Clicking on Dota 2 and clicking "Launch Dota 2 - Tools"

![Mod Tools](http://i.imgur.com/0EsjTMO.png)

 - Start a map by opening the console and running `dota_launch_custom_game <addonName> <mapname>`, replacing <addonName> with the name of your addon and <mapname> with a valid map name.
 - Valid map names can be found in the maps folder in the root directory of the repo. Do not include .vpk.
 - Check the console, you should see something along the lines of "Dota 2 Redux is activating!". Any errors while loading will be listed below this.

###Can I contribute code?###
 - Yes please do. The best way to contribute is to create a new branch on the repistory per feature, and then create a pull request to merge with "develop" branch. 
 - Your code will not be merged unless it meets the quality controls that are in place on this project.
 - Your code will not be merged if it does not follow the coding patterns / layout of the other code in the project.
 - Your code will not be merged if it implements a feature that is not inline with the direction the project is taking -- Please raise an issue asking if a feature would be good before implementing it, you may find certain features will never be approved.

###Coding Style Guide###
 - All variables and functions should be written in camel case, with the first letter being lowercase, and seperate words starting with uppercase
  - someVariableName is acceptable, some_variable_name and SomeVariableName are not acceptable
  - There are some instances where this rule has generally been broken, this was by mistake, before LoD had a well defined style
 - All code should be thread safe
  - If you make a call to an async function, ensure you check that the resources you want to access are still valid once the callback happens, this is usually needed when timers are used to process something on a unit after a short delay
 - Do not put credits or your name in code, the commit log will have your name, as well as the blame section of GitHub
 - Filenames are strictly lowercase. Sperate words should be seperated by an underscore (_) to increase readability, short file names should be used where possible, however, file names need to be readible and easily understandable.
 - Greentext in abilities (not including alt-text or warning texts) should accord to the following rule: We only use greentext in the tooltip, for REWORKED abilities, not for completely new ones. And greentext should only highlight what has been reworked, i.e. what is different to the reworked one and the original. [Example of correct usage.](http://imgur.com/5KWkSh5). The exception of green text in new abilities is when its a reworked new ability, an example of this, is the OP variety of abilities, greentext should be used to highlight the difference between the OP and normal version.

###Can I translate this into my language?###
 - Yes!
 - Open `src/localization/addon_<your langage>.txt`
 - You can reference `addon_english.txt`
 - You might need to save it as unicode, if non standard characters are used

###Credits###
 - For a breakdown of all the _tremendous_ developers who did _fantastic_ work on the mod, check the [collabrators page](https://github.com/darklordabc/Dota-2-Redux/graphs/contributors). 
 - Chinese Translation by [jhqz103](http://steamcommunity.com/profiles/76561198096463858/) and [ethereal](http://steamcommunity.com/profiles/76561198124343304/)

Legends of Dota Redux
=====

**Make Modding Great Again.**

### About ###
 - Choose from a huge selection of gamemodes and mutators to make every experience unique!
 - Pick your skills or select a random build!
 - Take advantage of hero perks and custom abilities to further enhance your hero! 
 - View the [Changelog](https://github.com/darklordabc/Dota-2-Redux/blob/develop/CHANGELOG.md)

### Github Issues ###
 - Feel free to post an [issue](https://github.com/darklordabc/Dota-2-Redux/issues) on any subject. Improvements, bugs, ideas or to start a discussion, its all good.
 - There are two major lists of issues, ordered by priority, the bug list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/4), and the improvement list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/5). 

### Steam Workshop ###
 - Click [here](https://steamcommunity.com/sharedfiles/filedetails/?id=786348190) to view Dota 2 Redux on the steam workshop.
 
### Discord Chat Server ###
 - Click [here](https://discordapp.com/channels/242335821426851842/242335821426851842).

### Ingame Comments Display ###
 - Click [here](http://ec2-52-59-238-84.eu-central-1.compute.amazonaws.com/wordpress/#messages).

### How to play Singple Player hosted on your machine ###
 - For players that have poor ping to dedicated servers, you may want to play locally (hosted on your own computer) todo this use this command in the console to launch a local game "dota_launch_custom_game 786348190 custom_bot".

### Requirements to Compile and Run ###
 - Dota 2 Workshop Tools
 - Nodejs

### How to extract from Github to Steam ###
- Install dota 2 workshop tools if you haven't already.
- Install [Node JS](https://nodejs.org/en/)
- Setup Github account.
- Use some git client to clone the redux repository (GitKraken, SourceTree. etc.)
![Manual Method](http://i.imgur.com/wUGrQRg.png)
- After cloning the repository to your computer edit your dota 2 path in `script_generator/settings_example.json`, set your `addonName` to something unique and rename the file to `settings.json`:
```
{
    "addonName" : "mycopyof_redux",
    "scriptDir":    "SRC/",
    "scriptDirOut": "BIN/",
    "dotaDir":      "C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta/",
    "customDir":    "CUSTOM/",
    "noPermute":    true
}
```
- Run `compile.bat`
- Create shortcut to run the workshop tools with your cloned repo. Set the shortcut target to something like this:
```
"C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\bin\win64\dota2.exe" -addon dr_redux -tools -steam  -console -vconsole
```

### Running Dota 2 Redux ###
 - Start the Dota 2 Mod Tools by Right-Clicking on Dota 2 and clicking "Launch Dota 2 - Tools"

![Mod Tools](http://i.imgur.com/0EsjTMO.png)

 - Start a map by opening the console and running `dota_launch_custom_game <addonName> <mapname>`, replacing <addonName> with the name of your addon and <mapname> with a valid map name.
 - Valid map names can be found in the maps folder in the root directory of the repo. Do not include .vpk.
 - Check the console, you should see something along the lines of "Dota 2 Redux is activating!". Any errors while loading will be listed below this.
 - If Sourcetree detects many particle (and other) files as "uncommited changes", this is because when you run the game it makes tiny changes to these particle files, to fix this you have to add these particles to your local "assumed unchanged" list, which tells SourceTree not to track changes for these files. A pastable list can be found here: [FIX](https://raw.githubusercontent.com/darklordabc/Legends-of-Dota-Redux/develop/FIX%20-%20Too%20Many%20'Uncommited%20Changes'.md)

### Can I contribute code? ###
 - Yes please do. The best way to contribute is to create a new branch on the repistory per feature, and then create a pull request to merge with "develop" branch. 
 - Your code will not be merged unless it meets the quality controls that are in place on this project.
 - Your code will not be merged if it does not follow the coding patterns / layout of the other code in the project.
 - Your code will not be merged if it implements a feature that is not inline with the direction the project is taking -- Please raise an issue asking if a feature would be good before implementing it, you may find certain features will never be approved.

### Coding Style Guide ###
 - All variables and functions should be written in camel case, with the first letter being lowercase, and seperate words starting with uppercase
  - someVariableName is acceptable, some_variable_name and SomeVariableName are not acceptable
  - There are some instances where this rule has generally been broken, this was by mistake, before LoD had a well defined style
 - All code should be thread safe
  - If you make a call to an async function, ensure you check that the resources you want to access are still valid once the callback happens, this is usually needed when timers are used to process something on a unit after a short delay
 - Do not put credits or your name in code, the commit log will have your name, as well as the blame section of GitHub
 - Filenames are strictly lowercase. Sperate words should be seperated by an underscore (_) to increase readability, short file names should be used where possible, however, file names need to be readible and easily understandable.
 - Greentext in abilities (not including alt-text or warning texts) should accord to the following rule: We only use greentext in the tooltip, for REWORKED abilities, not for completely new ones. And greentext should only highlight what has been reworked, i.e. what is different to the reworked one and the original. [Example of correct usage.](http://imgur.com/5KWkSh5). The exception of green text in new abilities is when its a reworked new ability, an example of this, is the OP variety of abilities, greentext should be used to highlight the difference between the OP and normal version.

### Can I translate this into my language? ###
 - Yes!
 - Open `src/localization/addon_<your langage>.txt`
 - You can reference `addon_english.txt`
 - You might need to save it as unicode, if non standard characters are used

### Credits ###
## Emoji key

Emoji | Represents | 
:---: | --- |
🌟 | Original Creator of LoD | 
😈 | Redux Director
👑 | Developer
🍭 | Custom Ability Creator
🌴 | Hero Perk Creator
🚀 | Panorama
😜 | Memes Redux Creator
🚩 | Game Logic
✨ | Developer of Other Mod
🈷 | Chinese Translator
🚣 | Creator of Overflow Abilities

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars2.githubusercontent.com/u/3754510?v=3&s=400" width="100px;"/><br /><sub>ash47</sub>](https://github.com/ash47)<br />🌟| [<img src="https://avatars2.githubusercontent.com/u/16277198?v=3&u=74f7571b7e976b4e58cf57ffdc9f2b375d1b3634&s=400" width="100px;"/><br /><sub>darklordabc</sub>](https://github.com/darklordabc)<br />😈 | [<img src="https://avatars3.githubusercontent.com/u/10674957?v=3&s=400" width="100px;"/><br /><sub>SwordBacon</sub>](https://github.com/SwordBacon)<br /> 👑✨🍭🌴😜| [<img src="https://avatars3.githubusercontent.com/u/1160901?v=3&s=400" width="100px;"/><br /><sub>TideSofDarK</sub>](https://github.com/TideSofDarK)<br /> 👑✨🍭🌴🚀🚩| [<img src="https://avatars2.githubusercontent.com/u/8745863?v=3&s=400" width="100px;"/><br /><sub>lcd1232</sub>](https://github.com/lcd1232)<br /> 👑👀 🔧 | [<img src="https://avatars2.githubusercontent.com/u/13403439?v=3&s=400" width="100px;"/><br /><sub>K1llMan</sub>](https://github.com/K1llMan)<br /> 👑🚀 | [<img src="https://avatars2.githubusercontent.com/u/9636071?v=3&s=400" width="100px;"/><br /><sub>Myrl</sub>](https://github.com/Myrl)<br />👑🚩🍭 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| [<img src="https://avatars3.githubusercontent.com/u/10646605?v=3&s=400" width="100px;"/><br /><sub>James Garbagnati</sub>](https://github.com/CarpeSwag)<br /> 👑✨🚀| [<img src="https://avatars0.githubusercontent.com/u/3296600?v=3&s=400" width="100px;"/><br /><sub>kernelpicnic</sub>](https://github.com/kernel-picnic)<br /> 👑🚀 | [<img src="https://avatars3.githubusercontent.com/u/11750369?v=3&s=400" width="100px;"/><br /><sub>ark120202</sub>](https://github.com/ark120202)<br />✨🚀🚩 | [<img src="https://avatars0.githubusercontent.com/u/11517760?v=3&s=400" width="100px;"/><br /><sub>Wouterz90</sub>](https://github.com/Wouterz90)<br /> 👑✨🍭🌴|[<img src="https://avatars3.githubusercontent.com/u/19353059?v=3&s=400" width="100px;"/><br /><sub>Yahnich</sub>](https://github.com/Yahnich)<br /> 👑✨🍭🌴|[<img src="https://avatars1.githubusercontent.com/u/25548968?v=3&s=400" width="100px;"/><br /><sub>OtsoTurpeinen</sub>](https://github.com/OtsoTurpeinen)<br /> 👑✨🍭🚣|[<img src="https://avatars2.githubusercontent.com/u/12683859?v=3&s=400" width="100px;"/><br /><sub>jhqz103</sub>](https://github.com/jhqz103)<br /> 🈷|
| [<img src="https://avatars0.githubusercontent.com/u/18477016?s=400&v=4" width="100px;"/><br /><sub>DankBudd</sub>](https://github.com/DankBudd)<br /> 👑✨| 
<!-- ALL-CONTRIBUTORS-LIST:END -->

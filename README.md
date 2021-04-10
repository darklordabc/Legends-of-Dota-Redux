# Legends of Dota Redux

**Make Modding Great Again.**

### About

-   Choose from a huge selection of gamemodes and mutators to make every experience unique!
-   Pick your skills or select a random build!
-   Take advantage of hero perks and custom abilities to further enhance your hero!
-   View the [Changelog](https://github.com/darklordabc/Dota-2-Redux/blob/develop/CHANGELOG.md) or the [Reddit Community](https://www.reddit.com/r/LegendsOfDotaRedux)

### Patreon

-   Nearly all the major features of Redux have been achieved by paying talented developers to implment them. If you enjoy Redux and can spare a few dollars, please consider supporting the mod financially so that it can continue to grow.
-   Supporting the mod will unlock exclusive features in game, as well as granting a special Discord role and Reddit flair
-   https://www.patreon.com/darklordabc

### Github Issues

-   Feel free to post an [issue](https://github.com/darklordabc/Dota-2-Redux/issues) on any subject. Improvements, bugs, ideas or to start a discussion, its all good.
-   There are two major lists of issues, ordered by priority, the bug list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/4), and the improvement list is [HERE](https://github.com/darklordabc/Dota-2-Redux/milestone/5).

### Steam Workshop

-   Click [here](https://steamcommunity.com/sharedfiles/filedetails/?id=786348190) to view Dota 2 Redux on the steam workshop.

### Discord Chat Server

-   Click [here](https://discordapp.com/channels/242335821426851842/242335821426851842).

### Ingame Comments Display

-   Click [here](http://ec2-52-59-238-84.eu-central-1.compute.amazonaws.com/wordpress/#messages).

### How to play Single Player hosted on your machine

-   For players that have poor ping to dedicated servers, you may want to play locally (hosted on your own computer) todo this use this command in the console to launch a local game "dota_launch_custom_game 786348190 custom_bot".

### Prerequisites

-   Enable Workshop Tools in your Dota DLC ![](https://imgur.com/DPE4S5b.png)
-   Install Node.js

### Set up

1. Clone this repo locally to your Desktop/projects folder
2. Open PowerShell/cmd.exe in the cloned folder
3. Type `npm install`

Common issues with `npm install` :

-   Make sure none of the files in the game/content folders are being used in another program while you are trying to `npm install`
-   Make sure the following folder don't exist before you run `npm install`

    -   Game: `dota 2 beta\game\dota_addons\legends_of_dota_redux`
    -   Content: `dota 2 beta\content\dota_addons\legends_of_dota_redux`

### Running the map

1. Open `legends_of_dota_redux` in Dota Tools. You can create a shortcut for this, Target: `"C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\bin\win64\dota2.exe" -addon legends_of_dota_redux -tools -vconsole -dev`
2. Open console and type `dota_launch_custom_game legends_of_dota_redux custom` (Replace `custom` with name of map you want to run)

### Can I contribute code?

-   Yes please do. The best way to contribute is to create a new branch on the repistory per feature, and then create a pull request to merge with "develop" branch.
-   Your code will not be merged unless it meets the quality controls that are in place on this project.
-   Your code will not be merged if it does not follow the coding patterns / layout of the other code in the project.
-   Your code will not be merged if it implements a feature that is not inline with the direction the project is taking -- Please raise an issue asking if a feature would be good before implementing it, you may find certain features will never be approved.

### Coding Style Guide

-   All variables and functions should be written in camel case, with the first letter being lowercase, and seperate words starting with uppercase
-   someVariableName is acceptable, some_variable_name and SomeVariableName are not acceptable
-   There are some instances where this rule has generally been broken, this was by mistake, before LoD had a well defined style
-   All code should be thread safe
-   If you make a call to an async function, ensure you check that the resources you want to access are still valid once the callback happens, this is usually needed when timers are used to process something on a unit after a short delay
-   Do not put credits or your name in code, the commit log will have your name, as well as the blame section of GitHub
-   Filenames are strictly lowercase. Sperate words should be seperated by an underscore (\_) to increase readability, short file names should be used where possible, however, file names need to be readible and easily understandable.
-   Greentext in abilities (not including alt-text or warning texts) should accord to the following rule: We only use greentext in the tooltip, for REWORKED abilities, not for completely new ones. And greentext should only highlight what has been reworked, i.e. what is different to the reworked one and the original. [Example of correct usage.](http://imgur.com/5KWkSh5). The exception of green text in new abilities is when its a reworked new ability, an example of this, is the OP variety of abilities, greentext should be used to highlight the difference between the OP and normal version.

### Can I translate this into my language?

-   Yes!
-   Open `src/localization/addon_<your langage>.txt`
-   You can reference `addon_english.txt`
-   You might need to save it as unicode, if non standard characters are used

### Credits

## Emoji key

| Emoji | Represents                    |
| :---: | ----------------------------- |
|  🌟   | Original Creator of LoD       |
|  😈   | Redux Director                |
|  👑   | Developer                     |
|  🍭   | Custom Ability Creator        |
|  🌴   | Hero Perk Creator             |
|  🚀   | Panorama                      |
|  😜   | Memes Redux Creator           |
|  🚩   | Game Logic                    |
|  ✨   | Developer of Other Mod        |
|  🈷   | Chinese Translator            |
|  🚣   | Creator of Overflow Abilities |

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->

| [<img src="https://avatars2.githubusercontent.com/u/3754510?v=3&s=400" width="100px;"/><br /><sub>ash47</sub>](https://github.com/ash47)<br />🌟 | [<img src="https://avatars0.githubusercontent.com/u/11517760?v=3&s=400" width="100px;"/><br /><sub>Wouterz90</sub>](https://github.com/Wouterz90)<br /> 😈✨🍭🌴 | [<img src="https://avatars3.githubusercontent.com/u/10674957?v=3&s=400" width="100px;"/><br /><sub>SwordBacon</sub>](https://github.com/SwordBacon)<br /> 👑✨🍭🌴😜 | [<img src="https://avatars3.githubusercontent.com/u/1160901?v=3&s=400" width="100px;"/><br /><sub>TideSofDarK</sub>](https://github.com/TideSofDarK)<br /> 👑✨🍭🌴🚀🚩 | [<img src="https://avatars2.githubusercontent.com/u/8745863?v=3&s=400" width="100px;"/><br /><sub>lcd1232</sub>](https://github.com/lcd1232)<br /> 👑👀 🔧 | [<img src="https://avatars2.githubusercontent.com/u/13403439?v=3&s=400" width="100px;"/><br /><sub>K1llMan</sub>](https://github.com/K1llMan)<br /> 👑🚀 | [<img src="https://avatars2.githubusercontent.com/u/9636071?v=3&s=400" width="100px;"/><br /><sub>Myrl</sub>](https://github.com/Myrl)<br />👑🚩🍭 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| [<img src="https://avatars3.githubusercontent.com/u/10646605?v=3&s=400" width="100px;"/><br /><sub>James Garbagnati</sub>](https://github.com/CarpeSwag)<br /> 👑✨🚀 | [<img src="https://avatars0.githubusercontent.com/u/3296600?v=3&s=400" width="100px;"/><br /><sub>kernelpicnic</sub>](https://github.com/kernel-picnic)<br /> 👑🚀 | [<img src="https://avatars3.githubusercontent.com/u/11750369?v=3&s=400" width="100px;"/><br /><sub>ark120202</sub>](https://github.com/ark120202)<br />✨🚀🚩 | [<img src="https://avatars2.githubusercontent.com/u/16277198?v=3&u=74f7571b7e976b4e58cf57ffdc9f2b375d1b3634&s=400" width="100px;"/><br /><sub>darklordabc</sub>](https://github.com/darklordabc)<br />👑 | [<img src="https://avatars3.githubusercontent.com/u/19353059?v=3&s=400" width="100px;"/><br /><sub>Yahnich</sub>](https://github.com/Yahnich)<br /> 👑✨🍭🌴 | [<img src="https://avatars1.githubusercontent.com/u/25548968?v=3&s=400" width="100px;"/><br /><sub>OtsoTurpeinen</sub>](https://github.com/OtsoTurpeinen)<br /> 👑✨🍭🚣 | [<img src="https://avatars2.githubusercontent.com/u/12683859?v=3&s=400" width="100px;"/><br /><sub>jhqz103</sub>](https://github.com/jhqz103)<br /> 🈷 |
| [<img src="https://avatars0.githubusercontent.com/u/18477016?s=400&v=4" width="100px;"/><br /><sub>DankBudd</sub>](https://github.com/DankBudd)<br /> 👑✨ |

<!-- ALL-CONTRIBUTORS-LIST:END -->

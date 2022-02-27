# Checklist
Lets say to make a level for your game you need to take a few steps. These are to complex to perfectly remember and not feasible to automate.
You need a Checklist. Step by step instructions for future you how to do this. 
If parts of your process are automated you can launch scripts or export your game directly from the Checklist Docker.
Also has a build in changelog editor.
You can use it as a todo list I guess but it is not meant for that. It is totally different.

## Making Checklists
Generally parts of a command are seperated by | and comments start with #
Empty lines will be ignored.

|Description|Example|Result|
|-----------|-------|------|
|Basic checklist items can just be written like so|Checklist Item|![](addons/Checklist/screenshots/ChecklistItem.png)
|To add a Label start the line with L\||L\|This will be a Label|![](addons/Checklist/screenshots/Label.png)
|Add indentation with I\| then add a number to change it by <br />Use = to set the indentation <br /> negative numbers also work. |I\|1 <br /> I\|=2 <br /> I\|-2|![](addons/Checklist/screenshots/Indentation.png)
|You can export any or all presets with one button <br /> Use E\|text\| to get the button, add \|true for debug mode and anything else for release. <br /> Then write all names of the export presets you want to export <br /> Write all to export all presets|E\|Export All Release\|f\|all<br />E\|Export All Debug\|true\|all<br />E\|Desktop Release\|f\|Windows Desktop\|Mac OSX\|Linux/X11<br />E\|Desktop Debug\|true\|Windows Desktop\|Mac OSX\|Linux/X11<br />E\|Mobile Release\|f\|Android\|IOS<br />E\|Mobile Debug\|true\|Android\|IOS<br />|![](addons/Checklist/screenshots/Export.png)


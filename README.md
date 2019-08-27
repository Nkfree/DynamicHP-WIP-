# DynamicHP-WIP- *PLEASE TEST OUT AND LET ME KNOW*

## Requires

[DataManager (by urm)](https://github.com/tes3mp-scripts/DataManager)

## Installation

1. Install *DataManager* (has to be installed and put into customScripts first)
2. Download the ```main.lua``` and put it in */server/scripts/custom/DynamicHP*
3. Open ```customScripts.lua``` and add this code on separate line: ```DynamicHP = require "custom/DynamicHP/main"```

## Description

Dynamic scaling of actors hp based on amount of visitors in certain cell.
The idea is to make raiding dungeons, wandering and combat overall harder in the simpliest of ways.

There are included debug messages as I'd love somebody to try it out first and let me know if any problems occured, this should help tracking the most important variables.


## To do

1. Configurable variable that could scale/rise the starting health of an actor.


Thanks to David C. for explanations on this topic.




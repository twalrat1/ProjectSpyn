%%%%% ProjectSpyn %%%%%
% ASU FSE100 Section: 16722
% Spring 2022
% Adam Colyar, Aryan Hiteshkumar, Rishikumar Senthilvel, Trevor Walrath

%%% Add Global Variables Here
% TODO: Add flag variables for objectives- hasPassenger,
%   deliveredPassenger, etc
% Variables to store sensor data
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove
% ManualNav Function- copy code from BasicManualControl to this doc as a
%   function

%%% Begin Main Program %%%

AutoNav(); % Get to Pick up location (Blue)- use arguments to indicate exit condition blue
BasicManualControl(); % Pick Up Passenger
AutoNav(); % Get to Drop off location (Green)- use arguments to indicate exit condition green
BasicManualControl(); % Drop off Passenger
AutoNav(); % Get to End location (Yellow)- use arguments to indicate exit condition yellow
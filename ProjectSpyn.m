%%%%% ProjectSpyn %%%%%
% ASU FSE100 Section: 16722
% Spring 2022
% Adam Colyar, Aryan Hiteshkumar, Rishikumar Senthilvel, Trevor Walrath

%%% Add Global Variables Here
turnSpeed = 15;
manSpeed = 15;
autoSpeed = 50;
colorMode = 2;
colorSize = 3;
color = ones(1,colorSize);
colorAvg = mode(color);
wheelOffset = 1;
liftAngle = 20;
liftSpeed = 10;
distances = zeros(1,3);
blueFound = 0;
greenFound = 0;
pickedUp = 0;
droppedOff = 0;
% maze = graph;

% TODO: Add flag variables for objectives- hasPassenger,
%   deliveredPassenger, etc
% Variables to store sensor data
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove
% ManualNav Function- copy code from BasicManualControl to this doc as a
%   function

%%% Sensor & Motor Ports %%%
leftMotor = 'A';
rightMotor = 'B';
liftMotor = 'C';
distMotor = 'D';
distPort = 1;
colorPort = 2;

%%% Begin Main Program %%%
brick.SetColorMode(colorPort,colorMode);

%AutoNav(); % Get to Pick up location (Blue)- use arguments to indicate exit condition blue
ManualNav(brick,turnSpeed,manSpeed,wheelOffset,leftMotor,rightMotor,liftMotor,liftAngle,liftSpeed); % Pick Up Passenger
%AutoNav(); % Get to Drop off location (Green)- use arguments to indicate exit condition green
ManualNav(brick,turnSpeed,manSpeed,wheelOffset,leftMotor,rightMotor,liftMotor,liftAngle,liftSpeed); % Drop Off Passenger
%AutoNav(); % Get to End location (Yellow)- use arguments to indicate exit condition yellow

function AutoNav(brick,turnSpeed,speed,offset,motorL,motorR,dist,motorD,distP,color,colorP,colorSize)
    while 0 % Loop until exit condition- based on color code
        % Gather distances store in array
        dist = getDistance(brick,distP,motorC,10);
        % Update maze map
        % Decide next action- forward left right
        % 1-MoveForward 2-TurnLeft 3-TurnRight 4-TurnAround
        decision = makeDecision(dist);
        % execute action- check colors
        execute(decision);
    end
return
end

function decision = makeDecision()
    return 0;
end

function execute()
    return
end

function distance = getDistance(brick,dPort,mPort,mSpeed)
    % Forward dist
    brick.ResetMotorAngle(mPort);
    distance(1) = brick.UltrasonicDist(dPort);
    % Right dist
    brick.MoveMotorAngleAbs(mPort, mSpeed, 90, 'Brake');
    brick.WaitForMotor(mPort);
    distance(2) = brick.UltrasonicDist(dPort);
    % Left dist
    brick.MoveMotorAngleAbs(mPort, mSpeed, -90, 'Brake');
    brick.WaitForMotor(mPort);
    distance(3) = brick.UltrasonicDist(dPort);
    brick.MoveMotorAngleAbs(mPort, mSpeed, 0, 'Brake');
    brick.WaitForMotor(mPort);
    brick.StopMotor(mPort,'Coast');
end

function ManualNav(brick,turnSpeed,speed,offset,wMotorL,wMotorR,lMotor,liftAngle,liftSpeed)
global key;
InitKeyboard();

while 1
    pause(0.1);
    switch key
        case 'uparrow'
            move(brick,speed,offset,wMotorL,wMotorR);
        case 'downarrow'
            move(brick,-1*speed,-1*offset,wMotorL,wMotorR);
        case 'rightarrow'
            turn(brick,turnSpeed,wMotorL,wMotorR);
        case 'leftarrow'
            turn(brick,-1*turnSpeed,wMotorL,wMotorR);
        case 's'
            brick.StopAllMotors('Coast');
        case 'l'
            operateLift(brick,lMotor,liftSpeed,liftAngle);
        case 'd'
            operateLift(brick,lMotor,-1*liftSpeed,liftAngle);
        case 0
            brick.StopAllMotors('Coast');
        case 'q'
            return;
    end
end
CloseKeyboard();
end

function operateLift(brick,motor,speed,angle)
    brick.ResetMotorAngle(motor);
    brick.MoveMotorAngleRel(motor, speed, angle, 'Brake');
    brick.WaitForMotor(motor);
    pause(1);
    brick.StopAllMotors('Coast');
end

function move(brick,speed,offset,motorL,motorR)
    brick.MoveMotor(motorL, speed+offset);
    brick.MoveMotor(motorR,speed-offset);
end

function turn(brick,speed,motorL,motorR)
    brick.MoveMotor(motorL, speed);
    brick.MoveMotor(motorR, -1*speed);
end
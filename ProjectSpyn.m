%%%%% ProjectSpyn %%%%%
% ASU FSE100 Section: 16722
% Spring 2022
% Adam Colyar, Aryan Hiteshkumar, Rishikumar Senthilvel, Trevor Walrath

%%% Global Variables %%% 
global colorSize;   colorSize = 3;
global color;       color = ones(1,colorSize);
global colorAvg;    colorAvg = mode(color);
global colorIx;     colorIx = 1;
global liftAngle;   liftAngle = 20;
global turn90Angle; turn90Angle = 90;
global distSpeed;   distSpeed = 10;
global distance;    distance = zeros(1,3);
global blueFound;   blueFound = 0;
global greenFound;  greenFound = 0;
global pickedUp;    pickedUp = 0;
global droppedOff;  droppedOff = 0;
%global maze;        maze = graph;

%%% Sensor & Motor Ports %%%
global leftMotor;   leftMotor = 'A';
global rightMotor;  rightMotor = 'B';
global wheelMotors; wheelMotors = 'AB';
global liftMotor;   liftMotor = 'C';
global distMotor;   distMotor = 'D';
global distPort;    distPort = 1;
global colorPort;   colorPort = 2;

%%% Local variables for AutoNav and ManNav functions %%%
autoSpeed = 50;
manSpeed = 15;
wheelOffset = 0;
turnSpeed = 15;
liftSpeed = 10;
colorMode = 2;
blueSquare = 2;
greenSquare = 3;
yellowSquare = 4;

% TODO:
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove

%%% Begin Main Program %%%
brick.SetColorMode(colorPort,colorMode);

% Autonomously navigate to Pick up location (Blue)
AutoNav(autoSpeed,turnSpeed,blueSquare); 
% Pick Up Passenger- Remote Control
ManualNav(manSpeed,wheelOffset,turnSpeed,liftSpeed); 
% Autonomously navigate to Drop off location (Green)
AutoNav(autoSpeed,turnSpeed,greenSquare); 
% Drop Off Passenger- Remote Control
ManualNav(manSpeed,wheelOffset,turnSpeed,liftSpeed); 
% Autonomously navigate to End location (Yellow)
AutoNav(autoSpeed,turnSpeed,yellowSquare); 

function AutoNav(speed,turnSpeed,exitColor)
    %global brick;
    exit = 0;
    
    while exit ~= 1 % Loop until exit condition- based on color code
        % Gather distances store in array
        getDistance();
        % Update maze map
        % Decide next action- forward left right
        % 1-MoveForward 2-TurnLeft 3-TurnRight 4-TurnAround
        decision = makeDecision();
        % execute action- check colors
        exit = execute(decision,exitColor,speed,turnSpeed);
    end
return
end

function decision = makeDecision
    decision = 0;
    return;
end

function code = execute(decision,exitColor,speed,turnSpeed)
    global brick color colorPort colorSize colorIx distPort distance;
    code = 0;
    
    switch decision
        case 1
            % Move Forward- do nothing here
        case 2
            % turnLeft
            turn(-1*turnSpeed);
        case 3
            % turnRight
            turn90(turnSpeed);
        case 4
            % turnAround = turnRight x2
            turn90(turnSpeed);
            turn90(turnSpeed);
        otherwise
            disp( 'no decision made' );
    end
    % actually move forward- a turn is always followed by forward movement
    move(speed,0);
    targetDist = distance(1) - 50; % each square is app 50cm long
    while distance(1) > targetDist %loop to move desired distance
        % Update color array as car is moving
        color(colorIx) = brick.ColorCode(colorPort);
        colorIx = colorIx + 1;
        if( colorIx == (colorSize+1) )
            colorIx = 1; % keep index within bounds >=1 & <=3
        end
        colorAvg = mode(color);
        % check for AutoNav exit condition
        if colorAvg == exitColor
            code = 1;
            brick.StopAllMotors('Coast');
            return;
        end
        % check for Stop Sign
        if colorAvg == 5 % 5 = Red
            brick.StopAllMotors('Coast');
            pause(1);
            move(speed,0);
        end
        distance(1) = brick.UltrasonicDist(distPort);
    end
    
    return;
end

function turn90(speed)
    global brick rightMotor leftMotor turn90Angle wheelMotors;
    brick.ResetMotorAngle(rightMotor);
    brick.MoveMotorAngleAbs(leftMotor,speed,turn90Angle,'Brake');
    brick.MoveMotorAngleAbs(rightMotor,-1*speed,turn90Angle,'Brake');
    brick.WaitForMotor(wheelMotors);
    brick.StopAllMotors('Coast');
    %brick.MoveMotor(leftMotor, speed);
    %brick.MoveMotor(rightMotor, -1*speed);
end

function getDistance
    global brick distPort distMotor distSpeed distance;
    % Forward dist
    brick.ResetMotorAngle(distMotor);
    distance(1) = brick.UltrasonicDist(distPort);
    % Right dist
    brick.MoveMotorAngleAbs(distMotor, distSpeed, 90, 'Brake');
    brick.WaitForMotor(distMotor);
    distance(2) = brick.UltrasonicDist(distPort);
    % Left dist
    brick.MoveMotorAngleAbs(distMotor, distSpeed, -90, 'Brake');
    brick.WaitForMotor(distMotor);
    distance(3) = brick.UltrasonicDist(distPort);
    brick.MoveMotorAngleAbs(distMotor, distSpeed, 0, 'Brake');
    brick.WaitForMotor(distMotor);
    brick.StopMotor(distMotor,'Coast');
end

function ManualNav(speed,offset,turnSpeed,liftSpeed)
global key;
InitKeyboard();

while key ~= 'q'
    pause(0.1);
    switch key
        case 'uparrow'
            move(speed,offset);
        case 'downarrow'
            move(-1*speed,-1*offset);
        case 'rightarrow'
            turn(turnSpeed);
        case 'leftarrow'
            turn(-1*turnSpeed);
        case 's'
            brick.StopAllMotors('Coast');
        case 'l'
            operateLift(liftSpeed);
        case 'd'
            operateLift(-1*liftSpeed);
        case 0
            brick.StopAllMotors('Coast');
    end
end
CloseKeyboard();
end

function operateLift(speed)
    global brick liftMotor liftAngle;
    brick.ResetMotorAngle(liftMotor);
    brick.MoveMotorAngleRel(liftMotor, speed, liftAngle, 'Brake');
    brick.WaitForMotor(liftMotor);
    brick.StopAllMotors('Coast');
end

function move(speed,offset)
    global brick rightMotor leftMotor; % wheelMotors;
    % try brick.MoveMotor(wheelMotors,speed); to resolve drifting
    brick.MoveMotor(leftMotor, speed+offset);
    brick.MoveMotor(rightMotor,speed);
end

function turn(speed)
    global brick rightMotor leftMotor;
    brick.MoveMotor(leftMotor, speed);
    brick.MoveMotor(rightMotor, -1*speed);
end

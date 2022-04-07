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
global turn90Angle; turn90Angle = 175;
global distSpeed;   distSpeed = 30;
global distance;    distance = zeros(1,3);
global blueFound;   blueFound = 0;
global greenFound;  greenFound = 0;
global pickedUp;    pickedUp = 0;
global droppedOff;  droppedOff = 0;
global squareDist;  squareDist = 57;
global moveTime;    moveTime = 50;
%global maze;        maze = graph;

%%% Sensor & Motor Ports %%%
global leftMotor;   leftMotor = 'A';
global rightMotor;  rightMotor = 'B';
global wheelMotors; wheelMotors = 'AB';
global liftMotor;   liftMotor = 'C';
global distMotor;   distMotor = 'D';
global distPort;    distPort = 1;
global colorPort;   colorPort = 4;
global RED;         RED = 5;
global YELLOW;      YELLOW = 4;
global GREEN;       GREEN = 3;
global BLUE;        BLUE = 2;


%%% Local variables for AutoNav and ManNav functions %%%
autoSpeed = 50;
autoTurn = 40;
manSpeed = 15;
wheelOffset = 0;
turnSpeed = 15;
liftSpeed = 10;
colorMode = 2;

% TODO:
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove

%%% Begin Main Program %%%
brick.SetColorMode(colorPort,colorMode);

% Autonomously navigate to Pick up location (Blue)
AutoNav(brick,autoSpeed,autoTurn,BLUE); 
% Pick Up Passenger- Remote Control
ManualNav(brick,manSpeed,wheelOffset,turnSpeed,liftSpeed); 
% Autonomously navigate to Drop off location (Green)
AutoNav(brick,autoSpeed,autoTurn,GREEN); 
% Drop Off Passenger- Remote Control
ManualNav(brick,manSpeed,wheelOffset,turnSpeed,liftSpeed); 
% Autonomously navigate to End location (Yellow)
AutoNav(brick,autoSpeed,autoTurn,YELLOW); 

function AutoNav(brick,speed,turnSpeed,exitColor)
    exitCode = 0;
    
    while exitCode ~= 1 % Loop until exit condition- based on color code
        % Gather distances store in array
        getDistance(brick);
        % Update maze map
        % Decide next action- forward left right
        % 1-MoveForward 2-TurnLeft 3-TurnRight 4-TurnAround
        disp('make decision');
        decision = makeDecision();
        % execute action- check colors
        disp(decision);
        disp('execute decision');
        exitCode = execute(brick,decision,exitColor,speed,turnSpeed);
    end
    return
end

function decision = makeDecision
    global distance squareDist;
    if( distance(2) > squareDist )
        % No wall detected on right = turn right
        decision = 3;
        return;
    else
        if( distance(1) > squareDist )
            % wall on right and no wall ahead = move forward
            decision = 1;
            return;
        else
            if( distance(3) > squareDist )
                % wall on right and ahead but not on left = turn left
                decision = 2;
                return
            else
                % wall on right, ahead, and left = turn around
                decision = 2;
                return;
            end
            
        end
    end
end

function code = execute(brick,decision,exitColor,speed,turnSpeed)
    global color colorPort colorSize colorIx distPort distance squareDist moveTime;
    global RED GREEN BLUE blueFound greenFound;
    code = 0;
    
    disp('execution');
    switch decision
        case 1
            % Move Forward- do nothing here
        case 2
            % turnLeft
            turn90(brick,-1*turnSpeed);
        case 3
            % turnRight
            turn90(brick,turnSpeed);
        case 4
            % turnAround = turnRight x2
            turn90(brick,turnSpeed);
            turn90(brick,turnSpeed);
        otherwise
            disp( 'no decision made' );
    end
    
    % actually move forward- a turn is always followed by forward movement
    correction = 2;
    disp(distance(1));
    targetDist = distance(1) - squareDist; % each square is app 50cm long
    move(brick,speed,correction);
    color = ones(1,colorSize);
    colorIx = 1;
    timer = 0;
    while (distance(1) > targetDist) && timer < moveTime %loop to move desired distance
        % Update color array as car is moving
        color(colorIx) = brick.ColorCode(colorPort);
        colorIx = colorIx + 1;
        if( colorIx == (colorSize+1) )
            colorIx = 1; % keep index within bounds >=1 & <=3
        end
        colorAvg = mode(color);
        % check for Stop Sign
        if colorAvg == RED % 5 = Red
            brick.StopAllMotors('Coast');
            pause(1);
            move(brick,speed,correction);
            color = ones(colorSize);
        end
        % Check if blue square is found
        if colorAvg == BLUE
            blueFound = 1;
        end
        % Check if green square is found
        if colorAvg == GREEN
            greenFound = 1;
        end
        % check for AutoNav exit condition
        if colorAvg == exitColor
            code = 1;
            brick.StopAllMotors('Coast');
            return;
        end
        pause(0.1);
        timer = timer+1;
        distance(1) = brick.UltrasonicDist(distPort);
    end
    brick.StopAllMotors('Coast');
    return;
end

function turn90(brick,speed)
    global rightMotor leftMotor turn90Angle;
    brick.ResetMotorAngle(rightMotor);
    brick.MoveMotorAngleAbs(leftMotor,speed,turn90Angle,'Brake');
    brick.WaitForMotor(leftMotor);
    brick.MoveMotorAngleAbs(rightMotor,-1*speed,turn90Angle,'Brake');
    brick.WaitForMotor(rightMotor);
    brick.StopAllMotors('Coast');
end

function getDistance(brick)
    global distPort distMotor distSpeed distance;
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

function ManualNav(brick,speed,offset,turnSpeed,liftSpeed)
    global key;
    InitKeyboard();

    while key ~= 'q'
        pause(0.1);
        switch key
            case 'uparrow'
                move(brick,speed,offset);
            case 'downarrow'
                move(brick,-1*speed,-1*offset);
            case 'rightarrow'
                turn(brick,turnSpeed);
            case 'leftarrow'
                turn(brick,-1*turnSpeed);
            case 's'
                brick.StopAllMotors('Coast');
            case 'l'
                operateLift(brick,liftSpeed);
            case 'd'
                operateLift(brick,-1*liftSpeed);
            case 0
                brick.StopAllMotors('Coast');
        end
    end
    CloseKeyboard();
end

function operateLift(brick,speed)
    global liftMotor liftAngle;
    brick.ResetMotorAngle(liftMotor);
    brick.MoveMotorAngleRel(liftMotor, speed, liftAngle, 'Brake');
    brick.WaitForMotor(liftMotor);
    brick.StopAllMotors('Coast');
end

function move(brick,speed,offset)
    global rightMotor leftMotor;
    brick.MoveMotor(leftMotor, speed+offset);
    brick.MoveMotor(rightMotor,speed);
end

function turn(brick,speed)
    global rightMotor leftMotor;
    brick.MoveMotor(leftMotor, speed);
    brick.MoveMotor(rightMotor, -1*speed);
end

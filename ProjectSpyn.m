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
global moveTime;    moveTime = 13;
global turnTime;    turnTime = 10;
global mapDist;     mapDist = 100;
global orientation; orientation = 1;  % 1-North 2-South 3-East 4-West
global pos;         pos = [0,0];
global autoOffset;  autoOffset = 2;
global robotSq;     robotSq = 0;
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
global YellowSq;
global BlueSq;
global GreenSq;

%%% Local variables for AutoNav and ManNav functions %%%
autoSpeed = 50;
autoTurn = 32;
manSpeed = 15;
wheelOffset = 2;
turnSpeed = 15;
liftSpeed = 10;
colorMode = 2;

% TODO:
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove

%%% Begin Main Program %%%
brick.SetColorMode(colorPort,colorMode);
createMap();
[pos,posCheck] = setStart();

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
        getCorrection();
        
        % Update maze map
        % Decide next action- forward left right
        % 1-MoveForward 2-TurnLeft 3-TurnRight 4-TurnAround
        disp('make decision');
        decision = makeDecision();
        changePosition
        updateMap
        % execute action- check colors
        disp(decision);
        disp('execute decision');
        exitCode = execute(brick,decision,exitColor,speed,turnSpeed);
    end
    return
end

function updateMap
    global orientation;
    for i = 1:3
        findPos(orientation);
    end
end

function changePosition
    global pos orientation mapDist;
    switch(orientation)
        case 1 % North
            pos = [pos(1), pos(2) + mapDist];
        case 3 % South
            pos = [pos(1), pos(2) - mapDist];
        case 2 % East
            pos = [pos(1) + mapDist, pos(2)];
        case 4 % West
            pos = [pos(1) - mapDist, pos(2)];
    end
    refreshdata
    drawnow
end

function createMap()
hold on

xlim([0,1000]);
ylim([0,1200]);
p = plot(xlim,ylim,'linestyle','none');
axis equal;
grid on
updateData(3);
end

function findPos(dir)
    global pos robotSq;
    if robotSq ~= 0
        delete( robotSq ); 
    end
    robotSq = rectangle('Position',[pos(1)+25 pos(2)+25 25 25]);
    refreshdata
    drawnow
end

function [pos, posCheck] = setStart()
    global YellowSq;
    pos = [400,600];
    posCheck = 1;
    YellowSq = rectangle('Position',[pos(1)+15 pos(2)+15 70 70],'FaceColor','y','LineStyle',':');
    refreshdata
    drawnow
end

function updateData(dir) %Update the map/figure with a new wall based off incoming distance reading
    global pos mapDist;

    p.XDataSource = 'x2';
    p.YDataSource = 'y2';

    %Direction should be 1,2,3,4 for north, south, east, or west
  switch dir
    case 1
        x2 = [pos(1), pos(1) + mapDist];
        y2 = [pos(2)+mapDist, pos(2) + mapDist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        disp("north")

    case 3
        x2 = [pos(1), pos(1) + mapDist];
        y2 = [pos(2), pos(2)];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        disp("south")

    case 4
        x2 = [pos(1), pos(1)];
        y2 = [pos(2), pos(2)+mapDist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        disp("west")

    case 2
        x2 = [pos(1) + mapDist, pos(1) + mapDist];
        y2 = [pos(2), pos(2) + mapDist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        disp("east")    

    case 0
        disp("Fail")

  end

    refreshdata
    drawnow
end

function decision = makeDecision
    global distance squareDist orientation;
    if( distance(2) > squareDist )
        % No wall detected on right = turn right
        decision = 3;
        orientation = orientation + 1;
        if( orientation == 5 )
            orientation = 1;
        end
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
                orientation = orientation - 1;
                if( orientation == 0 )
                    orientation = 4;
                end
                return
            else
                % wall on right, ahead, and left = turn around
                decision = 4;
                orientation = orientation + 2;
                if( orientation == 5 )
                    orientation = 1;
                elseif( orientation == 6 )
                    orientation = 2;
                end
                return;
            end
            
        end
    end
end

function code = execute(brick,decision,exitColor,speed,turnSpeed)
    global color colorPort colorSize colorIx distPort distance squareDist moveTime;
    global wheelMotors autoOffset;
    global RED GREEN BLUE blueFound greenFound BlueSq GreenSq pos;
    code = 0;
    
    disp('execution');
    disp(decision);
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
    disp(distance(1));
    targetDist = distance(1) - squareDist; % each square is app 50cm long
    disp(targetDist);
    color = ones(1,colorSize);
    colorIx = 1;
    timer = 0;
    move(brick,speed,autoOffset);
    
    while timer < moveTime %(distance(1) > targetDist)% || timer < moveTime %loop to move desired distance
        % Update color array as car is moving
        color(colorIx) = brick.ColorCode(colorPort);
        colorIx = colorIx + 1;
        if( colorIx == (colorSize+1) )
            colorIx = 1; % keep index within bounds >=1 & <=3
        end
        colorAvg = mode(color);
        % check for Stop Sign
        if colorAvg == RED % 5 = Red
            %brick.StopMotor(wheelMotors,'Brake');
            brick.StopMotor(wheelMotors,'Coast');
            pause(1);
            move(brick,speed,autoOffset);
            color = ones(colorSize);
            rectangle('Position',[pos(1)+15 pos(2)+15 70 70],'FaceColor','r','LineStyle',':');
        end
        % Check if blue square is found
        if colorAvg == BLUE
            blueFound = 1;
            BlueSq = rectangle('Position',[pos(1)+15 pos(2)+15 70 70],'FaceColor','b','LineStyle',':');
        end
        % Check if green square is found
        if colorAvg == GREEN
            greenFound = 1;
            GreenSq = rectangle('Position',[pos(1) pos(2) 70 70],'FaceColor','g','LineStyle',':');
        end
        % check for AutoNav exit condition
        if colorAvg == exitColor
            code = 1;
            %brick.StopMotor(wheelMotors,'Brake');
            brick.StopMotor(wheelMotors,'Coast');
            return;
        end
        pause(0.1);
        timer = timer+1;
        distance(1) = brick.UltrasonicDist(distPort);
        disp(distance(1));
    end
    %brick.StopMotor(wheelMotors,'Brake');
    brick.StopMotor(wheelMotors,'Coast');
    return;
end

function getCorrection
    global distance squareDist autoOffset;
    left = distance(3);
    right = distance(2);
    
    while left > squareDist
        left = left - squareDist;
    end
    while right > squareDist
        right = right - squareDist;
    end
    
    center = (right - left) - 13;
    
    if center >=  5
        autoOffset = autoOffset+1;
    end
    if center <= -5
        autoOffset = autoOffset-1;
    end
    disp( autoOffset );
   return;
end

function turn90(brick,speed)
    global rightMotor leftMotor turn90Angle wheelMotors direction;
    brick.ResetMotorAngle(leftMotor);
    brick.MoveMotorAngleAbs(leftMotor,speed,turn90Angle,'Brake');
    brick.WaitForMotor(leftMotor);
    brick.ResetMotorAngle(rightMotor);
    brick.MoveMotorAngleAbs(rightMotor,-1*speed,turn90Angle,'Brake');
    brick.WaitForMotor(rightMotor);
    brick.StopMotor(wheelMotors,'Coast');
end

function getDistance(brick)
    global distPort distMotor distSpeed distance orientation squareDist;
    % Forward dist
    brick.ResetMotorAngle(distMotor);
    distance(1) = brick.UltrasonicDist(distPort);
    if( distance(1) < squareDist )
        updateData(orientation);
    end
    % Right dist
    brick.MoveMotorAngleAbs(distMotor, distSpeed, 90, 'Brake');
    brick.WaitForMotor(distMotor);
    distance(2) = brick.UltrasonicDist(distPort);
    o = orientation + 1;
    if( o == 5 )
        o = 1;
    end
    if( distance(2) < squareDist )
        updateData(o);
    end
    % Left dist
    brick.MoveMotorAngleAbs(distMotor, distSpeed, -90, 'Brake');
    brick.WaitForMotor(distMotor);
    distance(3) = brick.UltrasonicDist(distPort);
    o = orientation - 1;
    if( o == 0 )
        o = 4;
    end
    if( distance(3) < squareDist )
        updateData(o);
    end
    brick.MoveMotorAngleAbs(distMotor, distSpeed, 0, 'Brake');
    brick.WaitForMotor(distMotor);
    brick.StopMotor(distMotor,'Coast');
    global autoOffset;
    disp(distance);
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

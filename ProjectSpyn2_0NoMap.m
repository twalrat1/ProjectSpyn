%%%%% ProjectSpyn %%%%%
% Version 2.0
% ASU FSE100 Section: 16722
% Spring 2022
% Adam Colyar, Aryan Hiteshkumar, Rishikumar Senthilvel, Trevor Walrath

%%% Global Variables %%% 
%%
global colorSize;   colorSize = 3;
global color;       color = ones(1,colorSize);
global colorAvg;    colorAvg = mode(color);
global colorIx;     colorIx = 1;
global liftAngle;   liftAngle = 20;
global turn90Angle; turn90Angle = 175;
global turn45Angle; turn45Angle = 75;
global distSpeed;   distSpeed = 30;
global distance;    distance = zeros(1,3);
global blueFound;   blueFound = 0;
global greenFound;  greenFound = 0;
global pickedUp;    pickedUp = 0;
global droppedOff;  droppedOff = 0;
global squareDist;  squareDist = 57;
global moveTime;    moveTime = 8;
global turnTime;    turnTime = 10;
global mapDist;     mapDist = 100;
global orientation; orientation = 1;  % 1-North 2-South 3-East 4-West
global pos;         pos = [0,0];
global autoOffset;  autoOffset = 2;
global robotSq;     robotSq = 0;
global angleRate;   angleRate = 0;
global adjSpeed;    adjSpeed = 15;
global backupSpeed; backupSpeed = 50;
global turnSpeedC;  turnSpeedC = 15;
global count;       count = 0;

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
%%
%%% Local variables for AutoNav and ManNav functions %%%
autoSpeed = 78;
autoTurn = 31;
manSpeed = 15;
wheelOffset = 2;
turnSpeed = 15;
liftSpeed = 5;
colorMode = 2;

% TODO:
% Variables to store map information
% AutoNav Function- gatherData, buildMap, searchMap, chooseNextMove,
%   makeNextMove

%%% Begin Main Program %%%
brick.SetColorMode(colorPort,colorMode);

%Setup gryoscope
brick.GyroCalibrate(2);
ang = brick.GyroAngle(2);

while( ~(ang >= 0 || ang < 0) )
    pause(1);
    ang = brick.GyroAngle(2);
end

%Main Code-------------------%

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

%-----------------------------%
%%

function AutoNav(brick,speed,turnSpeed,exitColor)
    global colorAvg;
    exitCode = 0;
      
    while exitCode ~= 1 % Loop until exit condition- based on color code
        % Gather distances store in array

        getDistance(brick); 
        if( colorAvg == exitColor )
            exitCode = 1;
            break;
        end
        correctDistance(brick);
        correctAngle(brick); 

        getCorrection(brick);
        
        % Decide next action- forward left right
        % 1-MoveForward 2-TurnLeft 3-TurnRight 4-TurnAround
        disp('make decision');
        decision = makeDecision(brick, turnSpeed);
        % execute action- check colors
        disp(decision);
        disp('execute decision');
        
        exitCode = execute(brick,decision,exitColor,speed,turnSpeed);
        
    end
    return
end

function correctAngle(brick)
    global wheelMotors;
    relAngle = brick.GyroAngle(2);
    errAng = abs(relAngle) - 90;
    while abs(errAng) <= 1
        if( errAng > 0 )
            turn(brick,-10);
        else
            turn(brick,10);
        end
        pause(0.1);
        brick.StopMotor(wheelMotors,'Coast');
        relAngle = brick.GyroAngle(2);
        errAng = abs(relAngle) - 90;
    end
end

function correctDistance(brick)
    global leftMotor rightMotor adjSpeed distance squareDist wheelMotors backupSpeed;
    
    %call this function after taking distances but before decisionMaking

    if(distance(1) < 23) %If too close to wall infront, move backwards slightly 
        brick.MoveMotor(leftMotor, -1*backupSpeed);
        brick.MoveMotor(rightMotor, -1*backupSpeed);
        pause(0.4);
        brick.StopMotor(wheelMotors);
        correctAngle(brick);
        
        getDistance(brick);
        
        disp("A1");
    end
    
    if(distance(1) > 50 && distance(1) < squareDist+10) %If too far from wall infront, move forwards slightly
        brick.MoveMotor(leftMotor, adjSpeed);
        brick.MoveMotor(rightMotor, adjSpeed);
        pause(0.7);
        brick.StopMotor(wheelMotors);
        correctAngle(brick);
        
        disp("A2");
    end   
end

function decision = makeDecision(brick, speed)
    global distance squareDist orientation autoOffset;
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
            if (distance(2) < 17)
                turn45(brick, -1*speed);
                disp("Right too close");
            end
            if (distance(3) < 8)
                turn45(brick, speed);
                disp("Left too close");
            end
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
                if( distance(2) + distance(3) < squareDist + 10 && distance(2) + distance(3) > squareDist - 10)
                    decision = 4;
                    orientation = orientation + 2;
                    autoOffset = 2;
                    if( orientation == 5 )
                        orientation = 1;
                    elseif( orientation == 6 )
                        orientation = 2;
                    end
                    return
                else
                    decision = 3;
                end
                return
            end
            
        end
    end
end

function code = execute(brick,decision,exitColor,speed,turnSpeed)
    global color colorPort colorSize colorIx distance squareDist moveTime;
    global wheelMotors autoOffset;
    global RED GREEN BLUE blueFound greenFound BlueSq GreenSq pos;
    code = 0;
    
    disp('execution');
    disp(decision);
    switch decision
        case 1
            % Move Forward- do nothing here
            checkStuck(brick,decision,speed)
        case 2
            % turnLeft
            turn90(brick,-1*turnSpeed);
            checkStuck(brick,decision,speed)
        case 3
            % turnRight
            turn90(brick,turnSpeed);
            checkStuck(brick,decision,speed)
        case 4
            % turnAround = turnRight x2
            turn90(brick,turnSpeed);
            turn90(brick,turnSpeed);
            checkStuck(brick,decision,speed)
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

    while timer < moveTime %(distance(1) > targetDist)% || timer < moveTime %loop to move desired distance
        getCorrection(brick);
        move(brick,speed,autoOffset);
        % Update color array as car is moving
        disp(autoOffset);
        colorIx = colorIx + 1;
        if( colorIx == (colorSize+1) )
            colorIx = 1; % keep index within bounds >=1 & <=3
        end
        color(colorIx) = brick.ColorCode(colorPort);
        colorAvg = mode(color);
        % check for Stop Sign
        if color(colorIx) == RED % 5 = Red
            %brick.StopMotor(wheelMotors,'Brake');
            brick.StopMotor(wheelMotors,'Coast');
            pause(1);
            move(brick,speed,autoOffset);
            color = ones(colorSize);
            rectangle('Position',[pos(1)+15 pos(2)+15 70 70],'FaceColor','r','LineStyle',':');
        end
        % Check if blue square is found
        if (colorAvg == BLUE) & (blueFound == 0)
            blueFound = 1;
            BlueSq = rectangle('Position',[pos(1)+15 pos(2)+15 70 70],'FaceColor','b','LineStyle',':');
        end
        % Check if green square is found
        if (colorAvg == GREEN) & (greenFound == 0)
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
%         distance(1) = brick.UltrasonicDist(distPort);
%         disp(distance(1));
    end
    %brick.StopMotor(wheelMotors,'Brake');
    brick.StopMotor(wheelMotors,'Coast');
    return;
end

function checkStuck(brick,decision,speed)
    global count autoOffset;

    if(decision == 1)
        count = count + 1;
    else
        count = 0;
    end
    if(count > 4)
        move(brick,-1*speed,autoOffset)
    end
end

function getCorrection(brick)
    global distPort distance autoOffset squareDist;
    pre = distance(2);
    cur = brick.UltrasonicDist(distPort);
    err = cur - pre;
    distance(2) = cur;
    if(distance(2) < squareDist)
%         if( err < -.1 && autoOffset >= 1 && autoOffset <= 3)
%             autoOffset = autoOffset - 2;
        if (err < -.1)
            autoOffset = autoOffset - 2;
        end
%         if( err > .1 && autoOffset >= 1 && autoOffset <= 3)
%                 autoOffset = autoOffset + 2;
        if ( err > .1)
            autoOffset = autoOffset + 2;
        end
        if(autoOffset >= 5)
            autoOffset = 5;
        end
        if(autoOffset <= -1)
            autoOffset = -1;
        end
    end
end

function turn90(brick,speed)
    global rightMotor leftMotor turn90Angle wheelMotors;

    brick.ResetMotorAngle(leftMotor);
    brick.MoveMotorAngleAbs(leftMotor,speed,turn90Angle,'Brake');
    brick.WaitForMotor(leftMotor);
    brick.ResetMotorAngle(rightMotor);
    brick.MoveMotorAngleAbs(rightMotor,-1*speed,turn90Angle,'Brake');
    brick.WaitForMotor(rightMotor);
    brick.StopMotor(wheelMotors,'Coast');
    correctAngle(brick);
end

function turn45(brick,speed)
    global rightMotor leftMotor turn45Angle wheelMotors;
    
    brick.ResetMotorAngle(leftMotor);
    brick.MoveMotorAngleAbs(leftMotor,speed,turn45Angle,'Brake');
    brick.WaitForMotor(leftMotor);
    brick.ResetMotorAngle(rightMotor);
    brick.MoveMotorAngleAbs(rightMotor,-1*speed,turn45Angle,'Brake');
    brick.WaitForMotor(rightMotor);
    brick.StopMotor(wheelMotors,'Coast');
    correctAngle(brick);
end

function getDistance(brick)
    global distPort distMotor distSpeed distance orientation squareDist;
    global color colorPort colorAvg;
    % Right dist
    color(1) = brick.ColorCode(colorPort);
    brick.GyroCalibrate(2);
    brick.ResetMotorAngle(distMotor);
    distance(2) = brick.UltrasonicDist(distPort);
    o = orientation + 1;
    if( o == 5 )
        o = 1;
    end
    if( distance(2) < squareDist )
        updateData(o);
    end
    % Forward dist
    color(2) = brick.ColorCode(colorPort);
    brick.MoveMotorAngleAbs(distMotor, distSpeed, -90, 'Brake');
    brick.WaitForMotor(distMotor);
    distance(1) = brick.UltrasonicDist(distPort);
    if( distance(1) < squareDist )
        updateData(orientation);
    end
    
    % Left dist
    color(3) = brick.ColorCode(colorPort);
    brick.MoveMotorAngleAbs(distMotor, distSpeed, -180, 'Brake');
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

    disp(distance);
    colorAvg = mode(color);
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

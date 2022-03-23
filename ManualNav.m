%%%%  Sensor Ports  %%%%%
%A is left
%B is right
%1 is distance sensor
%4 is gyro
turnSpeed = 15;
moveSpeedMan = 15;
moveSpeedAuto = 40;
colorP = 4;
colorM = 2;

global key

InitKeyboard();
brick.SetColorMode(colorP,colorM);

while 1
    color = brick.ColorCode(colorP);
    switch color
        case 5 % Red
            stop(brick);
            pause(5);
            disp('Red');
        case 4 % Yellow
            stop(brick);
            pause(3);
            disp('Yellow');
        case 3 % Green
            stop(brick);
            pause(3);
            disp('Green');
        case 2 % Blue
            stop(brick);
            pause(3);
            disp('Blue');
        otherwise
            disp(color);
    end
    pause(0.1);
    switch key
        case 'uparrow'
%            disp('up arrow');
            moveForward(brick,moveSpeedAuto);
        case 'downarrow'
%            disp('down arrow');
            moveBackward(brick,moveSpeedAuto);
        case 'leftarrow'
%            disp('left arrow');
            turnLeft(brick,turnSpeed);
        case 'rightarrow'
%            disp('right arrow');
            turnRight(brick,turnSpeed);
        case 's'
%            disp('full stop');
            brick.StopAllMotors('Coast');
        case 'l'
%            disp('lift up');
            brick.ResetMotorAngle('C');
            brick.MoveMotorAngleRel('C', 10, 45, 'Brake');
            brick.WaitForMotor('C');
            pause(1);
        case 'd'
%            disp('lift down');
            brick.ResetMotorAngle('C');
            brick.MoveMotorAngleRel('C', -10, 45, 'Brake');
            brick.WaitForMotor('C');
            pause(1);
        case 0
%            disp('0');
            brick.StopAllMotors('Coast');
        case 'q'
            brick.StopAllMotors('Coast');
            break;
    end
    
end
CloseKeyboard();


function moveForward(brick,speed)
    brick.MoveMotor('A', speed);
    brick.MoveMotor('B', speed);
return;
end


function moveBackward(brick,speed)
    brick.MoveMotor('A', -1*speed);
    brick.MoveMotor('B', -1*speed);
return;
end

function turnLeft(brick,speed)
    brick.MoveMotor('A', -1*speed);
    brick.MoveMotor('B', speed);
return;
end

function turnRight(brick,speed)
    brick.MoveMotor('A', speed);
    brick.MoveMotor('B', -1*speed);
return;
end

function stop(brick)
    brick.StopMotor('A');
    brick.StopMotor('B');
return;
end
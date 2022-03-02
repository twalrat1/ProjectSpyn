%%%%  Sensor Ports  %%%%%
%A is left
%B is right
%1 is distance sensor
%4 is gyro

global key
InitKeyboard();

while 1
    isMoving = 0;
    pause(0.1);
    switch key
        case 'uparrow'
            isMoving = moveForward(brick,isMoving);
        case 'downarrow'
            isMoving = moveBackward(brick,isMoving);
        case 'leftarrow'
            isMoving = turnLeft(brick,isMoving);
        case 'rightarrow'
            isMoving = turnRight(brick,isMoving);
        case 's'
            brick.StopAllMotors('Coast');
        case 'l'
            brick.ResetMotorAngle('C');
            brick.MoveMotorAngleRel('C', 10, 45, 'Brake');
            pause(1);
        case 'd'
            brick.ResetMotorAngle('C');
            brick.MoveMotorAngleRel('C', -10, 45, 'Brake');
            pause(1);
        case 0
            brick.StopAllMotors('Coast');
        case 'q'
            break;
    end
end
CloseKeyboard();


function m = moveForward(brick,isMoving)
if( isMoving == 0 )
    isMoving = 1;
    brick.MoveMotor('A', 10);
    brick.MoveMotor('B',10);
end
m = 1;
return;
end


function m = moveBackward(brick,isMoving)
if( isMoving == 0 )
    isMoving = 1;
    brick.MoveMotor('A', -10);
    brick.MoveMotor('B', -10);
end
m = 1;
return;
end

function m = turnLeft(brick,isMoving)
if( isMoving == 0 )
    isMoving = 1;
    brick.MoveMotor('A', -10);
    brick.MoveMotor('B', 10);
end
m = 1;
return;
end

function m = turnRight(brick,isMoving)
if( isMoving == 0 )
    isMoving = 1;
    brick.MoveMotor('A', 10);
    brick.MoveMotor('B', -10);
end
m = 1;
return;
end

function m = stop(brick, isMoving)
if( isMoving == 1 )
    isMoving = 0;
    brick.StopMotor('A');
    brick.StopMotor('B');
end
m = 0;
return;
end
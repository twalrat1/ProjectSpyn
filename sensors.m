%%% Sensors %%%
colorPort = 2;
colorMode = 2;
distPort = 1;
motorPort = 'D';

brick.ResetMotorAngle(motorPort);
distance = getDistances(brick, distPort, motorPort, 10);
disp(distance);

brick.StopAllMotors('Coast');

function [dist] = getDistances(brick,distPort,motorPort, motorSpeed)
    brick.ResetMotorAngle(motorPort);
    dist(1) = brick.UltrasonicDist(distPort);
    disp(dist);
    brick.MoveMotorAngleAbs(motorPort, motorSpeed, 90, 'Brake');
    brick.WaitForMotor(motorPort);
    dist(2) = brick.UltrasonicDist(distPort);
    disp(dist)
    brick.MoveMotorAngleAbs(motorPort, motorSpeed, 180, 'Brake');
    brick.WaitForMotor(motorPort);
    dist(3) = brick.UltrasonicDist(distPort);
    disp(dist);
    brick.MoveMotorAngleRel(motorPort, motorSpeed, -270, 'Brake');
    brick.WaitForMotor(motorPort);
    dist(4) = brick.UltrasonicDist(distPort);
    disp(dist);
    brick.MoveMotorAngleAbs(motorPort, motorSpeed, 0, 'Brake');
    brick.WaitForMotor(motorPort);
end
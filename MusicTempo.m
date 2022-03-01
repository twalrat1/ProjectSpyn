display('PUSH button to start timer');
while brick.TouchPressed(1) == 0
%waiting
end
timeCount = 0;
display('RELEASE button to stop timer');
while brick.TouchPressed(1) == 1 
    timeCount = timeCount + 1;
%    pause(.3);
end
display(timeCount);
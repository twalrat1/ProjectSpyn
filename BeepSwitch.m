display('PUSH button to start the tone');
while brick.TouchPressed(1) == 0
%waiting
end
display('RELEASE button to turn tone OFF');
while brick.TouchPressed(1) == 1
    % Play tone with frequency 300Hz and duration of 500ms.
    brick.playTone(100, 300, 500);
    pause(.49)
end
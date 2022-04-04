brick = ConnectBrick('HAROLD');
% Play tone with frequency 440Hz and duration of 500ms.
brick.playTone(100, 440, 500);
% Get current battery level.
v = brick.GetBattVoltage()

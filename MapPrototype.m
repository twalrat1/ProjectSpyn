%temp values for testing, distance will be fed through D1,D2,D3,D4 where 1,2,3,4 designate the cardinal direction
posCheck = 0;
dist = 100;
dir = 4;
pos = [0,0];

% generateDir(dist, pos)
createMap()
if posCheck == 0
    [pos, posCheck] = setStart();
else
    findpos()
end
%while running
% createColorSquare();
updateData(dist, pos, dir)
%end

%initalizing the map, 1000x1200 is equivalent to four 5x6 pieced together
function createMap()
hold on

xlim([0,1000]);
ylim([0,1200]);
p = plot(xlim,ylim,'linestyle','none');
axis equal;
grid on
end

function findPos()
    rectangle('Position',[pos(1)+25 pos(2)+25 25 25]);
%in progress
    %pos = [pos(1) + dist, pos(2) + dist]
%In main code, set dir to 1-4 during the distancing reading
    %updateData(dist, pos, dir)
    refreshdata
    drawnow
end

% function createColorSquare()
%     rectangle('Position',[pos(1)+25 pos(2)+25 25 25]);
%     refreshdata
%     drawnow
% end

function [pos, posCheck] = setStart()
    pos = [400,600];
    posCheck = 1;
    rectangle('Position',[pos(1)+37 pos(2)+30 25 25]);
    refreshdata
    drawnow
end

function updateData(dist, pos, dir) %Update the map/figure with a new wall based off incoming distance reading

    p.XDataSource = 'x2';
    p.YDataSource = 'y2';

    %Direction should be 1,2,3,4 for north, south, east, or west
  switch dir
    case 1
        x2 = [pos(1), pos(1) + dist];
        y2 = [pos(2)+dist, pos(2) + dist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        %disp("north")

    case 2
        x2 = [pos(1), pos(1) + dist];
        y2 = [pos(2), pos(2)];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        %disp("south")

    case 3
        x2 = [pos(1), pos(1)];
        y2 = [pos(2), pos(2)+dist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        %disp("east")

    case 4
        x2 = [pos(1) + dist, pos(1) + dist];
        y2 = [pos(2), pos(2) + dist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        %disp("west")    

    case 0
        disp("Fail")

  end

    refreshdata
    drawnow
end

%temp values for testing, distance will be fed through D1,D2,D3,D4 where 1,2,3,4 designate the cardinal direction
posx = 0;
x1 = 0;
y1 = 0;
dist = 100;
pos = [x1,y1];

%initalizing the map, 1000x1200 is equivalent to 4 5x6 piecedd together
hold on

xlim([0,1000]);
ylim([0,1200]);
p = plot(xlim,ylim,'linestyle','none');
axis equal;
grid on

generateDir(dist, pos)
findPos(posx)

function findPos(posx, pos)
    switch posx
        case 0
            setStart(pos)
            posx = 1;
        case 1
    end
end

function setStart(pos)
%generate 4 lines at center of plot for visual data, setPos to one data point for computation
end

function generateDir(dist, pos) %placeholder code to generate random #s for testing 4 different directions 
        a = 1;
        b = 4;
        count = 0;

        dir = a + (b-a).*rand(1);
        dir = round(dir,0);
        disp(dir);

        count = count + 1;

    updateData(dist, pos, dir, count);
end

function updateData(dist, pos, dir, count) %Update the map/figure with a new wall based off incoming distance reading

    p.XDataSource = 'x2';
    p.YDataSource = 'y2';

while count >= 1
    %Dir should be 1,2,3,4 for north, south, east, or west
  switch dir
    case 1
        x2 = pos + [dist, 0];
        y2 = pos + [dist,dist];
        line(x2,y2,'linestyle','-','Color','r');
        refreshdata
        drawnow
    
        disp("north")
        count = count - 1;

    case 2
        x2 = pos + [0, dist];
        y2 = pos + [0,0];
        line(x2,y2,'linestyle','-','Color','b');
        refreshdata
        drawnow
    
        disp("south")
        count = count - 1;

    case 3
        x2 = pos + [dist, dist];
        y2 = pos + [dist,0];
        line(x2,y2,'linestyle','-','Color','g');
        refreshdata
        drawnow
    
        disp("east")
        count = count - 1;

    case 4
        x2 = pos + [0, 0];
        y2 = pos + [0,dist];
        line(x2,y2,'linestyle','-','Color','y');
        refreshdata
        drawnow
    
        disp("west")
        count = count - 1;    

    case 0
        disp("Fail")

        count = count - 1;
  end

    refreshdata
    drawnow
end
end

function result = CircleDiff(dir1, dir2)
%result = CircleDiff(dir1, dir2)
angleInDeg = acosd(cosd(dir1).*cosd(dir2)+sind(dir1).*sind(dir2));

dir1Crossdir2 = cosd(dir1).*sind(dir2) - cosd(dir2).*sind(dir1);


result = -angleInDeg;
result(dir1Crossdir2<=0) = angleInDeg(dir1Crossdir2<=0);

result = (round(result*100000))/100000;
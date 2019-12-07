function [points]= rotate_points(points, theta, pivot)
% rotate a series of points (all in matrix points) around a pivot point by
% the angle theta

rot_mat=[cos(theta) -sin(theta); sin(theta) cos(theta)];
                 
for i=1:length(points(:,1));
points(i,:)=(points(i,:)-pivot)*rot_mat+pivot;       
end

end
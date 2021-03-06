clear; close all;

% Initialization
branch_length = 5; % step_size

region_radius = 8;

% Initital point of the tree
root = [5,5];
target = [240,140];

% Tree has only the root initially
Tree(1).node = 	root;
Tree(1).branches = [];
Tree(1).costToCome = 0;

% Develop the image for the GUI
image = getmap();

figure, imshow(image,'InitialMagnification','fit'); hold on
set(gca,'Ydir','Normal') % Invert the Y axis to match the matrix arguments

distance_to_target = branch_length + 1;

% Start of the searching Algorithm
disp("Searching:")
count = 0;
while((distance_to_target > branch_length) || hasObstacle(target, Xnew) || count < 2000)
    count = count + 1;
    disp(count)
    Xrand = get_random_point(250, 150);
    Xnearest = find_nearest(Xrand, Tree);
    Xnew = new_node(Xnearest, Xrand, branch_length);
    if (sum(isnan(Xnew)))
        continue
    end
    neighbourhood = get_neighbourhood(Tree, Xnew, region_radius);
    [Xnear, position] = get_best_parent(Tree, neighbourhood);
    
    % Add node if obstacle not in between
    if(~hasObstacle([floor(Xnear(1)),floor(Xnear(2))], [floor(Xnew(1)),floor(Xnew(2))]))
        current_no_of_nodes = size(Tree,2);
        % Add new node
        Tree(current_no_of_nodes+1).node = Xnew;
        Tree(current_no_of_nodes+1).costToCome = Tree(position).costToCome + norm(Xnear - Xnew);
        
        % Add child location in parent node
        Tree(position).branches = cat(2, Tree(position).branches, current_no_of_nodes+1);
        
        % check if close to target
        distance_to_target = norm(Xnew - target);
        disp(distance_to_target)
        
        % Rewiring
        for cc = 1:size(neighbourhood,2)
            if((Tree(current_no_of_nodes+1).costToCome + norm(Tree(neighbourhood(cc)).node - Xnew)) < Tree(neighbourhood(cc)).costToCome)
                % If cost from new node is cheaper switch parents
                location = findParent(Tree, neighbourhood(cc));
                Tree(location).branches= Tree(location).branches(Tree(location).branches~=neighbourhood(cc));
                Tree(current_no_of_nodes+1).branches = cat(2, Tree(current_no_of_nodes+1).branches, neighbourhood(cc));
            end
        end
        
    end
end

% Adding the target Node to the tree
current_no_of_nodes = size(Tree,2);
% Add new node
Tree(current_no_of_nodes+1).node = target;
Tree(current_no_of_nodes+1).costToCome = Tree(current_no_of_nodes).costToCome + norm(target - Xnew);

% Add child location in parent node
Tree(current_no_of_nodes).branches = cat(2, Tree(current_no_of_nodes).branches, current_no_of_nodes+1);

% Plot start point and target point

plot(root(1),root(2),'Marker','.','Color','g','MarkerSize', 20);
plot(target(1),target(2),'Marker','.','Color','r','MarkerSize', 20);

% Plot the tree
queue = 1;
while (size(queue,2) ~= 0)
    for jj = 1:size(Tree(queue(1)).branches, 2)
        point1 = Tree(queue(1)).node;
        point2 = Tree(Tree(queue(1)).branches(jj)).node;
        
        plot([point1(1),point2(1)],[point1(2),point2(2)] , 'Color', 'b');
        drawnow limitrate
    end
    
    queue = cat(2, queue, Tree(queue(1)).branches);
    queue = queue(2:end);
end

% Track the optimal path
node_number = current_no_of_nodes + 1;
current_node = target;
path_point1=[];
path_point2=[];
while(~isequal(root, current_node))
    path_point1 = cat(2, path_point1, current_node(1));
    path_point2 = cat(2, path_point2, current_node(2));
    
    node_number = findParent(Tree, node_number);
    current_node = Tree(node_number).node;
end

plot(path_point1, path_point2, 'Color', 'r');

legend({'Initial Node', 'Goal Node'});
legend('Location', 'bestoutside');
hold off
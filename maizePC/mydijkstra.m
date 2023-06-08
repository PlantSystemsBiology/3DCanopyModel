

% 2022-5-5
% code is original from public, provided by Fusang Liu, QF not modified.
% dijkstra Algorithm

function [mydistance,mypath] = mydijkstra(a,sb,db) % sb: base point index, db: tip point index
% if sb==0 || db==0
%     mydistance=0;
%     mypath=[];
% else

n=size(a,1); visited(1:n) = 0;
% disp('size of the leaf points: ')


distance(1:n) = inf; distance(sb) = 0;
visited(sb)=1; 
u=sb;
parent(1:n) = 0;

for i = 1: n-1 % 重复n-1次
    id=find(visited==0); %当前没有访问过的点
    for v = id %便利每个未访问过的点
        if  a(u, v) + distance(u) < distance(v)
            distance(v) = distance(u) + a(u, v);
            parent(v) = u;
        end
    end
    temp=distance;
    temp(visited==1)=inf;
    [t, u] = min(temp);
    visited(u) = 1;
end
mypath = [];
if parent(db) ~= 0
    t = db; mypath = [db];
    while t ~= sb
        p = parent(t);
        mypath = [p mypath];
        t = p;
    end
end
mydistance = distance(db);
% end
end

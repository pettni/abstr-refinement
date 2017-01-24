% clear; load('output/data_radiant.mat')

figure(1)
clf; hold on

% Assume winning set is a square
win_min = [Inf Inf Inf];
win_max = [-Inf -Inf -Inf];
for rec = part(Win)
	win_max = max(win_max, rec.xmax);
	win_min = min(win_min, rec.xmin);
end

lims = [part.domain.xmin; part.domain.xmax];
xlim([win_min(1), win_max(1)]);
ylim([win_min(2), win_max(2)]);
zlim([win_min(3), win_max(3)]);
view([-82, 15])
winrec = Rec([win_min' win_max']);

plot(intersect(goal_set, winrec), 'green', 0.6);
axis off
plot(winrec, 'black', 0.05, 0);

for i=1:length(xvec_list)

	xvec = xvec_list{i};
	avec = avec_list{i};
	tvec = (1:size(xvec, 2)) * dt/3600;

	ptr0 = 1;
	ptr1 = 1;
	a = avec(ptr0);

	while tvec(ptr1) <= 0.25
		
		if avec(ptr1) ~= a

			clr = [a==1 0 a==2];
			plot3(xvec(1, floor(linspace(ptr0, ptr1, 10))), ...
				  xvec(2, floor(linspace(ptr0, ptr1, 10))), ...
				  xvec(3, floor(linspace(ptr0, ptr1, 10))), ...
				  'color', clr)
			ptr0 = ptr1;

			a = avec(ptr0);
		else
			ptr1 = ptr1 + 1;
		end

	end

	plot3(xvec(1,1), xvec(2,1), xvec(3,1), 'o', 'color', 'black');
end

matlab2tikz('output/radiant_3d.tex','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

xvec = xvec_list{1};
avec = avec_list{1};

figure(2)
clf; hold on
ylim([20, 27])

plotidx = 1:floor(length(tvec)/500):length(tvec);
plot(tvec(plotidx), xvec(1, plotidx), 'color', 'green', 'linewidth', 1.25)
plot(tvec(plotidx), xvec(2, plotidx), 'color', 'blue', 'linewidth', 1.25)
plot(tvec(plotidx), xvec(3, plotidx), 'color', 'red', 'linewidth', 1.25)
% plot([tvec(1) tvec(end)], [22 22], '--', 'color', 'green', 'linewidth', 1.25)
% plot([tvec(1) tvec(end)], [25 25], '--', 'color', 'green', 'linewidth', 1.25)
legend('$T_C$', '$T_1$', '$T_2$')

ylabel('Temperature [$^\circ$C]')
xlabel('Time $t$ [hrs]')

switches = find(avec(2:end) ~= avec(1:end-1));

plot(tvec(switches), 21 * ones(length(switches)), '.', 'color', 'black', 'markersize', 1.5)

matlab2tikz('output/radiant_temp.tex','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left')

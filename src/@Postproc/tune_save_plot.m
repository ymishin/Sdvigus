function tune_save_plot(obj, name, desc)
% Tune and save the plot.
%
% $Id$

% useful variables
model = obj.model_name;
time = obj.current_time;
stime = num2str(time);
nstep = obj.nstep;
snstep = num2str(nstep, '%05d');
outdir = obj.outdir;

% execute custom functions
if (isfield(desc,'custom_funcs'))
    custom_funcs = desc.custom_funcs;
    for i = 1:length(custom_funcs)
        custom_funcs{i}();
    end
end

% tune the plot
box on;
axis xy equal;
if (isfield(desc,'domain') && ~isempty(desc.domain))
    axis(desc.domain);
else
    axis(obj.domain.size);
end
if (isfield(desc,'cmap') && ~isempty(desc.cmap))
    colormap(desc.cmap);
end
if (isfield(desc,'clim') && ~isempty(desc.clim))
    caxis(desc.clim);
end
if (isfield(desc,'fsize') && ~isempty(desc.fsize))
    set(gca,'FontSize',desc.fsize);
end
if (isfield(desc,'title') && ~isempty(desc.title))
    title(eval(desc.title));
elseif (isfield(desc,'titlet') && ~isempty(desc.titlet))
    title(eval(desc.titlet),'interpreter','latex');
end
if (isfield(desc,'xlabel') && ~isempty(desc.xlabel))
    xlabel(eval(desc.xlabel));
elseif (isfield(desc,'xlabelt') && ~isempty(desc.xlabelt))
    xlabel(eval(desc.xlabelt),'interpreter','latex');
end
if (isfield(desc,'ylabel') && ~isempty(desc.ylabel))
    ylabel(eval(desc.ylabel));
elseif (isfield(desc,'ylabelt') && ~isempty(desc.ylabelt))
    ylabel(eval(desc.ylabelt),'interpreter','latex');
end
if (isfield(desc,'xtick') && ~isempty(desc.xtick))
    set(gca,'XTick',desc.xtick);
end
if (isfield(desc,'ytick') && ~isempty(desc.ytick))
    set(gca,'YTick',desc.ytick);
end
if (isfield(desc,'xticklabel') && ~isempty(desc.xticklabel))
    set(gca,'XTickLabel',desc.xticklabel);
end
if (isfield(desc,'yticklabel') && ~isempty(desc.yticklabel))
    set(gca,'YTickLabel',desc.yticklabel);
end
if (isfield(desc,'ticklenf') && ~isempty(desc.ticklenf))
    set(gca,'TickLength',desc.ticklenf*get(gca,'TickLength'))
end
if (isfield(desc,'tickdir') && ~isempty(desc.tickdir))
    set(gca,'TickDir',desc.tickdir);
end
if (isfield(desc,'awidth') && ~isempty(desc.awidth))
    set(gca,'LineWidth',desc.awidth);
end
set(gca,'Layer','top');

% add the colorbar
if (isfield(desc,'colorbar') && ~isempty(desc.colorbar))
    cbar = desc.colorbar;
    if (isfield(cbar,'plot') && ~isempty(cbar.plot) && cbar.plot)
        if (isfield(cbar,'loc') && ~isempty(cbar.loc))
            hcb = colorbar(cbar.loc);
        else
            hcb = colorbar;
        end
        if (isfield(cbar,'fsize') && ~isempty(cbar.fsize))
            set(hcb,'FontSize',cbar.fsize);
        end
        if (isfield(cbar,'tick') && ~isempty(cbar.tick))
            set(hcb,'XTick',cbar.tick);
            set(hcb,'YTick',cbar.tick);
        end
        if (isfield(cbar,'ticklabel') && ~isempty(cbar.ticklabel))
            set(hcb,'XTickLabel',cbar.ticklabel);
            set(hcb,'YTickLabel',cbar.ticklabel);
        end
        if (isfield(cbar,'ticklenf') && ~isempty(cbar.ticklenf))
            set(hcb,'TickLength',cbar.ticklenf*get(gca,'TickLength'))
        end
        if (isfield(cbar,'tickdir') && ~isempty(cbar.tickdir))
            set(hcb,'TickDir',cbar.tickdir);
        end
        if (isfield(cbar,'awidth') && ~isempty(cbar.awidth))
            set(hcb,'LineWidth',cbar.awidth);
        end
    end
end

% save the plot
if (isfield(desc,'fname') && ~isempty(desc.fname))
    fname = eval(desc.fname);
else
    fname = [model, '_', name, '_', snstep];
end
if (isfield(desc,'rend') && ~isempty(desc.rend))
    rend = ['-', desc.rend];
else
    rend = '-zbuffer';
end
if (isfield(desc,'fmt') && ~isempty(desc.fmt))
    fmt = ['-d', desc.fmt];
else
    fmt = '-djpeg';
end
if (isfield(desc,'dpi') && ~isempty(desc.dpi) )
    rdpi = ['-r', num2str(desc.dpi)];
else
    rdpi = '-r100';
end
print(rend, fmt, rdpi, [outdir, '/', fname]);

end
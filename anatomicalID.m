cfg            = [];
cfg.nonlinear  = 'yes';
cfg.spmversion = 'spm12';
cfg.spmmethod  = 'new';
fsmri_mni = ft_volumenormalise(cfg, fsmri_acpc);
%%
elec_mni_frv = tkrRAS;
elec_mni_frv.elecpos = ft_warp_apply(fsmri_mni.params, tkrRAS.elecpos, 'individual2sn');
elec_mni_frv.chanpos = ft_warp_apply(fsmri_mni.params, tkrRAS.chanpos, 'individual2sn');
elec_mni_frv.coordsys = 'mni';
%%
[ftver, ftpath] = ft_version;
load([ftpath filesep 'template/anatomy/surface_pial_left.mat']);
ft_plot_mesh(mesh);
ft_plot_sens(elec_mni_frv);
view([-90 20]);
material dull;
lighting gouraud;
camlight;


%%

atlas = ft_read_atlas('E:\Shares\Gershwin\Recon\2020\PY20N007_SW\Freesurfer\mri/aparc+aseg.mgz');
%%
atlas.coordsys = 'acpc';
cfg            = [];
cfg.roi        = tkrRAS.chanpos;
cfg.atlas      = atlas;
%cfg.coordsys = 'acpc';
cfg.output     = 'label';
labels = ft_volumelookup(cfg, atlas);
%%
for i=1:length(tkrRAS.label)
    if labels.count(i) ~= 0
        disp(strcat('Electrode:',' ', tkrRAS.label(i), labels.name(labels.count(i))))

    else
        disp(strcat('Electrode:',' ', tkrRAS.label(i), "Unknown"))
    end
%    strcat(labels.count(i))
    %disp(strcat('Electrode: ', tkrRAS.label(i), ' index: ', labels.count(i)))
end

%%
[a, ~] = find(labels.count);




%%
atlas = ft_read_atlas('E:\Shares\Gershwin\Recon\2020\PY20N007_SW\Freesurfer\mri/aparc+aseg.mgz');
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;

cfg.roi        = {'Left-Cerebral-White-Matter'};
%cfg.roi        = {'Left-Cerebral-Cortex','Right-Hippocampus', 'Right-Amygdala'};
mask_rha = ft_volumelookup(cfg, atlas);

seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha = ft_prepare_mesh(cfg, seg);
%%
    cfg             = [];
    cfg.output      = {'brain'};
    segmentation    = ft_volumesegment(cfg, fsmri_acpc);
    cfg             = [];
    cfg.tissue      = { 'brain'};
    cfg.numvertices = [800, 1600, 2400];
    mesh            = ft_prepare_mesh(cfg, segmentation);
    %%
figure;
ft_plot_mesh(mesh);
hold on
ft_plot_mesh(pial_lh);
view([-55 10]);
%material iso2mesh;
camlight;
hold on

ft_plot_sens(electrodes)

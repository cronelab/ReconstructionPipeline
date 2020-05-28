ft_defaults
mri = ft_read_mri('Pre/mri/T1.mgz'); % we used the dcm series

ft_determine_coordsys(mri);
%%
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'acpc';
mri_acpc = ft_volumerealign(cfg, mri);
%%
cfg           = [];
cfg.filename  = 'T1_acpc';
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_acpc);
%%
pial_lh = ft_read_headshape('Pre/surf/lh.pial');
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
lighting gouraud;
camlight;
%%
fsmri_acpc = ft_read_mri('Pre/mri/T1.mgz'); % on Windows, use 'SubjectUCI29_MR_acpc.nii'
%fsmri_acpc.coordsys
%%
ct = ft_read_mri('CT_LPS.nii');
ft_determine_coordsys(ct);
%%
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);
%%
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');
%%
cfg             = [];
cfg.method      = 'spm';
cfg.spmversion  = 'spm12';
cfg.coordsys    = 'acpc';
cfg.viewresult  = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
%%
cfg           = [];
cfg.filename  = 'CT_to_T1';
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);
%%
elec = bis2fieldtrip('Pre/CT/electrodes_orig.mgrid','CT_LPS.nii')
cfg = [];
cfg.elec = elec;
ft_electrodeplacement(cfg, fsmri_acpc);


%%
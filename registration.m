ft_defaults
templateMri = ft_read_mri('E:\4\Pre\Processed\T1.nii');
intraMRIToMove = ft_read_mri('E:\4\Intra\Raw\Ax_3D_POST_GAD.nii');
%%
cfg             = [];
cfg.method      = 'interactive';
cfg.spmversion  = 'spm12';
cfg.coordsys    = 'acpc';
cfg.viewresult  = 'yes';
movedMRI = ft_volumerealign(cfg, intraMRIToMove, templateMri);
%%
cfg             = [];
cfg.method      = 'spm';
cfg.spmversion  = 'spm12';
cfg.coordsys    = 'acpc';
cfg.viewresult  = 'yes';
movedMRI = ft_volumerealign(cfg, movedMRI, templateMri);
%%
cfg           = [];
cfg.filename  = 'E:\4\Intra\Processed\registeredT1.nii';
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, movedMRI);
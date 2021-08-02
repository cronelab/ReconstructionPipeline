
% Add Fieldtrip to path
addpath('fieldtrip-20210720')
% Initialize fieldtrip
ft_defaults
%Set your raw T1
[rawT1File,rawT1Path] = uigetfile('.nii.gz')
%Read in the raw T1
gunzip(strcat(rawT1Path,rawT1File));
mri = ft_read_mri(strcat(rawT1Path,replace(rawT1File,'.gz',''))); 
%Determine the coordinate system (RAS) and mark acpc line
ft_determine_coordsys(mri);
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'acpc';
mri_acpc = ft_volumerealign(cfg, mri);
%Save the acpc aligned T1
cfg           = [];
cfg.filename  = strcat(strcat(rawT1Path,replace(rawT1File,'.nii.gz','')),'_acpc');
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_acpc);
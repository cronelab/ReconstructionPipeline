% Add Fieldtrip to path
addpath('fieldtrip-20210720')
addpath('spm12')
% Initialize fieldtrip
ft_defaults
%Set your freesurfer processed T1
[fsT1File,fsT1Path] = uigetfile('.nii');
fsmri_acpc = ft_read_mri(strcat(fsT1Path,fsT1File));
fsmri_acpc.coordsys = 'acpc';
%%
% Read in the raw CT (or load the coregistered CT)
x = input('Coregister (y) or load coregistered CT (n)? ', 's')
if(x=='n')
    [acpcCTFile,acpcCTPath] = uigetfile('.nii');
    ct_acpc_f = ft_read_mri(strcat(acpcCTPath,acpcCTFile)); 
elseif(x=='y')
    [rawCTFile,rawCTPath] = uigetfile('.nii.gz');
    gunzip(strcat(rawCTPath,rawCTFile));
    ct = ft_read_mri(strcat(rawCTPath,replace(rawCTFile,'.gz',''))); 
    ct = ft_determine_coordsys(ct);

    % Mark the fiducials and align CT to ctf and then acpc
    cfg           = [];
    cfg.method    = 'interactive';
    cfg.coordsys  = 'ctf';
    ct_ctf = ft_volumerealign(cfg, ct);
    ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');
    %Coregistration
    cfg             = [];
    cfg.method      = 'spm';
    cfg.spmversion  = 'spm12';
    cfg.coordsys    = 'acpc';
    cfg.viewresult  = 'yes';
    ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
    %%
    cfg           = [];
    cfg.filename  = strcat(strcat(rawCTPath,replace(rawCTFile,'.nii.gz','')),'_acpc');
    cfg.filetype  = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, ct_acpc_f);
end

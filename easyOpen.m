% Initialize fieldtrip
ft_defaults
% Load fsmri_acpc, ct_acpc_f, and electrodes
subjID = 'PY20N007_SW';
rawPath = 'E:\Shares\Gershwin\Recon\2020\';
fsmri_acpc = ft_read_mri(strcat(rawPath,subjID,'\MR\preOp\T1_acpc_processed.nii'));
fsmri_acpc.coordsys = 'acpc';
ct_acpc_f = ft_read_mri(strcat(rawPath,subjID,'\CT\PY20N007_SW_CT_acpc_f.nii'));
load(strcat(rawPath,subjID,'\electrodes\RASelectrodes.mat'))
load(strcat(rawPath,subjID,'\electrodes\tkrRASelectrodes.mat'))

%%
%View the electrodes on the the t1
ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
ft_plot_sens(RASelectrodes, 'label', 'on', 'fontcolor', 'w');
%%
%View the electrodes on the pial surface
figure;
pial_lh = ft_read_headshape(strcat(rawPath,subjID,'/Freesurfer/surf/lh.pial'));
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
lighting gouraud;
camlight;
hold on
ft_plot_sens(tkrRAS)
%%

ft_defaults
% import the patient's electrodes
patientFolder = 'E:\Shares\Gershwin\Recon\PrePostSurgicalComparison\PY18N013\Pre\';
tkrRAS = importTSV(strcat(patientFolder,'electrodes\electrodes_tkrRAS.tsv'));
tkrRAS.name = erase(tkrRAS.name,"'");
RAS = importTSV(strcat(patientFolder,'electrodes\electrodes_RAS.tsv'));
RAS.name = erase(RAS.name,"'");

% Format the table data to match the fieldtrip electrode structure
tkrRAS_electrodes = {};
tkrRAS_electrodes.unit = 'mm';
tkrRAS_electrodes.label = tkrRAS.name;
tkrRAS_electrodes.elecpos = [tkrRAS.x, tkrRAS.y, tkrRAS.z];
tkrRAS_electrodes.chanpos = [tkrRAS.x, tkrRAS.y, tkrRAS.z];
tkrRAS_electrodes.tra = eye(length(tkrRAS.name));

RAS_electrodes = {};
RAS_electrodes.unit = 'mm';
RAS_electrodes.label = RAS.name;
RAS_electrodes.elecpos = [RAS.x, RAS.y, RAS.z];
RAS_electrodes.chanpos = [RAS.x, RAS.y, RAS.z];
RAS_electrodes.tra = eye(length(RAS.name));
clear tkrRAS RAS
%%
% import the freesurfer brain and CT
fsmri_acpc = ft_read_mri(strcat(patientFolder,'mri\T1.nii'));
fsmri_acpc.coordsys = 'acpc';
ct = ft_read_mri(strcat(patientFolder,'CT\CT_LIA.nii'));


%%
% Generate electrode coordinates in voxel-space
VOX_electrodes = tkrRAS_electrodes;
VOX_electrodes.chanpos =  ft_warp_apply(inv(fsmri_acpc.hdr.tkrvox2ras), tkrRAS_electrodes.chanpos);
VOX_electrodes.elecpos =  ft_warp_apply(inv(fsmri_acpc.hdr.tkrvox2ras), tkrRAS_electrodes.elecpos);
%%
MR_electrodes = RAS_electrodes;
MR_electrodes.chanpos =  ft_warp_apply(inv(ct.transform), RAS_electrodes.chanpos);
MR_electrodes.elecpos =  ft_warp_apply(inv(ct.transform), RAS_electrodes.chanpos);

MR_electrodes.chanpos =  ft_warp_apply(fsmri_acpc.transform, MR_electrodes.chanpos);
MR_electrodes.elecpos =  ft_warp_apply(fsmri_acpc.transform, MR_electrodes.elecpos);

%%
% Transform fsmri_acpc to fsmri_mni
cfg            = [];
cfg.nonlinear  = 'yes';
cfg.spmversion = 'spm12';
cfg.spmmethod  = 'new';
fsmri_mni = ft_volumenormalise(cfg, fsmri_acpc);

MNI_electrodes = MR_electrodes;
MNI_electrodes.elecpos = ft_warp_apply(fsmri_mni.params, MR_electrodes.elecpos, 'individual2sn');
MNI_electrodes.chanpos = ft_warp_apply(fsmri_mni.params, MR_electrodes.chanpos, 'individual2sn');
MNI_electrodes.coordsys = 'mni';

%%
exportTSV(RAS_electrodes, strcat(patientFolder, 'electrodes/RAS_electrodes.tsv'));
exportTSV(tkrRAS_electrodes, strcat(patientFolder, 'electrodes/tkrRAS_electrodes.tsv'));
exportTSV(VOX_electrodes, strcat(patientFolder, 'electrodes/VOX_electrodes.tsv'));
exportTSV(MR_electrodes, strcat(patientFolder, 'electrodes/MR_electrodes.tsv'));
exportTSV(MNI_electrodes, strcat(patientFolder, 'electrodes/MNI_electrodes.tsv'));
save(strcat(patientFolder, 'electrodes/RAS_electrodes'),'RAS_electrodes');
save(strcat(patientFolder, 'electrodes/tkrRAS_electrodes'),'tkrRAS_electrodes');
save(strcat(patientFolder, 'electrodes/VOX_electrodes'),'VOX_electrodes');
save(strcat(patientFolder, 'electrodes/MR_electrodes'),'MR_electrodes');
save(strcat(patientFolder, 'electrodes/MNI_electrodes'),'MNI_electrodes');

%%
[ftver, ftpath] = ft_version;
figure
load([ftpath filesep 'template/anatomy/surface_pial_left.mat']);
ft_plot_mesh(mesh);
ft_plot_sens(MNI_electrodes);
view([-90 20]);
material dull;
lighting gouraud;
camlight;
figure
pial_rh = ft_read_headshape(strcat(patientFolder,'surf/lh.pial'));
pial_rh.coordsys = 'acpc';
ft_plot_mesh(pial_rh);
ft_plot_sens(tkrRAS_electrodes);
view([-90 20]);
material dull;
lighting gouraud;
camlight;
%%
data = {};
data = tkrRAS_electrodes;
cfg          = [];
cfg.viewmode = 'vertical';
cfg = ft_databrowser(cfg, data);
%%
depths = {'RA*'};
for d = 1:numel(depths)
cfg            = [];
cfg.channel    = ft_channelselection(depths{d}, data.label);
cfg.reref      = 'yes';
cfg.refchannel = 'all';
cfg.refmethod  = 'bipolar';
cfg.updatesens = 'yes';
reref_depths{d} = ft_preprocessing(cfg, data);
end
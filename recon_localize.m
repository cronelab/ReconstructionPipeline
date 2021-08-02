
%% original version
MR_vox = RAS_electrodes;
MR_vox.chanpos = ft_warp_apply(inv(fsmri_acpc.hdr.vox2ras0), RAS_electrodes.chanpos);
MR_vox.elecpos = ft_warp_apply(inv(fsmri_acpc.hdr.vox2ras0), RAS_electrodes.elecpos);

tkrRAS_electrodes = MR_vox;
tkrRAS_electrodes.chanpos =  ft_warp_apply(fsmri_acpc.hdr.tkrvox2ras, MR_vox.chanpos);
tkrRAS_electrodes.elecpos =  ft_warp_apply(fsmri_acpc.hdr.tkrvox2ras, MR_vox.elecpos);

VOX_electrodes =tkrRAS_electrodes;
VOX_electrodes.chanpos =  ft_warp_apply(inv(fsmri_acpc.hdr.tkrvox2ras), tkrRAS_electrodes.chanpos);
VOX_electrodes.elecpos =  ft_warp_apply(inv(fsmri_acpc.hdr.tkrvox2ras), tkrRAS_electrodes.elecpos);

%% MAKE electrodes folder before this code
exportTSV(RAS_electrodes,strcat(rawPath,subjID,'\electrodes\RAS_electrodes.tsv'));
exportTSV(tkrRAS_electrodes,strcat(rawPath,subjID,'\electrodes\tkrRAS_electrodes.tsv'));
exportTSV(VOX_electrodes,strcat(rawPath,subjID,'\electrodes\VOX_electrodes.tsv'));

save(strcat(rawPath,subjID,'\electrodes\RAS_electrodes.mat'), 'RAS_electrodes');
save(strcat(rawPath,subjID,'\electrodes\tkrRAS_electrodes.mat'), 'tkrRAS_electrodes');
save(strcat(rawPath,subjID,'\electrodes\VOX_electrodes.mat'), 'VOX_electrodes');

%%
elec = RAS_electrodes;
elec.elecpos(:,2)=-RAS_electrodes.elecpos(:,2)-41;
elec.chanpos(:,2)=-RAS_electrodes.chanpos(:,2)-41;
%%
fieldtrip2bis('./electrodes.mgrid', elec,'./MR/preOp/T1_3D_PRE_20210311100112_3_processed.nii')
%%
cfg           = [];
cfg.method    = 'cortexhull';
cfg.headshape = './rh.pial.T1';
cfg.fshome    = '/Applications/freesurfer'; % for instance, '/Applications/freesurfer'
hull_lh = ft_prepare_mesh(cfg);
%%
elec_acpc_fr = tkrRAS_electrodes;
grids = {'LTG*', 'LPOS*','LIPS*','LSPS*','STGS*','ABTS*','MBTS*','PBTS*'};
for g = 1:numel(grids)
cfg             = [];
cfg.channel     = grids{g};
cfg.keepchannel = 'yes';
cfg.elec        = elec_acpc_fr;
cfg.method      = 'headshape';
cfg.headshape   = hull_lh;
cfg.warp        = 'dykstra2012';
cfg.feedback    = 'yes';
elec_acpc_fr = ft_electroderealign(cfg);
end




%%

ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
ft_plot_sens(RAS_electrodes, 'label', 'on', 'fontcolor', 'k', 'fontsize', 6, 'facecolor', [1,0,0]);
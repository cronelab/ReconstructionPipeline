ft_defaults

whatever_CT_used_to_localize_the_electrodes = 'PY18N011/Pre/CT/CT_transformed.nii.gz'
corresponding_mgrid = 'PY18N011/Pre/CT/electrodes_transformed.mgrid'

CT = ft_read_mri(whatever_CT_used_to_localize_the_electrodes);
elec_xyz = ft_read_sens(corresponding_mgrid, 'sensetype','eeg')

% This is where it'll get tricky. Change the values below to flip the
% electrodes to correspond with the orientation in the CT
zTransform = 256 % This example changes LIP to LIA

elec_ijk.elecpos(:, 1) = elec_xyz.elecpos(:, 1)/CT.hdr.xsize;
elec_ijk.elecpos(:, 2) = elec_xyz.elecpos(:, 2)/CT.hdr.ysize;
elec_ijk.elecpos(:, 3) = (zTransform-elec_xyz.elecpos(:, 3))/CT.hdr.zsize;

% adjust for bioimage suite indexing first voxel at [0 0 0] instead of [1 1 1]
elec_ijk.elecpos = elec_ijk.elecpos+1;

% convert ijk coordinates to mri head coordinates
elec_tkrRAS = keepfields(CT, {'unit', 'coordsys'});
elec_RAS = keepfields(CT, {'unit', 'coordsys'});
elec_tkrRAS.label   = elec_xyz.label;
elec_RAS.label   = elec_xyz.label;

elec_tkrRAS.elecpos = ft_warp_apply(CT.hdr.tkrvox2ras, elec_ijk.elecpos);
elec_RAS.elecpos = ft_warp_apply(CT.hdr.vox2ras, elec_ijk.elecpos);

%%
% Load the T1 that the CT was registered to
brain_LIA = ft_read_mri('PY18N011/Pre/T1.nii')
%%
% View the RAS electrodes on the CT
cfg = [];
cfg.elec = elec_RAS;
ft_electrodeplacement(cfg, CT);
%%
% View the tkrRAS electrodes on the brain surface
pial_lh = ft_read_headshape('PY18N011/Pre/surf/rh.pial');
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
lighting gouraud;
camlight;
hold on
ft_plot_sens(elec_tkrRAS)

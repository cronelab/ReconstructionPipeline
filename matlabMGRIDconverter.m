ft_defaults
pathToData = 'E:\Shares\Gershwin\Recon\PrePostSurgicalComparison\'
patient = strcat(pathToData,'PY18N016/Pre/');
whatever_CT_used_to_localize_the_electrodes = strcat(patient,'CT/CT_LIA.nii');
corresponding_mgrid = strcat(patient,'electrodes/electrodes.mgrid');

CT = ft_read_mri(whatever_CT_used_to_localize_the_electrodes);
elec_xyz = ft_read_sens(corresponding_mgrid, 'sensetype','eeg');

%%
% This is where it'll get tricky. Change the values below to flip the
% electrodes to correspond with the orientation in the CT
zTransform = 256; % This example changes LIP to LIA

elec_ijk.elecpos(:, 1) = elec_xyz.elecpos(:, 1)/CT.hdr.xsize;
elec_ijk.elecpos(:, 2) = elec_xyz.elecpos(:, 2)/CT.hdr.ysize;
elec_ijk.elecpos(:, 3) = (zTransform-elec_xyz.elecpos(:, 3))/CT.hdr.zsize;

% adjust for bioimage suite indexing first voxel at [0 0 0] instead of [1 1 1]
% elec_ijk.elecpos = elec_ijk.elecpos+1;

% convert ijk coordinates to mri head coordinates
elec_tkrRAS = keepfields(CT, {'unit', 'coordsys'});
elec_RAS = keepfields(CT, {'unit', 'coordsys'});
elec_tkrRAS.label   = elec_xyz.label;
elec_RAS.label   = elec_xyz.label;

elec_tkrRAS.elecpos = ft_warp_apply(CT.hdr.tkrvox2ras, elec_ijk.elecpos);
elec_RAS.elecpos = ft_warp_apply(CT.hdr.vox2ras, elec_ijk.elecpos);

%%
% Load the T1 that the CT was registered to
brain_LIA = ft_read_mri(strcat(patient,'mri/T1.nii'));
%%
% View the RAS electrodes on the CT
cfg = [];
cfg.elec = elec_RAS;
ft_electrodeplacement(cfg, CT);
%%
% View the tkrRAS electrodes on the brain surface
figure;
pial_lh = ft_read_headshape(strcat(patient,'surf/lh.pial'));
pial_lh.coordsys = 'acpc';
ft_plot_mesh(pial_lh);
lighting gouraud;
camlight;
hold on
ft_plot_sens(elec_tkrRAS)
%% 
exportText(elec_RAS,'electrodes/electrodes_RAS.tsv',patient);
exportText(elec_tkrRAS,'electrodes/electrodes_tkrRAS.tsv',patient);
%%
function exportText(elec,name,patient)
    sep = regexp(elec.label,'\d');
    file{3} = elec.elecpos(:,1);
    file{4} = elec.elecpos(:,2);
    file{5} = elec.elecpos(:,3);
    fid = fopen(strcat(patient,name),'wt');
    fprintf(fid,'name\t x\t y\t z\n');
    for i = 1:length(elec.label)
        elecName = strcat(elec.label{i}(1:sep{i}-1),"'",elec.label{i}((sep{i}:length(elec.label{i}))));
        fprintf(fid, '%s\t %-.3f\t %-.3f\t %-.3f\n', elecName, file{3}(i), file{4}(i), file{5}(i));
    end
    fclose(fid)
end
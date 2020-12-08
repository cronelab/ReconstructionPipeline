% Initialize fieldtrip
ft_defaults
%Set your subject/path
subjID = 'PY20N007_SW';
rawPath = 'E:\Shares\Gershwin\Recon\2020\';
%%
%Read in the raw T1
T1_raw = strcat(rawPath,subjID,'\MR\preOp\T1.nii');
mri = ft_read_mri(T1_raw); % we used the dcm series
%%
% Determine the orientation (if raw, probably RAS) and mark acpc
ft_determine_coordsys(mri);
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'acpc';
mri_acpc = ft_volumerealign(cfg, mri);
%%
cfg           = [];
cfg.filename  = strcat(rawPath,subjID,'\MR\preOp\T1_acpc');
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_acpc);
%% 
% Send acpc-aligned T1 to Freesurfer for procesing
username = input('Zappa username: ','s')
password = input('Zappa password: ','s')
connection = ssh2_config('zappa.neuro.jhu.edu',username,password)
clear username password
%%
ssh2_simple_command(connection.hostname, connection.username, connection.password, char(strcat('mkdir /mnt/shared/Subjects/sourcedata/','PY20N006_MM')));
sftp_simple_put(connection.hostname, connection.username, connection.password, 'acpc.nii','/mnt/shared/Subjects/sourcedata/PY20N006_SW')
%%
msg = ['export FREESURFER_HOME=/usr/local/freesurfer; \' ...
    'export SUBJECTS_DIR=/mnt/shared/Subjects/derivatives/freesurfer; \' ...
    'source $FREESURFER_HOME/SetUpFreeSurfer.sh; \' ...
    'recon-all -s PY20N006_SW -i /mnt/shared/Subjects/sourcedata/PY20N006_SW/T1.nii -openmp 48 -all']
ssh2_command(connection, msg)
%%
%Get processed T1 back from Zappa
sftp_simple_get(connection.hostname, connection.username, connection.password,'/mnt/shared/Subjects/derivatives/freesurfer/PY20N006_SW/mri/T1.mgz', strcat(rawPath,subjID))
%ssh2_close(connection)
%%
fsmri_acpc = ft_read_mri(strcat(rawPath,subjID,'\MR\preOp\T1_acpc_processed.nii'));
fsmri_acpc.coordsys = 'acpc';

%%
% Read in the raw CT
CT_Raw = strcat(rawPath,subjID,'\CT\CT.nii');
ct = ft_read_mri(CT_Raw);
%%
ct = ft_determine_coordsys(ct);

%% Mark the fiducials and align CT to ctf and then acpc
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);
%%
ct_ctf = ft_determine_coordsys(ct_ctf);
%%
ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');
%%
ft_determine_coordsys(ct_acpc);

%%
% Register the CT to the T1
cfg             = [];
cfg.method      = 'spm';
cfg.spmversion  = 'spm12';
cfg.coordsys    = 'acpc';
cfg.viewresult  = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);
%%
cfg           = [];
cfg.filename  = strcat(rawPath,subjID,'\CT\ct_acpc');
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);
%%
% Mark the electrodes
elec = {};
i=1;
electrodeLabels = ["LA","LAH","LPH","LIF","LPOA","LPOB","RA","RAH","RPH","RIF"];
contactNumbers = [10,10,10,6,8,6,10,10,10,6];
for numLabels = 1:length(electrodeLabels)
    for numContacts = 1:contactNumbers(numLabels)
        elec.label{i,1} = char(strcat(electrodeLabels(numLabels),string(numContacts)));
        i=i+1;
    end
end
%%
cfg = [];
cfg.channel = elec.label;
RASelectrodes = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc);
%%
MR_vox = RASelectrodes;
MR_vox.chanpos = ft_warp_apply(inv(fsmri_acpc.hdr.vox2ras0), RASelectrodes.chanpos);
tkrRAS = MR_vox;
tkrRAS.chanpos =  ft_warp_apply(fsmri_acpc.hdr.tkrvox2ras, MR_vox.chanpos);

%%
exportTSV(tkrRAS,strcat(rawPath,subjID,'\electrodes\tkrRAS_electrodes.tsv'));
exportTSV(RASelectrodes,strcat(rawPath,subjID,'\electrodes\RAS_electrodes.tsv'));
save(strcat(rawPath,subjID,'\electrodes\RAS_electrodes.mat'), 'RASelectrodes');
save(strcat(rawPath,subjID,'\electrodes\tkrRAS_electrodes.mat'), 'tkrRAS');
%%
cfg           = [];
cfg.method    = 'cortexhull';
cfg.headshape = './Freesurfer/surf/lh.pial';
cfg.fshome    = '/Applications/freesurfer'; % for instance, '/Applications/freesurfer'
hull_lh = ft_prepare_mesh(cfg);
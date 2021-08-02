
% Perform freesurfer recon all

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

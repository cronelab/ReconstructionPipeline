% Initialize fieldtrip
ft_defaults
%%
%Set your subject/path
subjID = 'PY20N006_MM';
rawPath = 'E:\Shares\Gershwin\Recon\2020\';
%Read in the raw T1
T1_raw = strcat(rawPath,subjID,'\Imaging\02_10_20_MR\T1_3D_Ax_PRE\T1_3D_Ax_PRE_3.nii');
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
cfg.filename  = [subjID '_MR_acpc'];
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_acpc);
%% 
% Send acpc-aligned T1 to Freesurfer for procesing
username = input('Zappa username: ','s')
password = input('Zappa password: ','s')
connection = ssh2_config('zappa.neuro.jhu.edu',username,password)
clear username password
ssh2_simple_command(connection.hostname, connection.username, connection.password, char(strcat('mkdir /mnt/shared/Subjects/sourcedata/','PY20N006_MM')));
sftp_simple_put(connection.hostname, connection.username, connection.password, 'PY20N006_MM_MR_acpc.nii','/mnt/shared/Subjects/sourcedata/PY20N006_MM')
%%
msg = ['export FREESURFER_HOME=/usr/local/freesurfer; \' ...
    'source $FREESURFER_HOME/SetUpFreeSurfer.sh; \' ...
    'recon-all -s PY20N006_MM -i /mnt/shared/Subjects/sourcedata/PY20N006_MM/PY20N006_MM_MR_acpc.nii -openmp 48 -all']
ssh2_command(connection, msg)
%%
%Get processed T1 back from Zappa
sftp_simple_get('zappa.neuro.jhu.edu',usuername,password,'T1.mgz')
ssh2_close(connection)
%%
fsmri_acpc = ft_read_mri('T1.mgz');
fsmri_acpc.coordsys = 'acpc';

%%
% Read in the raw CT
CT_Raw = strcat(rawPath,subjID,'\Imaging\02_27_20_CT\01_Head_Routine_Spiral\01_Head_Routine_Spiral_Head_Routine_0.75_H20s.nii');
ct = ft_read_mri('rPY20N006_MM_CT_ctf.nii');
%ct = ft_determine_coordsys(ct);

%% Mark the fiducials and align CT to ctf and then acpc
cfg           = [];
cfg.method    = 'interactive';
cfg.coordsys  = 'ctf';
ct_ctf = ft_volumerealign(cfg, ct);
%%
ct_ctf = ft_determine_coordsys(ct_ctf);
%%
ct_acpc = ft_convert_coordsys(ct, 'acpc');
%ft_determine_coordsys(ct_acpc);

%%
% Register the CT to the T1
cfg             = [];
cfg.method      = 'spm';
cfg.spmversion  = 'spm12';
cfg.coordsys    = 'acpc';
cfg.viewresult  = 'yes';
ct_acpc_f = ft_volumerealign(cfg, ct_acpc_f, fsmri_acpc);

cfg           = [];
cfg.filename  = [subjID '_CT_acpc_f'];
cfg.filetype  = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, ct_acpc_f);
%%
% Mark the electrodes
elec = {}
i=1;
electrodeLabels = ["AMD","ALD","PMD","PLD", "CD", "AAC", "PAC", "LFA", "LFP", "LA", "LAH", "LPH"];
contactNumbers = [6,6,6,6,4,8,10,4,8,10,9,9];
for numLabels = 1:length(electrodeLabels)
    for numContacts = 1:contactNumbers(numLabels)
        elec.label{i,1} = char(strcat(electrodeLabels(numLabels),string(numContacts)));
        i=i+1;
    end
end

cfg = [];
cfg.channel = elec.label;
electrodes = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc);

%%
ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
ft_plot_sens(electrodes, 'label', 'on', 'fontcolor', 'w');
%%
ft_plot_mesh(pial_lh);
ft_plot_sens(elec_acpc_f);
view([-55 10]);
material dull;
lighting gouraud;
camlight;
%%
cfg            = [];
cfg.nonlinear  = 'yes';
cfg.spmversion = 'spm12';
cfg.spmmethod  = 'new';
fsmri_mni = ft_volumenormalise(cfg, fsmri_acpc);
%%
elec_mni_frv = elec_acpc_fr;
elec_mni_frv.elecpos = ft_warp_apply(fsmri_mni.params, elec_acpc_fr.elecpos, 'individual2sn');
elec_mni_frv.chanpos = ft_warp_apply(fsmri_mni.params, elec_acpc_fr.chanpos, 'individual2sn');
elec_mni_frv.coordsys = 'mni';
%%
[ftver, ftpath] = ft_version;
load([ftpath filesep 'template/anatomy/surface_pial_left.mat']);
ft_plot_mesh(mesh);
ft_plot_sens(elec_mni_frv);
view([-90 20]);
material dull;
lighting gouraud;
camlight;
save([subjID '_elec_mni_frv.mat'], 'elec_mni_frv');
%%
cfg           = [];
cfg.channel   = {'LPG*', 'LTG*'};
cfg.elec      = elec_acpc_fr;
cfg.method    = 'headshape';
cfg.headshape = 'freesurfer/surf/lh.pial';
cfg.warp      = 'fsaverage';
cfg.fshome    = '/usr/local/freesurfer'; % for instance, '/Applications/freesurfer'
elec_fsavg_frs = ft_electroderealign(cfg);
fspial_lh = ft_read_headshape([cfg.fshome '/subjects/fsaverage/surf/lh.pial']);
fspial_lh.coordsys = 'fsaverage';
ft_plot_mesh(fspial_lh);
ft_plot_sens(elec_fsavg_frs);
view([-90 20]);
material dull;
lighting gouraud;
camlight;
save([subjID '_elec_fsavg_frs.mat'], 'elec_fsavg_frs');
%%
atlas = ft_read_atlas([ftpath filesep 'template/atlas/aal/ROI_MNI_V4.nii']);
cfg            = [];
cfg.roi        = elec_mni_frv.chanpos(match_str(elec_mni_frv.label,'LHH2'),:);
cfg.atlas      = atlas;
cfg.inputcoord = 'mni';
cfg.output     = 'label';
labels = ft_volumelookup(cfg, atlas);

[~, indx] = max(labels.count);
labels.name(indx)
%%
cfg                     = [];
%cfg.dataset             = <path to recording file>;
cfg.trialdef.eventtype  = 'TRIGGER';
cfg.trialdef.eventvalue = 4;
cfg.trialdef.prestim    = 0.4;
cfg.trialdef.poststim   = 0.9;
cfg = ft_definetrial(cfg);
cfg.demean         = 'yes';
cfg.baselinewindow = 'all';
cfg.lpfilter       = 'yes';
cfg.lpfreq         = 200;
cfg.padding        = 2;
cfg.padtype        = 'data';
cfg.bsfilter       = 'yes';
cfg.bsfiltord      = 3;
cfg.bsfreq         = [59 61; 119 121; 179 181];
data = ft_preprocessing(cfg);
%%
data.elec = elec_acpc_fr;
save([subjID '_data.mat'], 'data');
cfg          = [];
cfg.viewmode = 'vertical';
cfg = ft_databrowser(cfg, data);
%%
cfg             = [];
cfg.channel     = {'LPG*', 'LTG*'};
cfg.reref       = 'yes';
cfg.refchannel  = 'all';
cfg.refmethod   = 'avg';
reref_grids = ft_preprocessing(cfg, data);
%%
depths = {'RAM*', 'RHH*', 'RTH*', 'ROC*', 'LAM*', 'LHH*', 'LTH*'};
for d = 1:numel(depths)
    cfg            = [];
    cfg.channel    = ft_channelselection(depths{d}, data.label);
    cfg.reref      = 'yes';
    cfg.refchannel = 'all';
    cfg.refmethod  = 'bipolar';
    cfg.updatesens = 'yes';
    reref_depths{d} = ft_preprocessing(cfg, data);
end
%%
cfg            = [];
cfg.appendsens = 'yes';
reref = ft_appenddata(cfg, reref_grids, reref_depths{:});
save([subjID '_reref.mat'], reref);
%%
cfg            = [];
cfg.method     = 'mtmconvol';
cfg.toi        = -.3:0.01:.8;
cfg.foi        = 5:5:200;
cfg.t_ftimwin  = ones(length(cfg.foi),1).*0.2;
cfg.taper      = 'hanning';
cfg.output     = 'pow';
cfg.keeptrials = 'no';
freq = ft_freqanalysis(cfg, reref);
save([subjID '_freq.mat'], 'freq');
cfg            = [];
cfg.headshape  = pial_lh;
cfg.projection = 'orthographic';
cfg.channel    = {'LPG*', 'LTG*'};
cfg.viewpoint  = 'left';
cfg.mask       = 'convex';
cfg.boxchannel = {'LTG30', 'LTG31'};
lay = ft_prepare_layout(cfg, freq);
%%
cfg              = [];
cfg.baseline     = [-.3 -.1];
cfg.baselinetype = 'relchange';
freq_blc = ft_freqbaseline(cfg, freq);
cfg             = [];
cfg.layout      = lay;
cfg.showoutline = 'yes';
ft_multiplotTFR(cfg, freq_blc);
%%
cfg             = [];
cfg.frequency   = [70 150];
cfg.avgoverfreq = 'yes';
cfg.latency     = [0 0.8];
cfg.avgovertime = 'yes';
freq_sel = ft_selectdata(cfg, freq_blc);
cfg              = [];
cfg.funparameter = 'powspctrm';
cfg.funcolorlim  = [-.5 .5];
cfg.method       = 'surface';
cfg.interpmethod = 'sphere_weighteddistance';
cfg.sphereradius = 8;
cfg.camlight     = 'no';
ft_sourceplot(cfg, freq_sel, pial_lh);
view([-90 20]);
material dull;
lighting gouraud;
camlight;
%%
atlas = ft_read_atlas('freesurfer/mri/aparc+aseg.nii');
atlas.coordsys = 'acpc';
cfg            = [];
cfg.inputcoord = 'acpc';
cfg.atlas      = atlas;
cfg.roi        = {'Right-Hippocampus', 'Right-Amygdala'};
mask_rha = ft_volumelookup(cfg, atlas);
%%
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha = ft_prepare_mesh(cfg, seg);
%%
cfg         = [];
cfg.channel = {'RAM*', 'RTH*', 'RHH*'};
freq_sel2 = ft_selectdata(cfg, freq_sel);
%%
cfg              = [];
cfg.funparameter = 'powspctrm';
cfg.funcolorlim  = [-.5 .5];
cfg.method       = 'cloud';
cfg.slice        = '3d';
cfg.nslices      = 2;
cfg.facealpha    = .25;
ft_sourceplot(cfg, freq_sel2, mesh_rha);
view([120 40]);
lighting gouraud;
camlight;

%%
cfg              = [];
cfg.funparameter = 'powspctrm';
cfg.funcolorlim  = [-2 2];
cfg.method       = 'cloud';
cfg.slice        = '2d';
cfg.nslices      = 2;
cfg.facealpha    = .25;
ft_sourceplot(cfg, freq_sel2, mesh_rha);
view([120 40]);
lighting gouraud;
camlight;
ft_sourceplot(cfg, freq_sel2, mesh_rha);




































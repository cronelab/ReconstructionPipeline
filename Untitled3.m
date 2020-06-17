clear
ft_defaults
% import the patient's electrodes
patientFolder = 'E:\Shares\Gershwin\Recon\PrePostSurgicalComparison\PY18N011\Pre\';
tkrRAS = importTSV(strcat(patientFolder,'electrodes\electrodes_tkrRAS.tsv'));
tkrRAS.name = erase(tkrRAS.name,"'");
tkrRAS_electrodes = {};
tkrRAS_electrodes.unit = 'mm';
tkrRAS_electrodes.label = tkrRAS.name;
tkrRAS_electrodes.elecpos = [tkrRAS.x, tkrRAS.y, tkrRAS.z];
tkrRAS_electrodes.chanpos = [tkrRAS.x, tkrRAS.y, tkrRAS.z];
tkrRAS_electrodes.tra = eye(length(tkrRAS.name));
elecLabel = {};
sep = regexp(tkrRAS.name,'\d');
for i=1:length(tkrRAS.name)
    elecLabel{i} = strcat(tkrRAS.name{i}(1:sep{i}-1),'*');
end
elecLabel = unique(elecLabel);

z = 1;
test = {}
channel = {};
for d = 1:numel(elecLabel)
    channel{d}    = ft_channelselection(elecLabel{d}, tkrRAS.name);
    bipolar = {};
    bipolar.tra = [];
    bipolar.labelnew = {};
    bipolar.labelold{1} = char(channel{d}(1))
    for i=2:length(channel{d})
     sep = regexp(channel{d}{i-1},'\d')  
     bipolar.labelnew{end+1} = strcat(channel{d}{i-1}(1:sep-1),channel{d}{i-1}(sep),'-',channel{d}{i-1}(1:sep-1),channel{d}{i}(sep(1):length(channel{d}{i})));
     bipolar.labelold{end+1} = char(channel{d}(i))
     bipolar.tra(i,i) = 1;
     bipolar.tra(i,i+1) = -1;
    end

    bipolar.tra(1,:) = [];
    bipolar.tra(:,i+1) = [];

    newsens{d} = ft_apply_montage(tkrRAS_electrodes, bipolar);
    test.label{z} = newsens{d}.label;
    test.chanpos{z} = newsens{d}.chanpos;
    test.elecpos{z} = newsens{d}.elecpos;
z=z+1;
end
%%
newLabels = horzcat(test.label{:});
newChanPos = vertcat(test.chanpos{:});
newElecPos = vertcat(test.elecpos{:});
for i=1:length(newLabels)
    tkrRAS_electrodes.label(end+1) = newLabels(i);
    tkrRAS_electrodes.chanpos(end+1) = newChanPos(i);
    tkrRAS_electrodes.elecpos(end+1) = newElecPos(i);
end

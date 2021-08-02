% Mark the electrodes
elec = {};
electrodeLabels = [
    ["RAC", 8],
    ["RMF", 12],
    ["RSM",8],
    ["RLM", 8],
    ["RLL", 8],
    ["RLP", 8],
    ["RP",8],
    ["RAM",10],
    ["RAH",10],
    ["RPH",10],
    ["LAC",8],
    ["LMF",10],
    ["LSM",6]
];
i=1;
j=1;
for label = 1:length(electrodeLabels)
    for contact = 1:str2double(electrodeLabels(i,2))
        elec.label{j,1} = char(strcat(electrodeLabels(i),string(contact)));
        j=j+1;
    end
    i = i+1;
   
end


cfg = [];
cfg.channel =elec.label;
%cfg.elec = RAS_electrodes; %%uncomment to edit existing electrode locations
RAS_electrodes = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc);

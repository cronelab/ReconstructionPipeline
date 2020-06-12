function exportTSV(elec,name)
    sep = regexp(elec.label,'\d');
    file{3} = elec.chanpos(:,1);
    file{4} = elec.chanpos(:,2);
    file{5} = elec.chanpos(:,3);
    fid = fopen(name,'wt');
    fprintf(fid,'name\tx\ty\tz\n');
    for i = 1:length(elec.label)
        elecName = strcat(elec.label{i}(1:sep{i}-1),"'",elec.label{i}((sep{i}:length(elec.label{i}))));
        fprintf(fid, '%s\t%-.3f\t%-.3f\t%-.3f\n', elecName, file{3}(i), file{4}(i), file{5}(i));
    end
    fclose(fid)
end
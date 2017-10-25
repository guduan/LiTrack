function translate_ascii_matlab
 translate('ParticleFiles', 'zd')
 translate('Wakefiles', 'dat')


function translate(root, ext)
for file = dir([root, '/*'])'
    name = file.name;
    base_name =  name(1:end-length(ext)-1);
    mat_name = sprintf('%s/%smat', root, base_name);
    
%     disp(~strcmp(name(end-length(ext):end), ext))
    
    
    if strcmp(name, '.') || ...
       strcmp(name, '..') || ...
       ~strcmp(name(end-length(ext)+1:end), ext) || ...
       exist(mat_name, 'file')
        continue
    end
    
    raw = struct();
    raw.(base_name) = load(sprintf('%s/%s', root, name));
    save(sprintf('%s/%s.mat', root, base_name), '-struct', 'raw');
    disp(base_name)
end
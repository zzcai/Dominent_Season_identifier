clear

%% vpp labels
% tile name
tilename = '33VUE';
% year
year = '2019';
% list of VPP name
vppname   = {'SOSD','EOSD','MAXD','SOSV','EOSV','MINV','MAXV','AMPL','LENGTH','LSLOPE','RSLOPE','SPROD','TPROD','QFLAG'};
% list of VPP nan value 
vppnodata = [  0   ,  0   ,  0   ,-32768,-32768,-32768,-32768,-32768,   0    ,-32768  ,-32768  ,65535  ,65535];
% VPP data folder
vppfolder = ['/Users/zhanzhangcai/Library/CloudStorage/OneDrive-LundUniversity/HR-VPP/HRVPP_data/','T',tilename,'_VPP/'];
% output folder
outfolder = ['/Users/zhanzhangcai/Library/CloudStorage/OneDrive-LundUniversity/HR-VPP/HRVPP_data/','T',tilename,'_VPP/'];
%% generate dominent season id (S1 or S2)

% import s1 TPROD
findvpp = dir([vppfolder,'*',year,'*',tilename,'*','_s1_TPROD.tif']); % find s1 TPROD
TPROD_s1 = double(imread(fullfile(findvpp.folder,findvpp.name))); % read s1 TPROD (double)
TPROD_s1(TPROD_s1==65535)=nan; % set nan value

% import s2 TPROD
findvpp = dir([vppfolder,'*',year,'*',tilename,'*','_s2_TPROD.tif']); % find s2 TPROD
TPROD_s2 = double(imread(fullfile(findvpp.folder,findvpp.name))); % read s2 TPROD (double)
TPROD_s2(TPROD_s2==65535)=nan; % set nan value

% combine s1 and s2 to a 3d matrix
TPROD_s1_s2 = cat(3,TPROD_s1,TPROD_s2);

% determine where the max TPROD is, <dsid> represent the dominant season
[maxTPROD,dsid] = max(TPROD_s1_s2,[],3);

%% generate dominent seasons
for i = 1:length(vppname)
    % import s1 TPROD
    findvpp1 = dir([vppfolder,'*',year,'*',tilename,'*','_s1_',vppname{i},'.tif']); % find s1 vpp
    vppfile1 = fullfile(findvpp1.folder,findvpp1.name);
    [vpp_s1,~] = geotiffread(vppfile1); % 

    % import s2 TPROD
    findvpp2 = dir([vppfolder,'*',year,'*',tilename,'*','_s2_',vppname{i},'.tif']); % find s2 vpp
    vppfile1 = fullfile(findvpp2.folder,findvpp2.name);
    [vpp_s2,R] = geotiffread(vppfile1); % 
    info = geotiffinfo(vppfile1);

    % create vpp_dominant
    vpp_dominant = vpp_s1;
    % replace values if the dominant season is s2 (dsid == 2)
    vpp_dominant(dsid==2) = vpp_s2(dsid==2);

    % generate new output
    ouputfile = strrep(findvpp1.name,'_s1_','_main_');
    % write the dominant to tiff
    geotiffwrite(fullfile(outfolder,ouputfile),vpp_dominant,R,...
        'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
end
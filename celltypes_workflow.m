% Code updated on 2/7/20 by Kyle Fang
% This code can now take in as many periods within an epoch as needed, as
% long as the m3p3_range_ItoS and m3p3_range_StoI are formatted as below:
% [start frame 1, end frame 1, start frame 2, end frame 2, etc.]


% The only manual components to this code is loading data into m3p3_range_ItoS
% and m3p3_range_StoI and inputting the number many frames per bin in
% line ~344.

% Need sort_max_time_fxn.m file to run the sorting section of this code in
% line ~280

% This code has 2 different  data sets ready to load into m3p3_range_ItoS
% and m3p3_range_StoI. The data set currently active is 3 seconds before
% and after each change in behavior.

% In order to access the other data set -- beginning (60 frames), middle (60
% frames), and end (60 frames) periods of each change in behavior --
% comment out the "Loading into m3p3_range_ItoS and m3p3_range_StoI" and
% uncomment the "loading different data" section



% Code written by SAW on 1/23/20
% This code is based on celltypes_workflow_v3.mat which was written by Kyle
% Fang and Scott Wilke in January 2020. The difference is that this code has
% been modified to run a similar analysis, but to look at how activity
% changes across struggling vs. immobility (rather than during transitions
% between these two types of behavior). Basically, because struggling and
% immobility vary in length, we need a way to define points of comparison at
% the beginning, middle and end of each epoch. This code takes epochs that
% are already longer than 180 frames at minimum and subdivides them into 60
% frame chunks taken from the beginning, middle and end of the epoch. Then
% it will take those three separate chunks and plot activity as per the
% original workflow.


clearvars -except analysis kd_sigs


%% Loading into m3p3_range_ItoS and m3p3_range_StoI

% loading struggle and immobile epochs
struggle_range_long = analysis(2).struggle_range_long; % contains start and end times
immobile_range_long = analysis(2).immobile_range_long;

% Breaking down long struggle epochs into 3 equal sized chunks, beg, middle, and end


%% Struggle
s_rangeL_beg = [struggle_range_long(:,1), struggle_range_long(:,1) + 59];
s_rangeL_end = [struggle_range_long(:,2) - 59, struggle_range_long(:,2)];

% s_rangeL_mid contains the very middle of each epoch
s_rangeL_mid = (size(struggle_range_long,1));
s_rangeL_mid = zeros(s_rangeL_mid,2); % s_rangeL_mid = zeros(size(struggle_range_long, 1), 2)

for t = 1:size(struggle_range_long,1) % for each epoch
    
    m = struggle_range_long(t,:);
    temp = m(1):m(2);
    temp2 = floor(median(temp));
    start = temp2-30;
    stop = temp2+29; % now med start and finish have 59 difference (60 frames inclusive)
    insert = [start stop];
    
    s_rangeL_mid(t,1)=insert(1,1);
    s_rangeL_mid(t,2)=insert(1,2);
end



%% Immobile
% Breaking down long immobile epochs into 3 equal sized chunks, beg,
% middle, end

i_rangeL_beg = [immobile_range_long(:,1), immobile_range_long(:,1) + 59];

i_rangeL_end = [immobile_range_long(:,2) - 59, immobile_range_long(:,2)];


%% i_rangeL_mid
i_rangeL_mid = (size(immobile_range_long,1));
i_rangeL_mid = zeros(i_rangeL_mid,2);


for t = 1:size(immobile_range_long,1)
    
    m = immobile_range_long(t,:);
    temp = m(1):m(2);
    temp2 = floor(median(temp));
    start = temp2-30;
    stop = temp2+29; % now med start and finish have 59 difference (60 frames inclusive)
    insert = [start stop];
    
    i_rangeL_mid(t,1)=insert(1,1);
    i_rangeL_mid(t,2)=insert(1,2);
end



%% m3p3_range_ItoS
%% m3p3_range_ItoS is a matrix where it has
%% beg start frame, beg last frame, mid start frame, mid last frame, end start frame, end last frame

m3p3_range_ItoS = i_rangeL_beg;

[m3p3_range_ItoS_rows, m3p3_range_ItoS_cols] = size(m3p3_range_ItoS);
m3p3_range_ItoS(:, m3p3_range_ItoS_cols + 1:m3p3_range_ItoS_cols + 2) = i_rangeL_mid;

[m3p3_range_ItoS_rows, m3p3_range_ItoS_cols] = size(m3p3_range_ItoS);
m3p3_range_ItoS(:, m3p3_range_ItoS_cols + 1:m3p3_range_ItoS_cols + 2) = i_rangeL_end;


%% m3p3_range_StoI
% m3p3_range_StoI is a matrix that contains
% beg start frame, beg last frame, mid start frame, mid last frame, end start frame, end last frame

m3p3_range_StoI = s_rangeL_beg;

[m3p3_range_StoI_rows, m3p3_range_StoI_cols] = size(m3p3_range_StoI);
m3p3_range_StoI(:, m3p3_range_StoI_cols + 1:m3p3_range_StoI_cols + 2) = s_rangeL_mid;

[m3p3_range_StoI_rows, m3p3_range_StoI_cols] = size(m3p3_range_StoI);
m3p3_range_StoI(:, m3p3_range_StoI_cols + 1:m3p3_range_StoI_cols + 2) = s_rangeL_end;



%% loading different data
%{
m3p3_range_ItoS = analysis(2).m3p3_range_ItoS;
m3p3_range_StoI = analysis(2).m3p3_range_StoI;
%}




%% Code below works as long as m3p3_range_ItoS and m3p3_range_StoI formatted as
%% [start frame 1, end frame 1, start frame 2, end frame 2, etc.]


%% code above needs manual input, code below works automatically



% 3 main types of code
sig_kd = kd_sigs(2).cell_sig_f_f0;
sig_zs = zscore(kd_sigs(2).cell_sig_f_f0);
sig_an = analysis(2).raster;

% number_of_periods within an epoch
[not_needed, number_of_periods] = size(m3p3_range_ItoS);

% now number_of_periods has the accurate number of periods
number_of_periods = number_of_periods / 2;

number_of_frames_per_period = zeros(1, number_of_periods);

for i = 1:number_of_periods
    number_of_frames_per_period(1, (i)) = m3p3_range_ItoS(1, i * 2) - m3p3_range_ItoS(1, i * 2 - 1) + 1;
end

total_frames = sum(number_of_frames_per_period);

% we pre-allocate matrices of zeros which will be populated with spike
% probability data
IS_kd = zeros((size(sig_kd,1)), total_frames);
SI_kd = zeros((size(sig_kd,1)), total_frames);

IS_zs = zeros((size(sig_kd,1)), total_frames);
SI_zs = zeros((size(sig_kd,1)), total_frames);

IS_an = zeros((size(sig_kd,1)), total_frames);
SI_an = zeros((size(sig_kd,1)), total_frames);

% number_of_events_IS represents number of immobile to struggling events
number_of_events_IS = size(m3p3_range_ItoS, 1);


%% IS -- Immobile to Struggling

% pre-allocate Isall matrices
ISall_kd(number_of_events_IS, total_frames) = 0;
    
ISall_zs(number_of_events_IS, total_frames) = 0;
        
ISall_an(number_of_events_IS, total_frames) = 0;


%% Fill IS_kd, IS_zs, IS_an
for i = 1:size(sig_kd,1) % loop through each neuron
    % fill ISall with the signals of neuron i during each event
    
    for row = 1:number_of_events_IS   % loop through each event
            
        start_index = 1;
        
        for m = 1:number_of_periods
            ISall_kd(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_kd(i, m3p3_range_ItoS(row, m * 2 - 1) : m3p3_range_ItoS(row, m * 2));
        
            ISall_zs(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_zs(i, m3p3_range_ItoS(row, m * 2 - 1) : m3p3_range_ItoS(row, m * 2));
        
            ISall_an(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_an(i, m3p3_range_ItoS(row, m * 2 - 1) : m3p3_range_ItoS(row, m * 2));

            start_index = start_index + number_of_frames_per_period(m);
        end
        
    end
    
    % find overall mean signal per frame across of all events
    ISmean_kd = mean(ISall_kd);
    ISmean_zs = mean(ISall_zs);
    ISmean_an = mean(ISall_an);

    % fill a row of IS
    IS_kd(i,:) = ISmean_kd;
    IS_zs(i,:) = ISmean_zs;
    IS_an(i,:) = ISmean_an;

end


%% Struggling to Immobile -- SI

% number_of_events_SI represents number of struggling to immobile events
number_of_events_SI = size(m3p3_range_StoI, 1);

% pre-allocate SIall matrices
SIall_kd(number_of_events_SI, total_frames) = 0;
    
SIall_zs(number_of_events_SI, total_frames) = 0;
        
SIall_an(number_of_events_SI, total_frames) = 0;
    

%% Fill SI_kd, SI_zs, SI_an
for i = 1:size(sig_kd,1) % loop through each neuron
        
    % fill SIall with the signals of neuron i during each event
    for row = 1:number_of_events_SI   % loop through each event
            
        start_index = 1;
        for m = 1:number_of_periods
            SIall_kd(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_kd(i, m3p3_range_StoI(row, m * 2 - 1) : m3p3_range_StoI(row, m * 2));
        
            SIall_zs(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_zs(i, m3p3_range_StoI(row, m * 2 - 1) : m3p3_range_StoI(row, m * 2));
        
            SIall_an(row, (start_index: (start_index + number_of_frames_per_period(m) - 1)))...
            = sig_an(i, m3p3_range_StoI(row, m * 2 - 1) : m3p3_range_StoI(row, m * 2));

            start_index = start_index + number_of_frames_per_period(m);
            
        end
            
    end
    
    %find overall mean signal per frame across of all events
    SImean_kd = mean(SIall_kd);
    SImean_zs = mean(SIall_zs);
    SImean_an = mean(SIall_an);

    %fill a row of SI
    SI_kd(i,:) = SImean_kd;
    SI_zs(i,:) = SImean_zs;
    SI_an(i,:) = SImean_an;

end
           


%% sort original results
[sort_IS_kd, sort_SI_kd] = sort_max_time_fxn(IS_kd, SI_kd);
[sort_IS_zs, sort_SI_zs] = sort_max_time_fxn(IS_zs, SI_zs);
[sort_IS_an, sort_SI_an] = sort_max_time_fxn(IS_an, SI_an);


%% The code below plots a set of resulting figures based on the
%% results for a single brain using 'IS' and 'SI'

%% original
if true
 figure;

% title of whole figure
sgtitle('1 Frame Per Bin')
 
subplot(3,2,1),imagesc(sort_IS_kd);
%subplot(3,2,1),imagesc(IS_kd);
%colormap jet
title('IS kd sorted')
caxis([-.1 .1]);


subplot(3,2,2),imagesc(sort_SI_kd);
%subplot(3,2,2),imagesc(SI_kd);
%colormap jet
title('SI kd sorted')
caxis([-.1 .1]);


subplot(3,2,3),imagesc(sort_IS_zs);
%subplot(3,2,3),imagesc(IS_zs);
%colormap jet
title('IS zs sorted')
caxis([-1 1]);


subplot(3,2,4),imagesc(sort_SI_zs);
%subplot(3,2,4),imagesc(SI_zs);
%colormap jet
title('SI zs sorted')
caxis([-1 1]);


subplot(3,2,5),imagesc(sort_IS_an);
%subplot(3,2,5),imagesc(IS_an);
%colormap jet
title('IS an sorted')
%caxis([0 0.5]);


subplot(3,2,6),imagesc(sort_SI_an);
%subplot(3,2,6),imagesc(SI_an);
%colormap jet
title('SI an sorted')
%caxis([0 0.5]);
 
end



%% frames_per_bin decides how many frames per bin. Change this variable
%% to input the number of frames per bin needed.
%% NOTE: The number of frames per bin MUST be a factor of total number of
%% frames or the code will break.
frames_per_bin = 15

bins_IS_kd = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
bins_IS_zs = zeros((size(sig_zs,1)) , (total_frames/frames_per_bin));
bins_IS_an = zeros((size(sig_an,1)) , (total_frames/frames_per_bin));

bins_SI_kd = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
bins_SI_zs = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));
bins_SI_an = zeros((size(sig_kd,1)) , (total_frames/frames_per_bin));


for i = 1:size(sig_kd,1) % loop through each neuron
    for j = 1:(length(IS_kd)/frames_per_bin)
        % IS
        bins_IS_kd(i, j) = mean(IS_kd(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        bins_IS_zs(i, j) = mean(IS_zs(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        bins_IS_an(i, j) = mean(IS_an(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        
        % SI
        bins_SI_kd(i, j) = mean(SI_kd(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        bins_SI_zs(i, j) = mean(SI_zs(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
        bins_SI_an(i, j) = mean(SI_an(i, (j * frames_per_bin - frames_per_bin + 1):(j * frames_per_bin)));
    end
end


%% sort bins
[sort_bins_IS_kd, sort_bins_SI_kd] = sort_max_time_fxn(bins_IS_kd, bins_SI_kd);
[sort_bins_IS_zs, sort_bins_SI_zs] = sort_max_time_fxn(bins_IS_zs, bins_SI_zs);
[sort_bins_IS_an, sort_bins_SI_an] = sort_max_time_fxn(bins_IS_an, bins_SI_an);


%% plot bins
if true
 figure;

% title of whole figure
sgtitle(frames_per_bin + " frames per bin")
 
subplot(3,2,1),imagesc(sort_bins_IS_kd);
%subplot(3,2,1),imagesc(IS_kd);
%colormap jet
title('IS kd sorted')
caxis([-.1 .1]);


subplot(3,2,2),imagesc(sort_bins_SI_kd);
%subplot(3,2,2),imagesc(SI_kd);
%colormap jet
title('SI kd sorted')
caxis([-.1 .1]);


subplot(3,2,3),imagesc(sort_bins_IS_zs);
%subplot(3,2,3),imagesc(IS_zs);
%colormap jet
title('IS zs sorted')
caxis([-1 1]);


subplot(3,2,4),imagesc(sort_bins_SI_zs);
%subplot(3,2,4),imagesc(SI_zs);
%colormap jet
title('SI zs sorted')
caxis([-1 1]);


subplot(3,2,5),imagesc(sort_bins_IS_an);
%subplot(3,2,5),imagesc(IS_an);
%colormap jet
title('IS an sorted')
%caxis([0 0.5]);


subplot(3,2,6),imagesc(sort_bins_SI_an);
%subplot(3,2,6),imagesc(SI_an);
%colormap jet
title('SI an sorted')
%caxis([0 0.5]);
 
end


%% put results into m3p3 object
m3p3(2).ItoS_cell_sig_f_f0 = IS_kd;
m3p3(2).StoI_cell_sig_f_f0 = SI_kd;

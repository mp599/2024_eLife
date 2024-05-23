%% pipeline from MB modelling analysis:
% from calcium imaging timeseries to kenyon cells timeseries
% by A. Wystrach and M. Paoli, eLife 2024

close all, clear all, clc

% FUNCTIONS REQUIRED: create_MB, use_MB


%% load and extract database
load('examplary_bee.mat')
bee = database.bee; 
bee = squeeze(mean(bee,3)); %for exemplificatory purposes, use mean across repetitions as input form MB
[gl,od,ti] = size(bee); % now bee is a matrix of GLOMERULI X ODORANTS X TIME
odorants = database.odorants; %'1-hexanol','1-heptanol','peppermint oil'
hz = database.time_frequency_in_hz;

%% some basic variables
limite_x = [-3 14]% visualize plots in the -3 to 14 second range
refs = [80,180,60];


%% execute
f1 = figure('color','white')
%for each odorant
for o = 1:od
    
    %% first show PN profile
    % define the PN timeseries for that bee/odor as the PN input to the modelled MB
    PN_input = squeeze(bee(:,o,:))*100; %factor 100 is to show changes as %
    nb_PNs = size(PN_input,1);
    timeline = (.05:.05:0.05*size(PN_input,2))-3; %define x-axis for plot
    figure(f1)
    subplot(2,od,o)
    imagesc(timeline, 1:end,PN_input)
    xlabel('time [s]');
    caxis([-25 25]);
    xlim(limite_x)
    % show stimulus interval from 0 to 5s
    line([0 0],[0 nb_PNs],'color','k','LineStyle','-','LineWidth',1)
    line([5 5],[0 nb_PNs],'color','k','LineStyle','-','LineWidth',1)

    title(odorants{o})
    drawnow
    
    %% modify PN input so that each glom has 3 PNs
    PN_input_multip = nan(gl*3,ti);
    for i = 1:gl
        indi = i*3-2;
        PN_input_multip(indi:indi+2,:) = [PN_input(i,:);PN_input(i,:);PN_input(i,:)];
    end
    PN_input = PN_input_multip;
    %% Create MB (empty matrix)
    
    nb_PNs = size(PN_input,1); %PN input defined from imaging timeseries
    nb_KC = 1000; %number of Kenyon cells
    PNperKCs = round(nb_PNs/3); %number of PN for each KC
    MB = create_MB(nb_PNs, nb_KC, PNperKCs); %external function
    disp 'MB created'

    %% Use the MB with a series of input across time
    
    nb_KC_firing = round(nb_KC/10);% Only 10% of most active KC firing
    [KC_PA, KC_EPSP] = use_MB (PN_input, MB, nb_KC_firing);
    % visualize KC time profile
    figure(f1)
    subplot(2,od,o+od)
    imagesc(timeline,1:end,sortrows(KC_PA',[80 90 180,250]))%[80 170 180]))
    xlim(limite_x)
    line([0 0],[0 nb_KC],'color','k','LineStyle','-','LineWidth',1)
    line([5 5],[0 nb_KC],'color','k','LineStyle','-','LineWidth',1)
    xlabel('time [s]')
end
   



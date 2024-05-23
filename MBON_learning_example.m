%% pipeline from MB modelling and MBON learning:
% from calcium imaging timeseries to MBON activity
% by A. Wystrach and M. Paoli, eLife 2024

close all, clear all, clc

% FUNCTIONS REQUIRED: create_MB, use_MB, learn_MB, familiarity_MB

%% load and extract database
load('examplary_bee.mat')
bee_original = database.bee; 
odorants = database.odorants; %'1-hexanol','1-heptanol','peppermint oil'
fs = database.time_frequency_in_hz;
%% define learning window, e.g. btw 4 and 7s
%note that stimulus is delivered between 0 and 5s
learning_window_s = [4 7]; %define learning window (in seconds);
learning_window = learning_window_s(1)*fs:learning_window_s(2)*fs; %convert in timepoints

%% define useful variables
synaptic_plasticity = 15; %define a synaptic plasticity threshold (number of active instances of a synapses necessary to turn it off)
% NOTE: different bees will require generating different MB models
bee = bee_original(:,[1,3],:,:); % chose, e.g., that odor 1 and odor 3 will be the learned and the novel odorant
[gl,od,tr,ti] = size(bee); %  bee is a matrix of GLOMERULI X ODORANTS X TRIALS X TIME
timeline = (1/fs:1/fs:ti/fs)-3; %define x-axis for plot

%% create MB
nb_PNs = gl*3;
nb_KC = 1000;
PNperKCs = round(nb_PNs/2);
nb_KC_firing = round(nb_KC/10);% Here take 10% of most excited KCs
%---------Create MB (PN_KC connectivity matrix)
MB = create_MB(nb_PNs, nb_KC, PNperKCs);

%% LEARNING: test odorant_1 agains itself and against odorant_2
% bees will learn the PN_input of trials 1 to 5 and will be tested agains
% trial 6 to 10 of the same and a novel odorant
bee_template = squeeze(mean(bee(:,:,1:5,:),3)); %learned PN configuration
[gl,od,ti] = size(bee_template);
store_familiarity_scores = nan(2,5,ti);
for o = 1 % training with odor 1
    PN_input = squeeze(bee_template(:,o,:)); %template was calculated as mean of trials 1 to 5
    
    %% modify PN input:each glom has 3 PNs
    PN_input_multip = nan(gl*3,ti);
    for i = 1:gl
        indi = i*3-2;
        PN_input_multip(indi:indi+2,:) = [PN_input(i,:);PN_input(i,:);PN_input(i,:)];
    end
    PN_input = PN_input_multip;
    %%
    %-----------Learn in the MB (=switch off the output weight of KCs firing above synaptic plasticity threshold)
    [W_KC_MBON] = learn_MB(PN_input(:, learning_window), synaptic_plasticity, MB, nb_KC_firing);
    % Return the learnt connectivity matrice between KCs and the MBON.
    
    %----------Compare with the second 5 trials of same and different odorants
    
    for t = 6:10
        for oo = 1:od %test with odor 1 and 2
            PN_input= squeeze(bee(:,oo,t,:));
            %% modify PN input:each glom has 3 PNs
            PN_input_multip = nan(size(PN_input,1)*3,size(PN_input,2));
            for i = 1:gl
                indi = i*3-2;
                PN_input_multip(indi:indi+2,:) = [PN_input(i,:);PN_input(i,:);PN_input(i,:)];
            end
            PN_input = PN_input_multip;
            %%
            [MBON] = familiarity_MB (W_KC_MBON, PN_input, MB, nb_KC_firing);
            store_familiarity_scores(oo,t-5,:) = MBON;
        end
    end
    drawnow
end

%% visualize
figure('color','white')
color_plots = [0.7,0.09,0.17;0.13,0.40,0.67];
for o = 1:2
    for t = 1:5
        plot(timeline,squeeze(store_familiarity_scores(o,t,:)),'color',color_plots(o,:))
        hold on
        box off
    end
end
title('MBON response to learned (red) and novel (blue) odorant')
        

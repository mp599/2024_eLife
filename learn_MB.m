%% created by Antoine Wystrach

function [W_KC_MBON] = learn_MB (PN_input_learn, synaptic_plasticity, MB, nb_KC_firing)

% Will create a Matrice for KC output synaptic weight to MBON.
% Simplest learning rules:
% At the begining, all KC_MBON weight = 1 (naive stage);
% During learning, all active KCs switch their output weight to 0.

W_KC_MBON = ones(1, size(MB,2)); % Naive weights

% Get the KC activity across time for the learnt input
[KC_AP, ~] = use_MB (PN_input_learn, MB, nb_KC_firing); 

% Get how much KCs got activated during learning window
active_KC = sum(KC_AP); 

learnt_KC = active_KC >= synaptic_plasticity; % find KCs that passes the threshold for learning

W_KC_MBON(learnt_KC)=0; % switch off the synapses of the learnt KCs.

% plasticity is here all or nothing synapse switch suddenly from (1 or 0), which seem supported by drosophila papers
% the synaptic_plasticity = 1 means that a KC must fire only once for its output synpase to switch off 


%% created by Antoine Wystrach

function [MBON] = familiarity_MB (W_KC_MBON, PN_input, MB, nb_KC_firing)

% use the learnt W_KC_MBON weights to output MBON activity to a given input


% Get the KC activity across time for the learnt input
[KC_AP, ~] = use_MB (PN_input, MB, nb_KC_firing); 

KC_output_on_MBON = KC_AP .* W_KC_MBON; %get wich KC fire on the MBON (so KC_PA is one, and is output weight is 1)

MBON = sum(KC_output_on_MBON,2)/nb_KC_firing; %MBON activity across time (/nb_KC_firing is to normalised between 0 and 1)

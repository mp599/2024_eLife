%% created by Antoine Wystrach

function [KC_AP, KC_EPSP] = use_MB (PN_input, MB, nb_KC_firing)
%in PN_input, glomerulus is vertical, time is horizontal
%work with a single input too (vertical PN vector)

if size(PN_input,1) == size(MB,1) %necessary requirement, nb of PNs input must match nb of PNs in MB

 KC_AP =[]; %will be the vector of KC action potential
 
    for i = 1:size(PN_input,2) %loop across time

        % Get KC exitatory post synaptic potential by summing the PN_input of the KCs for each connected PN    
        KC_EPSP(i,:) = sum(PN_input(:,i).*MB);

        % Get the n=nb_KC_firing highest EPSP, and make them fire 1 Action Potential 
        [~,idx] = sort(KC_EPSP(i,:),2,'descend'); 
        
        %create empty vector of KCs Action Potential
        kc_ap = zeros(1,size(MB,2)); % on KCs, time will be vertical
        kc_ap(idx(1:nb_KC_firing)) = 1;
        KC_AP = [KC_AP; kc_ap];%cumulate across time
    end


else
    warning('size PN_input mismatch number of PNs in MB')
end

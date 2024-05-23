%% created by Antoine Wystrach

function W_PN_KCs = create_MB (nb_PNs, nb_KCs, PNperKCs)
% Create the connectivity matrix W between PNs (line) and KCs (row)

a = rand(nb_PNs,nb_KCs); % Create random matrice of PNxKCs
[~,idx] = sort(a,1); %get the indexs per ascending value for each KCs

W_PN_KCs = double(idx <= PNperKCs); % For each KCs, set the N=PNperKCs smallest PN random value to 1, and the rest 0.


%make a warning
if PNperKCs > nb_PNs
    warning ('nb of PNperKCs is higher than nb of PNs, so MB fully connected');
end


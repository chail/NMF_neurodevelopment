function [system_names, system_indices] = load_system_names()
% PURPOSE: load cognitive system names and node assignments to systems
%
% INPUT:
% no inputs
% 
% OUTPUT:
% system_names: 14x1 cell of cognitive system names arranged in
% alphabetical order
%
% system_indices: assignment of each of 264 nodes to a system (with the
% systems arranged in alphabetical order
%--------------------------------------------------------------------------
[~, txt, ~]  = xlsread('./pnc_data/neuralSystem.xlsx', 'B2:B265');
[system_names, ~, system_indices] = unique(txt);
end
function regressed = regress_mvt(mvt, v)
% PURPOSE: regress out the effect of the movement nuisance variable on the
% data
%
% INPUT:
% mvt: vector of movement scores
%
% v: vector of data
%
% OUTPUT:
% regress: vector of data with the movement effect regressed out
%--------------------------------------------------------------------------
p = polyfit(mvt, v, 1);
regressed = v - mvt*p(1);
disp(corr(mvt, regressed));
end
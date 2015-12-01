function DCM = euler321(p);
%function DCM = euler321(p);
%
% Creates directional cosine matrix for euler 321 rotation 
% sequence. 
% 
% Inputs:
%   p    - phi/theta/psi vector, in radians
% 
% Outputs:
%   DCM  - Directional cosine matrix
% 	

% $Id: euler321.m 4852 2013-08-06 22:12:54Z cox $

p=p(:);
cp=cos(p);
sp=sin(p);

DCM=[cp(2)*cp(3), cp(2)*sp(3), -sp(2);
sp(1)*sp(2)*cp(3)-cp(1)*sp(3),sp(1)*sp(2)*sp(3)+cp(1)*cp(3), sp(1)*cp(2);
cp(1)*sp(2)*cp(3)+sp(1)*sp(3),cp(1)*sp(2)*sp(3)-sp(1)*cp(3), cp(1)*cp(2)];


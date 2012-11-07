function f = s2let_mw_axisym_synthesis(f_wav, f_scal, varargin)

% s2let_mw_axisym_synthesis 
% Compute axisymmetric wavelet transform, output in pixel space.
%
% Default usage :
%
%   f = s2let_mw_axisym_synthesis(f_wav, f_scal, <options>)
%
% f_wav contains the input wavelet contributions -- MW sampling,
% f_scal contains the input scaling contributions -- MW sampling,
% f is the output field -- MW sampling,
%
% Option :
%  'Reality'         = { false        [do not assume f real (default)],
%                        true         [assume f real (improves performance)] }
%  'B'               = { Dilation factor; B > 1 (default=2) }
%  'L'               = { Harmonic band-limit; L > 1 (default=guessed from input) }
%  'Downsample'      = { true        [multiresolution algorithm (default)],
%                        false       [full resolution wavelets] }
%  'J_min'           = { Minimum needlet scale to consider;
%                        0 <= J_min < log_B(L) (default=0) }
%
% S2LET package to perform Wavelets transform on the Sphere.
% Copyright (C) 2012  Boris Leistedt & Jason McEwen
% See LICENSE.txt for license details

len = size(f_wav);
temp = f_wav{len};
sz = size(temp);
Lguessed = min([sz(1) sz(2)]);

p = inputParser;
p.addRequired('f_wav'); 
p.addRequired('f_scal', @isnumeric); 
p.addParamValue('B', 2, @isnumeric);   
p.addParamValue('L', Lguessed, @isnumeric);   
p.addParamValue('J_min', 0, @isnumeric); 
p.addParamValue('Downsample', true, @islogical);
p.addParamValue('Reality', false, @islogical);
p.parse(f_wav, f_scal, varargin{:});
args = p.Results;

f_scal_vec = s2let_mw_arr2vec(f_scal);

J = s2let_jmax(args.L, args.B);
f_wav_vec = [];

offset = 0;
for j = args.J_min:J
	if args.Downsample == true
      band_limit = min([ ceil(args.B^(j+1)) args.L ]);
    else
      band_limit = args.L;
    end
    temp = f_wav{j+1-args.J_min};
    for t = 0:band_limit-1
        for p = 0:2*band_limit-2
          ind = offset + t * ( 2 * band_limit - 1) + p + 1;
          f_wav_vec = [f_wav_vec temp(t+1,p+1)];
        end
    end
    offset = offset + band_limit * (2 * band_limit - 1);
end

f_vec = s2let_mw_axisym_synthesis_mex(f_wav_vec, f_scal_vec, args.B, args.L, args.J_min, args.Reality, args.Downsample);
 
f = s2let_mw_vec2arr(f_vec);

end
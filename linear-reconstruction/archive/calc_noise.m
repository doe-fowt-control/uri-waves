function [pxxn, fn] = calc_noise(param, eta_)

fs = param.fs;
wwindow = param.wwindow;
noverlap = param.noverlap;
nfft = param.nfft;

noise_length = 60 * fs;

eta_noise = eta_(end - noise_length: end);

[pxxn, fn] = pwelch(eta_noise, wwindow, noverlap, nfft, fs);



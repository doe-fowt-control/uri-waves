function [stat] = decompose_1g(pram, stat, eta_)

mg = pram.mg;

i1 = stat.i1;
i2 = stat.i2;

eta = eta_(i1:i2, mg);

[A, phi, w] = fft_decomp(pram, eta);

a = A .* cos(phi);
b = A .* sin(phi);

k = w.^2 / 9.81;

stat.k = k;
stat.w = w;
stat.a = a;
stat.b = b;
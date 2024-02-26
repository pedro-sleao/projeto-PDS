// UFPE
// Alunos: Pedro Lucas, Bruno França, Henrique Pedro
// Projeto de Filtro Cancelador de Voz

clear;
clc;

// configurações iniciais
filterType = "wFIR"; // "wFIR", "butt", "cheb1", "notch"
windowType = "kr"; // "re", "kr", "tr"

[y, Fsm, bits] = wavread("EnjoyTheSilence.wav");
y = y(1,:);

// Constantes
//M = 1739; // 1739
fc = 5000;
Fs = 22100;
wc = 2*%pi*fc/Fsm;

if filterType == "wFIR" then
    // kaiser window parameters
    delta = 0.001; // ripple
    deltaOmegazao = 100; // Hz
    deltaOmega = 2*%pi*deltaOmegazao/Fsm;
    A = -20*log10(delta);
    M = ceil((A-8)/(2.285*deltaOmega));
    // Beta
    if A < 21 then
        B = 0
    elseif A <= 50 then
        B = 0.5842*(A - 21)^(0.4) + 0.07886*(A - 21);
    else
        B = 0.1102*(A - 8.7);B = 0.1102*(A - 8.7);
    end
    //
    
    n = linspace(0, M, M+1);
    hd = (sin(%pi*(n - M/2)) - sin(wc*(n - M/2)))./(%pi*(n-M/2)); // Passa-alta
    //hd = sin(wc*(n - M/2))./(%pi*(n - M/2)); // Passa-baixa
    h = hd .* window(windowType, M+1, B);
    
    y_filtered = conv2(y, h);
    
    subplot(321);
    plot2d3(n, h);
    title(gettext("Resposta ao impulso"));
    xlabel("n");
    ylabel("h[n]");
    
elseif filterType == "butt" then
    h = iir(25, 'hp', filterType, (200+fc)/Fsm, [0 0]); // verificar parâmetros com GILSON
    num = flipdim(coeff(h.num), 2);
    den = flipdim(coeff(h.den), 2);
    [y_filtered, zf] = filter(num, den, y)
    
elseif filterType == "cheb1" then
    h = iir(25, 'hp', filterType, (200+fc)/Fsm, [.001 0]); // verificar parâmetros com GILSON
    num = flipdim(coeff(h.num), 2);
    den = flipdim(coeff(h.den), 2);
    [y_filtered, zf] = filter(num, den, y)
    
elseif filterType == "notch" then
    r = 0.99;
    wc1 = 2*%pi*3000/Fsm;
    wc2 = 2*%pi*5000/Fsm;
    
    // Filtro IIR notch de quarta ordem
    
    //num = conv([1, -2*cos(wc2), 1], conv([1, -2*cos(wc1), 1], [1, -2*cos(wc1), 1]));
    //den = conv([1, -2*r*cos(wc2), r^2], conv([1, -2*r*cos(wc1), r^2], [1, -2*r*cos(wc1), r^2]));
    
    num = [1, -(2*cos(wc1) + 2*cos(wc2)), (2 + 4*cos(wc1)*cos(wc2)), -(2*cos(wc1) + 2*cos(wc2)), 1];
    den = [1, -(2*r*cos(wc1) + 2*r*cos(wc2)), (2*r^2 + 4*r^2*cos(wc1)*cos(wc2)), -(2*r^3*cos(wc1) + 2*r^3*cos(wc2)), r^4];
 
    y_filtered = filter(num, den, y);
end


[hzm, fr] = frmag(h, 256); // num, den para filtro notch e h para o resto.
hzm_db = 20*log10(hzm)./max(hzm);

Y = fft(y);
Y_filtered = fft(y_filtered);

fk1 = (0:length(Y)-1)*Fsm/length(Y);
fk2 = (0:length(Y_filtered)-1)*Fsm/length(Y_filtered);

subplot(322);
plot2d(fr*Fsm, hzm);
title(gettext("Resposta na frequência"));
xlabel("f");
ylabel("Magnitude em db");

subplot(323);
plot2d(fk1, Y);
title(gettext("FFT da Música Original"));
xlabel("f");
ylabel("Magnitude em db");

subplot(324);
plot2d(fk2, Y_filtered);
title(gettext("FFT da música filtrada"));
xlabel("f");
ylabel("Magnitude em db");

t = (0:length(y)-1)/Fsm;
subplot(325);
plot2d(t, y);
title(gettext("Música Original"));
xlabel("Tempo (s)");
ylabel("Magnitude");

t_filtered = (0:length(y_filtered)-1)/Fsm;
subplot(326);
plot2d(t_filtered, y_filtered);
title(gettext("Música Filtrada"));
xlabel("Tempo (s)");
ylabel("Magnitude");

playsnd(y_filtered, Fsm);
//wavwrite(3*y_filtered, Fsm, "PDS_MUSICA_PASSABAIXA.wav")

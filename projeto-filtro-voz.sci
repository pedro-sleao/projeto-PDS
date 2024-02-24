// UFPE
// Alunos: Pedro Lucas, Bruno França, Henrique Pedro
// Projeto de Filtro Cancelador de Voz

clear;
clc;

// configurações iniciais
filterType = "wFIR"; // "wFIR", "butt"
windowType = "tr"; // "re", "kr", "tr"

// Filtro FIR hp utilizando janelamento

[y, Fsm, bits] = wavread("EnjoyTheSilence.wav");

// Constantes
//M = 1739; // 1739
fc = 5000;
Fs = 22100;
wc = 2*%pi*fc/Fsm;

if filterType == "wFIR" then
    if windowType == "kr" then
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
    end
    
    if (windowType == "re" || windowType == "tr") then
         M = 1001; // Tentar entender como escolher o M mais adequado
         B = 0;
    end
    
    n = linspace(0, M, M+1);
    hd = (sin(%pi*(n - M/2)) - sin(wc*(n - M/2)))./(%pi*(n-M/2));
    h = hd .* window(windowType, M+1, B);
end

[hzm, fr] = frmag(h, 256);
hzm_db = 20*log10(hzm)./max(hzm);

y_filtered = conv2(y, h);

fk1 = (0:length(fft(y(1,:)))-1)*Fsm/length(fft(y(1,:)))
fk2 = (0:length(fft(y_filtered(1,:)))-1)*Fsm/length(fft(y_filtered(1,:)))

subplot(321);
plot2d3(n, h);
title(gettext("Resposta ao impulso"));
xlabel("n");
ylabel("h[n]");

subplot(322);
plot2d(fr*Fsm, hzm);
title(gettext("Resposta na frequência"));
xlabel("f");
ylabel("Magnitude em db");

subplot(323);
plot2d(fk1, fft(y(1,:)));
title(gettext("FFT da Música Original"));
xlabel("f");
ylabel("Magnitude em db");

subplot(324);
plot2d(fk2, fft(y_filtered(1,:)));
title(gettext("FFT da música filtrada"));
xlabel("f");
ylabel("Magnitude em db");

t = (0:length(y(1,:))-1)/Fsm;
subplot(325);
plot2d(t, y(1,:));
title(gettext("Música Original"));
xlabel("Tempo (s)");
ylabel("Magnitude");

t_filtered = (0:length(y_filtered(1,:))-1)/Fsm;
subplot(326);
plot2d(t_filtered, y_filtered(1,:));
title(gettext("Música Filtrada"));
xlabel("Tempo (s)");
ylabel("Magnitude");

playsnd(y_filtered, Fsm);
//wavwrite(2*y_filtered, Fsm, "PDS_MUSICA_FILTRADA.wav")


clear, clc, close all

addpath('M');
addpath('C');

Tipo = 'normal';
ordem = 3;

%% Fun��es auxiliares
propaga =@(Ein,L,Dhat) ifft(exp(L*Dhat).*fft(Ein));
binomialc = @(n,k) nchoosek(n,k);
t2f = @(x) fftshift(fft(x))/length(x);
f2t = @(x) ifft(ifftshift(x))*length(x);
corta = @(x, indices) x(indices);
P = @(x)  sum(abs(x).^2)/length(x);
erro = @(xteorico, x) 100*P(x - xteorico)/P(xteorico);
dc2ac = @(x) x - mean(x);

%% Parametros de entrada
%% OFDM
Nc = 108;            % N�mero de subportadoras
fc =  1.503e9;         % Frequ�ncia central (Hz)
Deltaf = 9e6;
BW = Nc*Deltaf;     % Bandwidth (Hz)

if mod(Nc, 2) == 0 % par
    F = (-Nc/2:Nc/2-1)*Deltaf + fc; % Nc par
else
    F = (-(Nc-1)/2:(Nc-1)/2)*Deltaf + fc; % Nc par
end

W = 2*pi*F;

if F(1) <= 0 || F(end) > 10e9
    disp('Fora da faixa de frequ�ncias');
    pause
end

%% laser
mIM = 0.02*ones(size(F));
QPSK = [pi/4 3*pi/4 -pi/4 -3*pi/4];
PSK8 = [0 pi/4 pi/2 3*pi/4 pi -3*pi/4 -pi/2 -pi/4];

lambda = 1550e-9;
c = 299792458;

alfa = 5;
kappa = 75e12;  % 	 
P0 = 5e-3;

%% Dados para FFT
N2 = 1;
deltaf = Deltaf/N2;
N = 2^14;
deltat = 1/(N*deltaf);
fa = N*deltaf;
t = 0:deltat:(N-1)*deltat;
f = -fa/2:deltaf:fa/2-deltaf;
indices = 1:N2:length(f);

if fa <= 2*F(end)
    disp('Erro Frequ: fa <= 2*F(end)');
    pause
end

for k = 1:length(F)
    if isempty(find(abs(f) == F(k), 1))
        disp('Amostragem da FFT n�o est� alinhada com espectro OFDM');
        pause
    end
end    

if 2*F(1) > F(end)
    disp('---- Sistema suboitava: 2*F(1) > F(end)')
else
    disp('---- Sistema n�o � suboitava: 2*F(1) <= F(end)')
end

%% fibra
D = 17e-6;
L = 100e3;

beta2 = -D*lambda^2/(2*pi*c);
beta2L = beta2*L;
Dhat = -1j*0.5*beta2*(2*pi*ifftshift(f)).^2;

R = 0.9;
att = 0.25;
attlin = 0.25*1e-4*log(10);

filt = zeros(size(f));
indF = zeros(size(F));
for k = 1:length(F)
    filt(abs(f) == F(k)) = 1;
    indF(k) = find(f == F(k));
end

tic
Nit = 100;
IMDteo = zeros(Nit, N);
IMDap1 = zeros(Nit, N);
IMDap2 = zeros(Nit, N);
IMDpsi = zeros(Nit, N);
SIGteo = zeros(Nit, N);
SIGap1 = zeros(Nit, N);
SIGap2 = zeros(Nit, N);
SIGpsi = zeros(Nit, N);
fprintf('L = %.2fkm, P0 = %.2fmW, mIM = %.2f%%, Nit = %d, kappa = %.2f\n', L/1e3, P0*1e3, mIM(1)*100, Nit,kappa/1e12);
for kit = 1:Nit
    %% laser
    phiIM = QPSK(randi(4, [1, Nc]));

    %%
    IM = 0;
    AM = 0;
    FM = 0;
    Adiab = 0;

    mFM = zeros(size(W));
    phiFM = zeros(size(W));
    dPSI = zeros(size(W));

    for k = 1:Nc
        mFMc = alfa/2*(1 + kappa*P0./(1j*W(k)))*1j*mIM(k)*exp(1j*phiIM(k));
        mFM(k) = abs(mFMc);
        phiFM(k) = angle(mFMc);
        dPSI(k) = phiFM(k) - phiIM(k);
        Adiab = Adiab + kappa*P0*mIM(k)/W(k)*sin(W(k)*t+phiIM(k));
        AM = AM + mIM(k)/2*cos(W(k)*t + phiIM(k));
        IM = IM + mIM(k)*cos(W(k)*t + phiIM(k));
        FM = FM + mFM(k)*sin(W(k)*t + phiFM(k));   
    end

    Pt = P0*(1 + IM);

    if min(Pt) <= 0.1*P0
        disp('Erro! Pot�ncia negativa!!!!!!!!!!!!!!!!!!')
        pause
    end

    %% Calcula Modelos
    %% Modelo te�rico
%     disp('Modelo Te�rico')
    TeoricoNumerico
       
    AproxNumerico
    
%     PequenosSinais
            
    SIGteo(kit,:) = abs(teorico.Idet - teorico.IMPdet).^2;
    SIGap1(kit,:) = abs(aprox1.Idet - aprox1.IMPdet).^2;
    SIGap2(kit,:) = abs(aprox2.Idet - aprox2.IMPdet).^2;
%     SIGpsi(kit,:) = abs(smallsig.Idet - smallsig.IMPdet).^2;
    
    IMDteo(kit,:) = abs(teorico.IMPdet).^2;    
    IMDap1(kit,:) = abs(aprox1.IMPdet).^2;
    IMDap2(kit,:) = abs(aprox2.IMPdet).^2;
%     IMDpsi(kit,:) = abs(smallsig.IMPdet).^2;
end

fprintf('Ind�ce de Modula��o Global: %.3f%%\n', 100*sqrt(P(Pt-P0))/P0);
fprintf('ER = %f [dB]\n', 10*log10(max(Pt)/min(Pt)))
chirp = alfa/2*(log(Pt/P0) + Adiab);
fprintf('Adiab�tico: %.3f%%\n', 100*P(alfa/2*Adiab)/P(chirp));
fprintf('Transiente: %.3f%%\n', 100*P(alfa/2*log(Pt/P0))/P(chirp));

SIRteo = corta(10*log10(mean(SIGteo,1)./mean(IMDteo,1)), indF);
SIRap1 = corta(10*log10(mean(SIGap1,1)./mean(IMDap1,1)), indF);
SIRap2 = corta(10*log10(mean(SIGap2,1)./mean(IMDap2,1)), indF);
% SIRpsi = 10*log10(mean(SIGpsi,1)./mean(IMDpsi,1));
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generaliza��o N-Tons: Aproxima��o linear do logaritmo (Eva Eq. 12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
SIRLogLinear % IMP 3rd ordem validado com analitico eq fechada
toc

%% Gr�ficos
FF = F/1e9;
figure
plot(FF, SIRteo, 'sk', FF, SIRap1, 'or', FF, SIRap2, 'dm', FF, loglinear.SIR, '*b')
legend('Te�rico', 'Log Linear Num�rico', 'Log Quad Num�rico', 'Anal�tico');
xlabel('Frequ�ncia (GHz)');
ylabel('SIR (dB)');



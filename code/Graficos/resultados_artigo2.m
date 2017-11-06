clear, clc, close all

load resultados100km

FF = resultados(1).FF;
SIRteo75 = (resultados(1).SIRteo + resultados(2).SIRteo)/2;
SIRteo40 = (resultados(3).SIRteo + resultados(4).SIRteo)/2;
SIRteo10 = (resultados(5).SIRteo + resultados(6).SIRteo)/2;

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

plot1 = plot(FF, SIRteo75, 'ob', FF, resultados(1).SIReva, 'b', FF, resultados(2).SIReva, '--b',...
     FF, SIRteo40, 'ok', FF, resultados(3).SIReva, 'k', FF, resultados(4).SIReva, '--k',...
     FF, SIRteo10, 'or', FF, resultados(5).SIReva, 'r', FF, resultados(6).SIReva, '--r');

xlabel('Frequency (GHz)', 'Fontsize', 14)
ylabel('SIR (dB)', 'Fontsize', 14)
legend('Simulation', 'Proposed theory up to 3rd order', 'Proposed theory up to 4th order')

set(plot1([1 4 7]),'MarkerSize',2,'Marker','o','LineWidth',1)
set(plot1([2 5 8]),'LineWidth',2)
set(plot1([3 6 9]),'LineWidth',2)
set(gca, 'FontSize', 14)
grid on

set(plot1([6 9]), 'visible', 'off')
set(figure1, 'Position', [100 100 640 550])

% Create ellipse
annotation(figure1,'ellipse',...
    [0.771312500000003 0.169627386502386 0.0320188679245282 0.0961538461538472],...
    'Color',[0 0 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.701218553459123 0.243413711288712 0.219093946540877 0.0747863247863249],...
    'String',{'\kappa P_0 = 75 GHz'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[0 0 1]);

% Create textbox
annotation(figure1,'textbox',...
    [0.698765723270445 0.567402014652019 0.209046776729555 0.0747863247863249],...
    'String',{'\kappa P_0 = 10 GHz'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none',...
    'Color',[1 0 0]);

% Create textbox
annotation(figure1,'textbox',...
    [0.702330974842771 0.402846930846933 0.221106525157229 0.0747863247863249],...
    'String',{'\kappa P_0 = 40 GHz'},...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');

dir = pwd;
cd 'D:\Dropbox\PG\publica��es\artigo2\figs'
saveas(gcf, 'OFDM_Gen_100km', 'fig')
saveas(gcf, 'OFDM_Gen_100km', 'epsc')
cd(dir);
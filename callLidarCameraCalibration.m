clear;
close all;
clc;

param.pathBase= 'D:\Moacir\ensaios\Calibração\LiDAR_Stereo\08_02_2023_B';
param.pathPcl= '\LiDAR\mult\PlanoAjustada';
param.pathImage= '\Camera\L';
param.nameCalibFile= '\out\paramsCalibrationL.mat';

fullPathImg= fullfile(param.pathBase, param.pathImage);
fullPathPC= fullfile(param.pathBase, param.pathPcl);

checkerSize= 50.0;
padding= [0 0 0 0];

% Chama o App de calibração cruzada LiDAR-Câmera: 
lidarCameraCalibrator(fullPathImg, fullPathPC, checkerSize, padding);

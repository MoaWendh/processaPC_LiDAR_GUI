clear;
clc;
close all
data= load('C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\0001.csv');

pc= pointCloud(data(:,1:3));

pcwrite(pc,'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\0001.pcd'); 

pc1= pcread('C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\0001.pcd');

pc2= pcread('C:\Projetos\Matlab\Experimentos\LiDAR_Estereo\Plano\07_11_2022_A\ComFiltro\LiDAR\0001.pcd');

m= [rand(1,1000); rand(1,1000); rand(1,1000)];

pc3= pointCloud(m');

pcwrite(pc3,'C:\Projetos\Matlab\Experimentos\2022.11.25 - LiDAR Com Interferômetro\tst.pcd');

a=0;

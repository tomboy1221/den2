function denoiseBatchTestUD_Banded;
gpuDevice();
addpath('../LASIP');
addpath('../DNCNN/model');
addpath('../DNCNN/utilities');

run /home/cosc/csprh/linux/code/matconvnet-1.0-beta25/matlab/vl_setupnn

validInds = [1 172 73
    2 20  123
    3 252 1757
    4 47  2232
    5 33  642
    6 54  1280
    7 65  827
    8 29  2719
    9 106 2863
    10 119 3200
    11 351 57
    12 404 3200
    13 406 2945
    14 362 270
    15 383 439
    16 366 697
    17 374 1043
    18 378 2645
    19 385 1900
    20 388 2410
    21 773 3184
    22 823 46
    23 877 136
    24 950 2925
    25 952 2478
    26 659 2210
    27 683 523
    28 674 706
    29 665 1892
    30 678 1176];

scratchDir = '/home/cosc/csprh/linux/HABCODE/scratch/HUAWEI';
baseDir = [scratchDir '/Valid3/'];
modelDir = [scratchDir '/Models/'];

psnrInds = 0;

for epochs = 30:5:120
    psnrInds = psnrInds + 1;
    nameOfModel = ['out-epoch-' num2str(epochs) '.mat']; 
    outPSNR1(psnrInds) = multiModelDenoise1(baseDir, nameOfModel,  modelDir, 1, validInds(:,3));
    outPSNR1
    save outPSNR1 outPSNR1
end




function outPSNRMean = multiModelDenoise1(baseDir, nameOfModel,  modelDir, thisBand, validInds)

load borders;
allIndices = 1:30;
modName = ['model_0_' num2str(thisBand) '/' nameOfModel];
lowEdge = borders(thisBand); highEdge = borders(thisBand+1);
bandIms = allIndices((validInds>=lowEdge)&(validInds<highEdge))
for i = 1 : length(bandIms)
    outPSNR(i) = thisDenoise(bandIms(i), baseDir, modName,  modelDir);
end
outPSNRMean = mean(outPSNR);



function PSNR = thisDenoise(ImNum, baseDir, nameOfModel,  modelDir)

load(fullfile(modelDir, nameOfModel));

net = vl_simplenn_tidy(net);
net.layers = net.layers(1:end-1);
net = vl_simplenn_tidy(net);

noisyName = [baseDir 'Noisy/Test_Image_' num2str(ImNum) '.png'];
cleanName = [baseDir 'Clean/Test_Image_' num2str(ImNum) '.png'];

zRGB = im2double(imread(noisyName));
yRGB = im2double(imread(cleanName));
input = single(zRGB);
clean = single(yRGB);

res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test','CuDNN', 'true');

output = input - res(end).x;

[PSNR, SSIM] = Cal_PSNRSSIM(255*clean,255*output,0,0);



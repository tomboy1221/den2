function CropIms;

addpath('../BM3D');
addpath('../LASIP');
addpath('../DNCNN/model');
addpath('../DNCNN/utilities');
run /mnt/storage/home/csprh/code/matconvnet-1.0-beta25/matlab/vl_setupnn

if ismac
    baseDir = '/Users/csprh/tmp/Huawei/Test/';
    load(fullfile('/Users/csprh/Dlaptop/MATLAB/MYCODE/HUAWEI/HUAWEI/DNCNN/model/model_Huwei_All-epoch-19.mat'));
    net = vl_simplenn_tidy(net);
    net.layers = net.layers(1:end-1);
    net = vl_simplenn_tidy(net);
else
    baseDir = '/mnt/storage/home/csprh/scratch/HAB/Huwei/Test/';
    load(fullfile('/mnt/storage/home/csprh/code/HUAWEI/DNCNN/TrainingCodes/DnCNNHuawei/data/model_Huwei_All/model_Huwei_All-epoch-19.mat'));
    net = vl_simplenn_tidy(net);
    net.layers = net.layers(1:end-1);
    net = vl_simplenn_tidy(net);
    
end

outDirBM3D = [ baseDir 'OutBM3D/'];
outDirDnCNN = [ baseDir 'OutDnCNN/'];
mkdir(outDirBM3D);
mkdir(outDirDnCNN);
%run /mnt/storage/home/csprh/code/matconvnet-1.0-beta25/matlab/vl_setupnn



%%%
%net = vl_simplenn_tidy(net);


for i = 29 : 30
    outName = ['Image_' num2str(i) '.png'];
    imName = [baseDir 'Test_Image_' num2str(i) '.png']; 
    
    zRGB = im2double(imread(imName)); % uint8

    %zRGB = im2double(imread([noisyDir thisImName]));
    %yRGB = im2double(imread([cleanDir thisImName]));
    greyzRGB = rgb2gray(zRGB);
    thisSigma = estimate_noise(greyzRGB*255);
    input = single(zRGB);
    res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test');
    %res = simplenn_matlab(net, input); %%% use this if you did not install matconvnet.
    output = input - res(end).x;
    output = round(output*255);
    output(output<0) = 0;
    output(output>255) = 255;
    output = uint8(output);
    imwrite(output,[outDirBM3D outName]);
    
    [PSNR, output] = CBM3D(zRGB, zRGB, thisSigma,'high',0);
    output = round(output*255);
    output(output<0) = 0;
    output(output>255) = 255;
    output = uint8(output);
    imwrite(output,[outDirDnCNN outName]);
    
end






%pause;




toc;

function output = getThisPath(baseDir, classesA,imName,cleanNoisy)

for ii = 1: length(classesA)
    thisClass = classesA{ii};
    thisPath = dir ([baseDir thisClass cleanNoisy imName]);
    if length(thisPath) == 1 
        output = [baseDir thisClass cleanNoisy imName];
    end
end




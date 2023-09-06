% gpuDeviceCount
% gpuDevice(1)
% gpuDeviceTable


meas = ones(1000)*3; % 1000-by-1000 matrix
gn   = rand(1000,"gpuArray")/100 + 0.995; 
offs = rand(1000,"gpuArray")/50  - 0.01;
corrected = arrayfun(@myCal,meas,gn,offs);
results = gather(corrected);

function c = myCal(rawdata, gain, offset)
    c = (rawdata .* gain) + offset;
end
function []= recorderTF(app)
%   recorderTF  是接收信号时调用的计时器函数
%   在此处 mode=0时在寻找前导码， mode=1时在寻找包长度, mode=2时在接收包
%   
myRecording = getaudiodata(app.myRecorder);
plot(app.UIAxes, myRecording(end-24000:end));
[m p] = max(myRecording(end-4800:end));
app.Gauge.Value = m*100;        
end


function []= recorderTF(app)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
            myRecording = getaudiodata(app.myRecorder);
            plot(app.UIAxes, myRecording(end-24000:end));
            [m p] = max(myRecording(end-4800:end));
            app.Gauge.Value = m*100;
end


function beepbeepTF(app)
%   beepbeepTF 
%   beepbeep测距时的timer函数
%   在此处，当beepbeep_mode=A时
%   mode=1 
    myRecording = getaudiodata(app.myRecorder);
    plot(app.UIAxes, myRecording(end-24000:end));
    [m p] = max(myRecording(end-4800:end));
    app.Gauge.Value = m*100;
    
    if app.beepbeep_mode == 'A'
        
    elseif app.beepbeep_mode == 'B'
        
    end

end


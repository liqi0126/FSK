function beepbeepTF(app)
%   beepbeepTF 
%   beepbeep测距时的timer函数
%   在此处，当beepbeep_mode=A时
%   mode=1时，等待接收自己的beepbeep信号，mode=2时，等待接收B的beepbeep信号，mode=3时，等待接受B的tcp信息。
%   在此处，当beepbeep_mode=B时
%   mode=1时，等待接收到A的信号后，即刻发出beepbeep信号，mode=2时，等待接收到自己的信号后，即刻发出tcp信息。
    myRecording = getaudiodata(app.myRecorder);
    plot(app.UIAxes, myRecording(end-24000:end));
    [m p] = max(myRecording(end-4800:end));
    app.Gauge.Value = m*100;
    
    if app.beepbeep_type == 'A'
        if app.beepbeep_mode == 1
            start_pos = position(myRecording(end - app.Fs * 0.6,end), app.chirp_signal, app.chirp_f0, app.chirp_f1, app.chirp_duration);
            if start_pos ~= -1
               app.tA1 = start_pos;
               app.beepbeep_mode = 2;
               app.mode2Lamp.Color = [0 1 0];
            end
        elseif app.beepbeep_mode == 2
            start_pos = position(myRecording(end-app.Fs * 0.6, end), app.chirp_signal, app.chirp_f0, app.chirp_f1, app.chirp_duration);
            if start_pos ~= -1
               app.tA3 = start_pos;
               app.beepbeep_mode = 3;
               app.mode3Lamp.Color = [0 1 0];
            end
        elseif app.beepbeep_mode == 3
            if app.data_recv ~= -1
                app.distEditField.Value = 0.5 * 340 * ((app.tA3 - app.tA1) - app.data_recv) / app.Fs + app.dA + app.dB;
                app.beepbeep_mode = 1;
                app.mode2Lamp.Color = [1 0 0];
                app.mode3Lamp.Color = [1 0 0];
            end
        end
    elseif app.beepbeep_type == 'B'
        if app.beepbeep_mode == 1
            start_pos = position(myRecording(end - app.Fs * 0.6,end), app.chirp, app.f0, app.f1, app.duration);
            if start_pos ~= -1
               play_chirp;
               app.beepbeep_mode = 2;
               app.mode2Lamp.Color = [0 1 0];
            end
        elseif app.beepbeep_mode == 2
            start_pos = position(myRecording(end - app.Fs * 0.6,end), app.chirp, app.f0, app.f1, app.duration);
            if start_pos ~= -1
               app.tB3 = start_pos;
               tcp_client(app, app.tB3 - app.tB1);
               app.beepbeep_mode = 1;
               app.mode2Lamp.Color = [1 0 0];
            end
        end
    end

end


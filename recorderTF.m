function []= recorderTF(app)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
            myRecording = getaudiodata(app.myRecorder);
            plot(app.UIAxes, myRecording(end-24000:end));
            [m p] = max(myRecording(end-4800:end));
            app.Gauge.Value = m*100;
            
            if app.isFindingStart == true
                data = myRecording(end-32000:end);
                app.pStart;
                
            elseif app.isdemoding == true
                if length(myRecording) - app.pStart > app.pLen
                    code = my_FSK_demod(data, app.Fs, app.duration, app.f0, app.f1 );
                    app.outStr = [app.outStr int2str(code)];
                    app.recvInfo.Value = app.outStr;
                    app.isFindingStart = true;
                    app.isdemoding = false;
                end
            end
                
             
            
end


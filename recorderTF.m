function []= recorderTF(app)
%   recorderTF  是接收信号时调用的计时器函数
%   在此处 mode=0时在寻找前导码， mode=1时在寻找包长度, mode=2时在接收包
%   
            myRecording = getaudiodata(app.myRecorder);
            plot(app.UIAxes, myRecording(end-24000:end));
            [m p] = max(myRecording(end-4800:end));
            app.Gauge.Value = m*100;
            if app.mode == 1    % 寻找前导码  
                data = myRecording(end-32000:end);
                app.pStart = position(data, app.preamble_code, app.f0, app.f1, app.duration);
                if app.pStart ~= -1
                    app.mode = 2;
                end
            elseif app.mode == 2    % 寻找包长度
                if length(myRecording) - app.pStart > 36400
                    app.pLen = decode_header(myRecording(app.pStart, end), app.Fs, app.duration, app.f0, app.f1, app.preamble_bit_num);
                    app.mode = 3;
                end
            elseif app.mode == 3    % 接收包
                if length(myRecording) - app.pStart > app.pLen
                    code = my_FSK_demod(myRecording(app.pStart,app.pStart+app.pLen), app.Fs, app.duration, app.f0, app.f1 );
                    app.outStr = [app.outStr int2str(code)];
                    app.recvInfo.Value = app.outStr;
                    
                    app.mode = 1;
                end
            end
                
             
            
end


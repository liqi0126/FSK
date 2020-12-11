function tcp_server(app)
%TCP_SERVER 建立tcp/ip连接的主机
%   此处显示详细说明
t_server = tcpip('0.0.0.0', app.port, 'NetwordRole', 'server');
fopen(t_server);
while(1)
    if t_server.BytesAvailable > 0
        t_server.BytesAvailable
        break;
    end
end
pause(1);
app.data_recv = fread(t_server, t_server.ByteAvailable);
fclose(t_server);
end


function tcp_client(app, send_data)
%TCP_CLIENT ��Ϊtcp�ͻ��˷�����Ϣ
t_client = tcpip(app.ip, app.port, 'NetworkRole', 'client');
t_client.OutputBuffersize = 1000000;
fopen(t_client);

pause(1);
fwrite(t_client, send_data);
pause(1);
fclose(t_client);
end


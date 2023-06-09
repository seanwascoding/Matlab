% Server

clc;

% Create TCP/IP server
% server = tcpclient('localhost', 65500);
% server = tcpserver(65500)

% Close & open TCP/IP connect
% echotcpip("off")
% echotcpip("on",65500)

% reset the timeout value
server.Timeout=5;

% read data from client
read(t,50,'int8')

%% Timer

clc;

% setup server
server.Timeout=5;
configureTerminator(server, "CR/LF");

% Create timer & name
t = timer;
t.Name='timer';

% setup
t.Period=5;                                %the time between execute
t.TimerFcn={@myTimerFcn,server};     %function
t.StartDelay=1;                            %the gap between start and first-function
t.ExecutionMode='fixedSpacing';            %Execution Mode (can search on official-web)
t.ErrorFcn='disp("An error has occured")';

% TasksToExecute 為執行次數
t.TasksToExecute=Inf;

% start
% 當計時器到期時，MATLAB 調用指定的 TimerFcn 函數。 當TimerFcn函數開始執行時，定時器會暫停，等待TimerFcn函數執行完畢。
start(t);

% function
function myTimerFcn(t, event, server)
    clc;
    disp('func start')

    % input data
    name=[];
    state=[];
    name_length=read(server, 1, "string")
    if ~isempty(name_length)
        name=read(server, str2num(name_length), "string")
        if ~isempty(name)
            state = read(server, 1, "string")
        end
    end

    % funtion
    if ~isempty(name)
        if (state == '1')
            gray(name)
        elseif (state == '2')
            encryption(name)
        elseif (state == '3')
            decryption(name)
        elseif (state == '4')
            colorimageencrypt(name)
        elseif (state == '5')
            colorimagedecrypt(name)
        end
    end

    % output data
    if ~isempty(state)
        write(server,state);
        flush(server);
    end
    disp('func end')
end


%%stop(t)
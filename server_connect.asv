%% checked gpu count
gpuDeviceCount;
gpuDevice
gpuDeviceTable;

%% Server

clc;

% Create TCP/IP server
% server = tcpclient('localhost', 65500);
server = tcpserver(65500);

% Close & open TCP/IP connect
% echotcpip("off")
% echotcpip("on",65500)

% reset the timeout value
% server.Timeout=5;

% read data from client
% read(t,50,'int8')

%% Timer

clc;

% setup parfeval
% gpuDevice(1)
f(1)=parfeval(@strat_server, 1, 5);
fetchOutputs(f);
% delete(f(1));
f(1)=[];
numel(f)

% setup server
server.Timeout=5;
get(server, 'OutputBufferSize')
get(server, 'InputBufferSize')
bufferSize = 4096; % 設置緩衝區大小為 4096 字節
set(server, 'OutputBufferSize', bufferSize);
set(server, 'InputBufferSize', bufferSize);
configureTerminator(server, "CR/LF");

% Create timer & name
t = timer;
t.Name='timer';

% setup
t.Period=5;                                %the time between execute
t.UserData=f;
t.TimerFcn={@myTimerFcn,server};           %function
t.StartDelay=1;                            %the gap between start and first-function
t.ExecutionMode='fixedSpacing';            %Execution Mode (can search on official-web)
t.ErrorFcn='disp("An error has occured")';

% https://www.mathworks.com/help/matlab/ref/timer.html


% TasksToExecute 為執行次數
t.TasksToExecute=Inf;

% start
% 當計時器到期時，MATLAB 調用指定的 TimerFcn 函數。 當TimerFcn函數開始執行時，定時器會暫停，等待TimerFcn函數執行完畢。
start(t);

% function
function myTimerFcn(t, ~, server)
    clc;
    disp('func start')
   
    f=t.UserData;

    % input data
    name=[];
    state=[];
    name_length=read(server, 3, "string")
    if ~isempty(name_length)
        name=read(server, str2num(name_length), "string")
        if ~isempty(name)
            state = read(server, 1, "string")
        end
    end

    % funtion
    if ~isempty(name)
        if (state == '1')
            % gray(name)
            % test(name)
            % numel(f)
            f(numel(f)+1)=parfeval(@test, 1, name);
            % f(numel(f)+1)=parfeval(@worker, 1, name);
            % run_test=arrayfun(@test, name);
            % results = gather(run_test);
            % write(server,name);
        elseif (state == '2')
            f=encryption(name)
        elseif (state == '3')
            f=decryption(name)
        elseif (state == '4')
            f=colorimageencrypt(name)
        elseif (state == '5')
            f=colorimagedecrypt(name)
        end
    end

    for j=numel(f):-1:1
        if(f(j).State == "finished")
            disp("working")
            [~, value]=fetchNext(f(j));
            % delete(f(j))
            f(j)=[];
            write(server,value);
        end
    end

    disp("mission in progress:" + num2str(numel(f)));

    % output data
    % if ~isempty(name)
    %     write(server,name);
    %     %flush(server);
    % end

    t.UserData=f;

    disp('func end')
end


%%stop(t)

function output=strat_server(t)
    pause(5)
    output=t;
end

% function result=worker(name)
%     run_test=arrayfun(@test, name);
%     result = gather(run_test);
% end
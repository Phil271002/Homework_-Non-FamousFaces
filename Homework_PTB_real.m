%% Homework - a full experiment:

%{
Take everything you’ve learned in the last hours and put
it together, i.e.:
• Load from Internet famous and non famous faces
• Present a fix cross, then a mask/“noisy square” for
some jittered time, then briefly show a random ’face’,
repeat/loops for many faces/trials …
• OPTIONAL: measure the time it takes to press a
response button (e.g. Famous ↑, Non, ↓), check
“KbCheck”
• OPTIONAL: repeat it (i.e. loop!) and calculate the
average RT on 50 trials! Do the same with Mama :-)
%}

% Base
myScreen = 0;
myWindow = Screen('OpenWindow', myScreen, [127 127 127]);

white = WhiteIndex(myWindow);
black = BlackIndex(myWindow);
gray = (white+black)/2;

[winX, winY] = Screen('WindowSize', myWindow);
x = winX/2;
y = winY/2;

% Ordner
famousFolder    = 'Stimuli/FamousFaces';
nonfamousFolder = 'Stimuli/NonFamousFaces';

% Famous
famousFiles = dir(fullfile(famousFolder, '*.png'));
famousTex = cell(1, length(famousFiles));

for i = 1:length(famousFiles)
    img = imread(fullfile(famousFolder, famousFiles(i).name));
    famousTex{i} = Screen('MakeTexture', myWindow, img);
end

% Non-Famous
nonfamousFiles = dir(fullfile(nonfamousFolder, '*.png'));
nonfamousTex = cell(1, length(nonfamousFiles));


for i = 1:length(nonfamousFiles)
    img = imread(fullfile(nonfamousFolder, nonfamousFiles(i).name));
    nonfamousTex{i} = Screen('MakeTexture', myWindow, img);
end

% Design
nTrials = 20;
conditions = [ones(1, nTrials/2), zeros(1, nTrials/2)];
conditions = Shuffle(conditions);

% Prepare data storage
RT        = nan(1, nTrials);
response  = nan(1, nTrials);   % 1 = up, 0 = down
accuracy  = nan(1, nTrials);   % optional

% Define Keyboard
KbName('UnifyKeyNames');
keyFamous    = KbName('UpArrow');
keyNonFamous = KbName('DownArrow');
keyEsc       = KbName('ESCAPE');

% Create Fixationcross
fixCross=ones(50,50)*gray;       % 50x50 Pixel, alle grau
fixCross(22:28,:)=black;         % horizontal
fixCross(:,22:28)=black;         % vertikal

fixcrossTexture = Screen('MakeTexture',myWindow,fixCross);

for trial = 1:nTrials
    
    % Fixation
    Screen('DrawTexture', myWindow, fixcrossTexture);
    Screen('Flip',myWindow);
    WaitSecs(2);
    
    % Mask (white)
    jitter = 0.3 + rand * 0.4;
    Screen('FillRect', myWindow, white);
    Screen('Flip', myWindow);
    WaitSecs(jitter);
    
    % Background gray again
    Screen('FillRect', myWindow, gray);
    
    % Condition
    condition = conditions(trial);
    
        if condition == 1   % famous
            idx = randi(length(famousTex));
            faceTex = famousTex{idx};
        else
            idx = randi(length(nonfamousTex));
            faceTex = nonfamousTex{idx};
        end
    
    % Stimulus
    Screen('DrawTexture', myWindow, faceTex);
    tStim = Screen('Flip', myWindow); % Time 
    WaitSecs(0.5); %Stimuli only 200ms 
    
    % Danach neuen Hintergrund zeichnen
    Screen('FillRect', myWindow, gray);
    Screen('Flip', myWindow); 
    
    % Response
    KbReleaseWait;
    responseGiven = false;
    
    while ~responseGiven
        [keyIsDown, tKey, keyCode] = KbCheck;
        
        if keyIsDown
            if keyCode(keyFamous)
                rt = tKey - tStim;
                response(trial) = 1;
                responseGiven = true;
                
            elseif keyCode(keyNonFamous)
                rt = tKey - tStim;
                response(trial) = 0;
                responseGiven = true;
               
            elseif keyCode(keyEsc)
                Screen('CloseAll');
                return;
            end
        end
    end
    
    RT(trial)   = rt;
    cond(trial) = condition;
    accuracy(trial) = (response(trial) == condition);
end

KbWait;
Screen('CloseAll');

%{ 
noch zu verbessern:
    -NonFamous-Bilder alle schwarz-weiß
    -gerade vorgegeben Trial Anzahl (20) => ich will n = Anzahl Bilder
    (Famous+ NonFamous)
    -
%}
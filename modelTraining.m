clc;clear function;close all;
obsInfo = rlNumericSpec([13 1]); %Specifies the dimension of the observation state.
actInfo = rlNumericSpec([5 1], ...
    "UpperLimit", 1, ...
    "LowerLimit", [0; -1; -1; -1; -1]); %Specifies the dimension of the action state
%have to look into the action space once for the correct dimenstion


env = rlSimulinkEnv('f16', 'f16/RL Agent', obsInfo, actInfo, 'UseFastRestart', 'off');
env.ResetFcn = @(in)localResetFcn(in); %standard line, randomize the initial condition
rng(0); %seed helps in reproducing the results from random generator.

%SETTING UP THE AGENT PARAMETERS

opt = rlDDPGAgentOptions;
opt.NoiseOptions.StandardDeviationDecayRate = 1e-4;
opt.SampleTime = 0.2;
opt.MiniBatchSize = 256;

%SETTING UP THE ACTOR PARAMETERS
actorOpts = rlOptimizerOptions;
actorOpts.LearnRate = 1e-3;
actorOpts.GradientThreshold = 1;
opt.ActorOptimizerOptions = actorOpts;
%SETTING UP THE CRITIC PARAMETERS
criticOpts = rlOptimizerOptions;
criticOpts.LearnRate = 1e-3;
criticOpts.GradientThreshold = 1;
opt.CriticOptimizerOptions = criticOpts;

agent = rlDDPGAgent(obsInfo, actInfo, opt); %this creates default neural networks

%Training options:
trainAgentOpt = rlTrainingOptions();
trainAgentOpt.MaxEpisodes = 5000;
trainAgentOpt.MaxStepsPerEpisode = 150;
trainAgentOpt.StopTrainingCriteria = "AverageReward";
trainAgentOpt.StopTrainingValue = -50;
trainAgentOpt.ScoreAveragingWindowLength = 5;


trainingAgent = train(agent, env, trainAgentOpt);

%The reset function:

function in = localResetFcn(in)
psi_rad = 2*180*rand();
%funcoptions = get_param('f16/JSBSim','Description');
%fprintf(funcoptions)
%set_param('f16/JSBSim', 'psi_Rad', num2str(psi_rad));
%set_param('f16/Subsystem1/target_heading', 'Value', num2str(psi_rad));
xml_write_init(30000, 750, 0, 0, 47, 122, 0, 0, psi_rad, 0);
end
function xml_write_init(altitude, ubody, vbody, wbody, latitude, longitude, phi, theta, psi, beta)
    % Validate input arguments
    inputFilePath = 'C:\Users\sherwin kumar\Desktop\Poster\GAMES\JSBSim\aircraft\f16\f16_init.xml';
    outputFilePath = 'C:\Users\sherwin kumar\Desktop\Poster\GAMES\JSBSim\aircraft\f16\f16_init.xml';
  
    % Read existing XML file
    xmlDoc = xmlread(inputFilePath);
    root = xmlDoc.getDocumentElement;

    % Update child elements with the provided values
    updateElement(root, 'altitude', altitude);
    updateElement(root, 'ubody', ubody);
    updateElement(root, 'vbody', vbody);
    updateElement(root, 'wbody', wbody);
    updateElement(root, 'latitude', latitude);
    updateElement(root, 'longitude', longitude);
    updateElement(root, 'phi', phi);
    updateElement(root, 'theta', theta);
    updateElement(root, 'psi', psi);
    updateElement(root, 'beta', beta);

    % Write the updated XML to file
    xmlwrite(outputFilePath, xmlDoc);
end

function updateElement(root, name, value)
    % Update the text content of the specified element
    element = root.getElementsByTagName(name).item(0);
    if ~isempty(element)
        element.setTextContent(sprintf('%.1f', value));
    else
        error('Element %s not found in XML file.', name);
    end
end
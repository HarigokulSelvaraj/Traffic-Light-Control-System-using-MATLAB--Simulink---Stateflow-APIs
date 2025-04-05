close_system("traffic_signal");
clc;
clear;
% Traffic Signal Model
sfnew traffic_signal;
% Open Simulink Model
open_system("traffic_signal");
% Configuration Setting
set_param("traffic_signal","Solver","FixedStepDiscrete");
set_param("traffic_signal","FixedStep","1");
set_param("traffic_signal","StopTime","300");
% Getting Root Object
rt = sfroot;  
% Search for Chart within the model
ch = find(rt,"-isa","Stateflow.Chart",Path = "traffic_signal/Chart");
% Action Language
ch.ActionLanguage = "C";
% States Creation
red = Stateflow.State(ch);
red.Position = [100 200 100 100];
red.LabelString ="Red"+newline+"during:"+newline+" rled = 1;"+newline+"exit:"+newline+" rled = 0;";
green = Stateflow.State(ch);
green.Position = [100 400 100 100];
green.LabelString ="Green"+newline+"during:"+newline+" gled = 1;"+newline+"exit:"+newline+" gled = 0;";
yellow = Stateflow.State(ch);
yellow.Position = [400 300 100 100];
yellow.LabelString = "Yellow"+newline+"during:"+newline+" yled = 1;"+newline+"exit:"+newline+" yled = 0;";
% Transitions
t1 = Stateflow.Transition(ch);
t1.Source = red;
t1.Destination = green;
t1.LabelString = "after(30,sec)";
t1.SourceOClock = 6;
t1.LabelPosition = [130 320 100 100];
t2 = Stateflow.Transition(ch);
t2.Source = green;
t2.Destination = yellow;
t2.LabelString = "after(25,sec)";
t2.LabelPosition = [250 300 100 100];
t2.SourceOClock = 3;
t3 = Stateflow.Transition(ch);
t3.Source = yellow;
t3.Destination = red;
t3.LabelString = "after(5,sec)";
t3.LabelPosition = [250 150 100 100];
t3.SourceOClock = 0;
% Default Transition
t0 = Stateflow.Transition(ch);
t0.Destination = red;
t0.DestinationOClock = 0;
t0.SourceEndpoint = t0.DestinationEndpoint-[0 30];
t0.Midpoint = t0.DestinationEndpoint-[0 30];
% Setting Data and Scope
rled = Stateflow.Data(ch);
rled.Name = "rled";
rled.Scope = "Output";
rled.Props.Type.Method = "Built-in";
rled.DataType = "single";
gled = Stateflow.Data(ch);
gled.Name = "gled";
gled.Scope = "Output";
gled.Props.Type.Method = "Built-in";
gled.DataType = "single";
yled = Stateflow.Data(ch);
yled.Name = "yled";
yled.Scope = "Output";
yled.Props.Type.Method = "Built-in";
yled.DataType = "single";
% add block using Simulink API
add_block("built-in/Scope","traffic_signal/S1","ShowLegend", "on");
add_block("built-in/Mux","traffic_signal/M1");
add_block("built-in/ToWorkspace", "traffic_signal/T1");
add_block("simulink_hmi_blocks/Lamp","traffic_signal/Lamp1");
add_block("simulink_hmi_blocks/Lamp","traffic_signal/Lamp2");
add_block("simulink_hmi_blocks/Lamp","traffic_signal/Lamp3");
% Simulink HMI
blockpath = Simulink.BlockPath("traffic_signal/Chart");
ptr = getSimulinkBlockHandle("traffic_signal/Chart");
p = get(ptr)
sig1 = Simulink.HMI.SignalSpecification;
sig1.BlockPath = blockpath;
sig1.OutputPortIndex = 1;
stateColors(1).Value = 1;
stateColors(1).Color = [1 0 0]; %[r g b]
sig2 = Simulink.HMI.SignalSpecification;
sig2.BlockPath = blockpath;
sig2.OutputPortIndex = 2;
stateColors(2).Value = 1;
stateColors(2).Color = [0 1 0];
sig3 = Simulink.HMI.SignalSpecification;
sig3.BlockPath = blockpath;
sig3.OutputPortIndex = 3;
stateColors(3).Value = 1;
stateColors(3).Color = [1 1 0];
% set param 
set_param("traffic_signal/T1", "SaveFormat", "Structure with Time","Variablename","data");
set_param("traffic_signal/S1","NumInputPorts","3");
set_param("traffic_signal/M1","Inputs","3");
set_param("traffic_signal/Lamp1","Binding",sig1); 
set_param("traffic_signal/Lamp2","Binding",sig2);
set_param("traffic_signal/Lamp3","Binding",sig3);
set_param("traffic_signal/Lamp1","StateColors",stateColors(1));
set_param("traffic_signal/Lamp2","StateColors",stateColors(2));
set_param("traffic_signal/Lamp3","StateColors",stateColors(3));
% add line
add_line("traffic_signal","Chart/1","S1/1");
add_line("traffic_signal","Chart/2","S1/2");
add_line("traffic_signal","Chart/3","S1/3");
add_line("traffic_signal","Chart/1","M1/1");
add_line("traffic_signal","Chart/2","M1/2");
add_line("traffic_signal","Chart/3","M1/3");
add_line("traffic_signal","M1/1","T1/1");
% Simulink Block Arrangement
Simulink.BlockDiagram.arrangeSystem("traffic_signal");
% viewing the chart
view(ch);
% Simulation 
sim("traffic_signal");
% Extracting the signal values and time
timeData = ans.data.time;
signalData = ans.data.signals.values;
redData = ans.data.signals.values(:,1);
greenData = ans.data.signals.values(:,2);
yellowData = ans.data.signals.values(:,3);
% Creating a table with the specified variable names
T = table(timeData, redData, greenData, yellowData, 'VariableNames', {'Time', 'Red', 'Green', 'Yellow'} );
% Writing the table to an excel sheet
writetable(T,"My_Traffic_signal.xls");

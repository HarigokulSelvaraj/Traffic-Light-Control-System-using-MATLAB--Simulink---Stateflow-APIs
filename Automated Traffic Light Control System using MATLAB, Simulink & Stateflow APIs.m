clc;
clear;
%Creating Stateflow model
sfnew stateflow_mscript;
%Open simulink model
open_system("stateflow_mscript");
%setting Configuration parameters
set_param("stateflow_mscript","Solver","FixedStepDiscrete");
set_param("stateflow_mscript","FixedStep","1");
set_param("stateflow_mscript","StopTime","50");
%Getting Root object
rt = sfroot;
% Search for Stateflow charts within the model
ch = find(rt, "-isa", "Stateflow.Chart",Path = "stateflow_mscript/Chart");
%Action Language
ch.ActionLanguage ="C";
%states creation
p = Stateflow.State(ch);
p.Position = [50 100 500 400];
p.LabelString = "Parent";
p.IsGrouped = false;
p.IsSubchart = false;
s1 = Stateflow.State(ch);
s1.LabelString = "On"+newline+"entry:"+newline+" x=0;"+newline+"during:"+newline+" x=x+1;";
s1.Position = [100 200 100 100];
s2 = Stateflow.State(ch);
s2.LabelString = "Off"+newline+"entry:"+newline+"during:"+newline+" x=x-1;";
s2.Position = [300 200 100 100];
%Transitions
t1 = Stateflow.Transition(ch);
t2 = Stateflow.Transition(ch);
t1.Source = s1;
t1.Destination = s2;
t1.SourceOClock = 2;
t1.LabelString = "[x >= 10]";
t1.LabelPosition = [200 190 100 100];
t2.Source = s2;
t2.Destination = s1;
t2.SourceOClock = 8;
t2.LabelString = "[x <= 0]";
t2.LabelPosition = [200 290 100 100];
%Default Transition
%parent
p0 = Stateflow.Transition(ch);
p0.Destination = p;
p0.DestinationOClock = 0;
p0.SourceEndpoint = p0.DestinationEndpoint-[0 20];
p0.Midpoint = p0.DestinationEndpoint-[0 10];
%Subchart
t0 = Stateflow.Transition(ch);
t0.Destination = s1;
t0.DestinationOClock = 0;
t0.SourceEndpoint = t0.DestinationEndpoint-[0 30];
t0.Midpoint = t0.DestinationEndpoint-[0 30];
%Setting Data and Scope
x = Stateflow.Data(ch);
x.Name = "x";
x.Scope = "Output";
x.Props.Type.Method = "Built-in";
x.DataType = "single";
%Viewing the Chart
view(ch);
%add block
add_block("built-in/Scope","stateflow_mscript/S1");
%add line
add_line("stateflow_mscript","Chart/1","S1/1");
%Arrange
Simulink.BlockDiagram.arrangeSystem("stateflow_mscript");
%Simulation of the model 
sim("stateflow_mscript");
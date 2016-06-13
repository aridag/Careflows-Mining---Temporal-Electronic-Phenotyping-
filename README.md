# Careflows-Mining---Temporal-Electronic-Phenotyping-

PROJECT
A carflow mining algorithm to mine the most frequent histories in event logs, based on
- a discovery phase, where frequent sequences (careflows) of events are extracted from the logs; 
- a temporal enrichment phase, where the careflows are augmented with temporal information;
The results are a .dot file, containing the mined carflows and a txt file containing the IDs of instances undergoing each of the mined carflows.

FILES
MainCFM_eng.m - the main function to lunch from Matlab console.
findHistory_eng.m - the file containing the algorithm main instructions to mine careflows.
Example.txt - an input file example

INPUT FILE FORMAT
% format for file: 5 columns
% Column 1: case identifier (e.g patient ID)
% Column 2: start date of the event (format dd/mm/yyyy)
% Column 3: end date of the event (format dd/mm/yyyy)
% Column 4: event name (string)
% Column 5: event type (for colours) 

INSTRUCTIONS
1) In the MainCFM_eng.m - specify the name of the INPUT file in the instruction
[idcod_orig dateStart dateEnd eventStr_orig evColour_orig]=textread('Example.txt','%d %s %s %s %s','delimiter','\t');

2) Define parameters
% CountPZ		= Minimum number of patients that undergo an event
% PercCount		= if PercCount==1 la variable CountPZ is computed as a proportion on  
%				  the entire population (it should be between 0 and 1)
% LengthMax		= History maximum length to compute
% Threshold		= Support threshold

3) Eventually change the name of the output files:
- A Dot file is computed and saved in the project folder
fid=fopen('HISTdot_EventLog_ENG.dot','w');

- A txt file containing the mined carflows and the ID of the instances is saved in the project folder
fidHist=fopen('HIST_EventLog_ENG.txt','w');

4) Run the MainCFM_eng.m file from Matlab console.

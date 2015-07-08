function extractVars( filename )
%Variable Extractor This function extracts variables from a result data
%file.
%   Detailed explanation goes here

strNum = regexp(filename, 'SimOut(\d*)', 'tokens');
strNroom = regexp(filename, 'SimOut(\d)', 'tokens');

Num = str2double(strNum{1});
Nroom = str2double(strNroom{1});
    
evalin('base', ['axisX = linspace(0, 50, size(' sprintf('SimOut%d', Num) '.get(' sprintf('''tempRoom%d''', Nroom) '), 1));']);

for ii = 1:Nroom
    
    evalin('base', [sprintf('tempRoom%d', ii) ' = ' sprintf('SimOut%d', Num) '.get(''' sprintf('tempRoom%d', ii) ''');']);
    evalin('base', [sprintf('heatCost%d', ii) ' = ' sprintf('SimOut%d', Num) '.get(''' sprintf('heatCost%d', ii) ''');']);
    evalin('base', [sprintf('coolCost%d', ii) ' = ' sprintf('SimOut%d', Num) '.get(''' sprintf('coolCost%d', ii) ''');']);

end

evalin('base', ['clearvars ' sprintf('SimOut%d', Num) ' handles']);

end


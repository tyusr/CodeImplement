function y = get_label(CountOfSampleEachClass)
y = zeros(1,sum(CountOfSampleEachClass));
index = 1;
label = 1;
for i = 1:length(CountOfSampleEachClass)
    for j = 1:CountOfSampleEachClass(i)
        y(1,index) = label;
        index = index + 1;
    end
    label = label + 1;
end
end
function [blockx blockz]=puttogether(blockxl, blockxr, blockzl, blockzr)

%ensure no duplicates
if blockxr(end)==blockxl(end) && blockzr(end)==blockzl(end)
    blockzr(end)=[];
    blockxr(end)=[];
end

blockx=[blockxr fliplr(blockxl)];
blockz=[blockzr fliplr(blockzl)];
        
end
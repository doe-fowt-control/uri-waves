function array = update_buffer(pram, array, update_info)
% shift old data back by new buffer acquisition, add new

buffer_size = pram.buffer_size;

% take newest data, shift by the size of the new data
array(1:end-buffer_size, :) = array(buffer_size+1: end, :);

% add new data to the end of the old array
array(end-buffer_size + 1:end, :) = update_info;
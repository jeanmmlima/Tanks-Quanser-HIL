function [ L1,L2 ] = lerNiveis( board,channels )

%lendo nivel atual dos tanques
levels = hil_read_analog(board,channels) * 6.25;
L1 = levels(1);
L2 = levels(2);

end


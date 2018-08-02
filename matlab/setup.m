function [ placa ] = setup()
btype = 'q8_usb';
bnum = '0';
placa = hil_open(btype, bnum);

end


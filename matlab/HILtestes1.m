%%parametros
chread = [0 1];
chwrite = [0];
h = 0.01;
i = 1;

%abre conexao com a placa
board = setup();

% SP
sp = 15;

%ganhos
Kp = 2;

while(i < 1000)
    L = lerNiveis(board,chread);
    L1 = L(1);
    
    text = ['Nivel Tanque 1 = ',num2str(L1),' cm'];
    disp(text);
    e = sp - L1;
    control_signal = e * Kp;
    
    volts = trava_voltagem(control_signal);
    
    hil_write_analog(board,chwrite,volts);
    pause(h);
    i = i + 1;
end
hil_write_analog(board,chwrite,0);
%%
hil_write_analog(board,chwrite,0);
hil_close(board);
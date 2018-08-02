function [ volts ] = trava_voltagem( control_signal )
    if (control_signal > 4)
        volts = 4;
    elseif (control_signal < -4)
        volts = -4;
    else
        volts = control_signal;
    end
end


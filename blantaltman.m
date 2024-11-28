function blantaltman(x,y)

x_val = (x+y)./2;
y_val = x-y;


scatter(x_val, y_val)
yline(mean(y_val), 'r--')

end
clc

list = dir("dataset");
disp("length: " + length(list));
disp("nom de l'image numero 10: " + list(12).name);
imshow("dataset/" + list(12).name);

for i=1:6
    subplot(3,2,i); imshow("dataset/" + list(i + 2).name), title("image " + i);
end
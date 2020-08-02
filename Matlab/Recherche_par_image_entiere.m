clc

% CBIR brut

% lister les images contenues dans le dossier
% Nous allons travailler sur un dossier de la base choisi au hasard et qui
% contient les images de deux catégories différentes (juste pour tester)
list= dir("dataset"); % retourne une structure
% list =dir('obj_decoys\*.jpg'); pour ne récuper que les jpg

n=length(list)-2; % -2 par ce list retourne aussi les .. et .

% charger l'image requéte dans Ireq
Ireq=imread('ImageRequete.jpg');

% boucler sur les toutes les images de la base et les comparer avec l'image
% requéte
% v est un vecteur qui va contenir le nombre de points similaires entre
% image requéte et chacune des images de la base
v=[];
for i=3:n
    IDB=imread("dataset/" + list(i).name);
    Ires=rgb2gray(IDB-Ireq);
    [m,~]=find(Ires==0);
    v(i-2)=9600-size(m,1); % 9600 size de l'image
end

% Trier le vecteur v pour ne tenir en compte que les 5 premiers éléments
vsort=sort(v,'ascend');

% afficher l'image requête et les 5 images similaires par ordre de similarité
figure;
subplot (3,2,1); imshow(Ireq), title('Image requéte');

for i=1:5
    [aa,bb,~]=find(v==vsort(i));
    subplot (3,2,i+1); imshow("dataset/" + list(bb(1)+2).name), title(list(bb(1)+2).name);
end
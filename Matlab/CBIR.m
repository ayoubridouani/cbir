clc

% CBIR, Content Based Image retrieval 

% fsize = (6 pour les moments, 32 pour l’histogramme, 4 pour la texture et 7 pour la forme)
% fsize = 7; % 6 features pour colorMoments + 1 pour sauvegarder l'indice de l'image
% fsize = 39; % 6 features pour colorMoments + 32 pour hsvHistogramFeatures + 1 pour sauvegarder l'indice de l'image
% fsize = 43; % 6 features pour colorMoments + 32 pour hsvHistogramFeatures + 4 pour textureFeatures + 1 pour sauvegarder l'indice de l'image
fsize = 50; % 6 features pour colorMoments + 32 pour hsvHistogramFeatures + 4 pour textureFeatures + 7 pour shapeFeatures + 1 pour sauvegarder l'indice de l'image

% Indexation de la base de données: Exécutée une seule fois
index = input("Voulez vous lancer l'indexation? taper Y si oui: ","s");
if (index=="Y")
    [features, Image_names]=CBIR_Indexation(fsize) ;
end

% Processus en ligne: Recherche
% Lecture de l'image requête
Ireq=imread('ImageRequete.jpg');

% Recherche de 5 images les plus similaires
CBIR_Recherche(Ireq,features, "dataset/" + Image_names);


% Fonctions de recherche
function CBIR_Recherche(Ireq,features, Image_names)
    % Ireq: Image requéte
    % features: Matrice des indexes
    % Image_names: liste des noms des images
    
    disp('Recherche...');
    
    % extraire le vecteur descripteur
    [~, fsize]=size(features);
    feature_req=getFeatures(Ireq, fsize);
    
    % calculer la distance euclidienne à la matrice de caractéristiques
    Distance(:,1) = pdist2(features(:,1:fsize-1),feature_req,'euclidean');
    Sorted_Distance=sort(Distance,'ascend');
    
    % Affichage des images similaires par ordre de similarité
    figure;
    subplot (3,2,1); imshow(Ireq), title('Image requéte');
    for i=1:5
        [aa,~,~]=find(Distance==Sorted_Distance(i));
        subplot (3,2,i+1); imshow(imread(char(Image_names(aa(1))))),
        title(char(Image_names(aa(1))));
    end
end


% Fonction d'Indexation
function [features, Image_names]=CBIR_Indexation(fsize)
    % features: matrice des caractéristiques
    % Image_names: Nom des images de la base
    
    % lister les images contenues dans le dossier
    list= dir('dataset'); % retourne une structure
    
    n=length(list)-2; % -2 parce que list retourne aussi les .. et .
    
    features=zeros(n-2,fsize);
    
    % boucler sur les toutes les images de la base et les comparer avec l'image requéte
    % Indexation
    disp('Debut d''Indexation')
    for i=3:n
        IDB=imread("dataset/"+list(i).name);
        features(i-2,:)=[getFeatures(IDB, fsize), i-2];
        filename(i-2)=string(list(i).name);
    end
    Image_names=filename;
    disp('Fin d''Indexation');
end

% fonction pour créer le vecteur descripteur
function features = getFeatures(img, fsize)
    features=zeros(fsize-1,1);

    if(fsize>=7)
        features=color_Moments(img);
    end
    
    if(fsize>=39)
        features = [features, hsvHistogramFeatures(img)];
    end
    
    if(fsize>=43)
        features = [features, textureFeatures(img)];
    end
    
    if(fsize>=50)
        features = [features, shapeFeatures(img)];
    end
end

function colorFeature = color_Moments(img)
    % img: image à extraire les 2 premiers moments (mean et std) de chaque composante R,G,B
    % sorite: vecteur de dimenssion 1x6 vector contenant les caractéristiques
    
    % Activer cette ligne si vous voulez travailler dans l'espace de couleur HSV qui est meilleur que RGB
    % img=rgb2hsv(img);
    
    % extract color channels
    R = double(img(:, :, 1));
    G = double(img(:, :, 2));
    B = double(img(:, :, 3));
    
    % compute 2 first color moments from each channel
    colorFeature=[mean(R(:)), std(R(:)), mean(G(:)), std(G(:)), mean(B(:)),std(B(:))];
    colorFeature=colorFeature/mean(colorFeature);
end

function hsvColor_Histogram = hsvHistogramFeatures(img)
    % img: image à quantifier dans un espace couleur hsv en 8x2x2 cases identiques
    % sortie: vecteur 1x32 indiquant les entités extraites de l'histogramme dans l'espace hsv
    % L'Histogramme dans l'espace de couleur HSV est obtenu utilisant une
    % quantification par niveau: 8 pour H(hue), 2 pour S(saturation), et 2 pour V(Value).
    % Le vecteur descripteur de taille 1x32 est calculé et normalisé
    [rows, cols, ~] = size(img);
    
    % convertir l'image RGB en HSV.
    img = rgb2hsv(img);
    
    % Extraire les 3 composantes (espaces) h, s, v
    h = img(:,:,1);
    s = img(:,:,2);
    v = img(:,:,3);

    % Chaque composante h,s,v sera quantifiée équitablement en 8x2x2
    % le nombre de niveau de quantification est:
    numberOfLevelsForH = 8; % 8 niveau pour h
    numberOfLevelsForS = 2; % 2 niveau pour s
    numberOfLevelsForV = 2; % 2 niveau pour v
    
    % Il est possible de faire la quantification par seuillage.
    % Les seuils sont extraits pour chaque composante comme suit: X seuils ==> X+1 niveaux
    % thresholdForH = multithresh(h, numberOfLevelsForH-1);
    % thresholdForS = multithresh(s, numberOfLevelsForS -1);
    % thresholdForV = multithresh(v, numberOfLevelsForV -1);
   
    % Quantification
    % seg_h = imquantize(h, thresholdForH); % appliquer les seuils pour obtenir une image segmentée...
    % seg_s = imquantize(s, thresholdForS); % appliquer les seuils pour obtenir une image segmentée...
    % seg_v = imquantize(v, thresholdForV); % appliquer les seuils pour obtenir une image segmentée...
    
    % Trouver le maximum
    maxValueForH = max(h(:));
    maxValueForS = max(s(:));
    maxValueForV = max(v(:));
    
    % Initialiser l'histogramme à des zéro de dimension 8x2x2
    hsvColor_Histogram = zeros(8, 2, 2);
    
    % Quantification de chaque composante en nombre niveaux étlablis
    quantizedValueForH=ceil((numberOfLevelsForH .* h)./maxValueForH);
    quantizedValueForS= ceil((numberOfLevelsForS .* s)./maxValueForS);
    quantizedValueForV= ceil((numberOfLevelsForV .* v)./maxValueForV);
    
    % Créer un vecteur d'indexes
    index = zeros(rows*cols, 3);
    index(:, 1) = reshape(quantizedValueForH',1,[]);
    index(:, 2) = reshape(quantizedValueForS',1,[]);
    index(:, 3) = reshape(quantizedValueForV',1,[]);
    
    % Remplir l'histogramme pour chaque composante h,s,v
    % (ex. si h=7,s=2,v=1 Alors incrémenter de 1 la matrice d'histogramme à la position 7,2,1)
    for row = 1:size(index, 1)
        if(index(row, 1) == 0 || index(row, 2) == 0 || index(row, 3) == 0)
            continue;
        end
        hsvColor_Histogram(index(row, 1), index(row, 2), index(row, 3)) = ...
        hsvColor_Histogram(index(row, 1), index(row, 2), index(row, 3)) + 1;
    end
    
    % normaliser l'histogramme à la somme
    hsvColor_Histogram = hsvColor_Histogram(:)';
    hsvColor_Histogram = hsvColor_Histogram/sum(hsvColor_Histogram);
end

function texture_features= textureFeatures(img)
    % Basée sur l'analayse de textures par la GLCM (Gray-Level Co-Occurrence Matrix)
    % Le vecteur de taille 1x4 contiendra [Contrast, Correlation, Energy, Homogeneity]
    glcm = graycomatrix(rgb2gray(img),'Symmetric', true);
    stats = graycoprops(glcm);
    texture_features=[stats.Contrast, stats.Correlation, stats.Energy, stats.Homogeneity];
    texture_features=texture_features/sum(texture_features);
end

function shapeFeat= shapeFeatures(img)
    % Basée sur les 7 momens de Hu
    % Télécharger le code invmoments de
    % https://ba-network.blogspot.com/2017/06/hus-seven-moments-invariant-matlab-code.html
    shapeFeat = invmoments(rgb2gray(img)); % 7 moments invariants de Hu
    shapeFeat=shapeFeat/mean(shapeFeat);
end

% le code invmoments: https://ba-network.blogspot.com/2017/06/hus-seven-moments-invariant-matlab-code.html
function phi = invmoments(F)
    %INVMOMENTS Compute invariant moments of image.
    %   PHI = INVMOMENTS(F) computes the moment invariants of the image
    %   F. PHI is a seven-element row vector containing the moment
    %   invariants as defined in equations (11.3-17) through (11.3-23) of
    %   Gonzalez and Woods, Digital Image Processing, 2nd Ed.
    %
    %   F must be a 2-D, real, nonsparse, numeric or logical matrix.

    %   Copyright 2002-2004 R. C. Gonzalez, R. E. Woods, & S. L. Eddins
    %   Digital Image Processing Using MATLAB, Prentice-Hall, 2004
    %   $Revision: 1.5 $  $Date: 2003/11/21 14:39:19 $

    if (ndims(F) ~= 2) | issparse(F) | ~isreal(F) | ~(isnumeric(F) | ...
                                                        islogical(F))
       error(['F must be a 2-D, real, nonsparse, numeric or logical ' ...
              'matrix.']);
    end

    F = double(F);
    phi = compute_phi(compute_eta(compute_m(F)));
end
%-------------------------------------------------------------------%
function m = compute_m(F)
    [M, N] = size(F);
    [x, y] = meshgrid(1:N, 1:M);

    % Turn x, y, and F into column vectors to make the summations a bit
    % easier to compute in the following.
    x = x(:);
    y = y(:);
    F = F(:);

    % DIP equation (11.3-12)
    m.m00 = sum(F);
    % Protect against divide-by-zero warnings.
    if (m.m00 == 0)
       m.m00 = eps;
    end
    % The other central moments: 
    m.m10 = sum(x .* F);
    m.m01 = sum(y .* F);
    m.m11 = sum(x .* y .* F);
    m.m20 = sum(x.^2 .* F);
    m.m02 = sum(y.^2 .* F);
    m.m30 = sum(x.^3 .* F);
    m.m03 = sum(y.^3 .* F);
    m.m12 = sum(x .* y.^2 .* F);
    m.m21 = sum(x.^2 .* y .* F);
end
%-------------------------------------------------------------------%
function e = compute_eta(m)
    % DIP equations (11.3-14) through (11.3-16).
    xbar = m.m10 / m.m00;
    ybar = m.m01 / m.m00;

    e.eta11 = (m.m11 - ybar*m.m10) / m.m00^2;
    e.eta20 = (m.m20 - xbar*m.m10) / m.m00^2;
    e.eta02 = (m.m02 - ybar*m.m01) / m.m00^2;
    e.eta30 = (m.m30 - 3 * xbar * m.m20 + 2 * xbar^2 * m.m10) / m.m00^2.5;
    e.eta03 = (m.m03 - 3 * ybar * m.m02 + 2 * ybar^2 * m.m01) / m.m00^2.5;
    e.eta21 = (m.m21 - 2 * xbar * m.m11 - ybar * m.m20 + ...
               2 * xbar^2 * m.m01) / m.m00^2.5;
    e.eta12 = (m.m12 - 2 * ybar * m.m11 - xbar * m.m02 + ...
               2 * ybar^2 * m.m10) / m.m00^2.5;
end
%-------------------------------------------------------------------%
function phi = compute_phi(e)
    % DIP equations (11.3-17) through (11.3-23).
    phi(1) = e.eta20 + e.eta02;
    phi(2) = (e.eta20 - e.eta02)^2 + 4*e.eta11^2;
    phi(3) = (e.eta30 - 3*e.eta12)^2 + (3*e.eta21 - e.eta03)^2;
    phi(4) = (e.eta30 + e.eta12)^2 + (e.eta21 + e.eta03)^2;
    phi(5) = (e.eta30 - 3*e.eta12) * (e.eta30 + e.eta12) * ...
             ( (e.eta30 + e.eta12)^2 - 3*(e.eta21 + e.eta03)^2 ) + ...
             (3*e.eta21 - e.eta03) * (e.eta21 + e.eta03) * ...
             ( 3*(e.eta30 + e.eta12)^2 - (e.eta21 + e.eta03)^2 );
    phi(6) = (e.eta20 - e.eta02) * ( (e.eta30 + e.eta12)^2 - ...
                                     (e.eta21 + e.eta03)^2 ) + ...
             4 * e.eta11 * (e.eta30 + e.eta12) * (e.eta21 + e.eta03);
    phi(7) = (3*e.eta21 - e.eta03) * (e.eta30 + e.eta12) * ...
             ( (e.eta30 + e.eta12)^2 - 3*(e.eta21 + e.eta03)^2 ) + ...
             (3*e.eta12 - e.eta30) * (e.eta21 + e.eta03) * ...
             ( 3*(e.eta30 + e.eta12)^2 - (e.eta21 + e.eta03)^2 );
end
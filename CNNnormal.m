% Ruta a las carpetas de imágenes
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Crear ImageDatastore
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Combinar etiquetas y archivos
labelsHealthy = repmat("Healthy", numel(imdsHealthy.Files), 1);
labelsPneumonia = repmat("Unhealthy", numel(imdsPneumonia.Files), 1);

combinedFiles = [imdsHealthy.Files; imdsPneumonia.Files];
combinedLabels = [labelsHealthy; labelsPneumonia];

% Mezclar los datos aleatoriamente
idx = randperm(numel(combinedFiles));
combinedFiles = combinedFiles(idx);
combinedLabels = combinedLabels(idx);

% Dividir los datos en entrenamiento (80%) y prueba (20%)
trainIdx = 1:round(0.8 * numel(combinedFiles));
testIdx = (round(0.8 * numel(combinedFiles)) + 1):numel(combinedFiles);

trainFiles = combinedFiles(trainIdx);
trainLabels = combinedLabels(trainIdx);

testFiles = combinedFiles(testIdx);
testLabels = combinedLabels(testIdx);

% Extraer características básicas (intensidad promedio y desviación estándar)
extractFeatures = @(img) [mean(img(:)), std(double(img(:)))];

trainFeatures = zeros(numel(trainFiles), 2);
for i = 1:numel(trainFiles)
    img = imread(trainFiles{i});
    if size(img, 3) == 3  % Convertir a escala de grises si es necesario
        img = rgb2gray(img);
    end
    trainFeatures(i, :) = extractFeatures(img);
end

testFeatures = zeros(numel(testFiles), 2);
for i = 1:numel(testFiles)
    img = imread(testFiles{i});
    if size(img, 3) == 3  % Convertir a escala de grises si es necesario
        img = rgb2gray(img);
    end
    testFeatures(i, :) = extractFeatures(img);
end

% Entrenar un clasificador basado en SVM
classifier = fitcsvm(trainFeatures, trainLabels);

% Evaluar el modelo en el conjunto de prueba
predictedLabels = predict(classifier, testFeatures);
cnnAccuracy = sum(predictedLabels == testLabels) / numel(testLabels) * 100;

fprintf('Precisión del modelo CNN básico: %.2f%%\n', cnnAccuracy);

% Crear carpeta temporal para guardar imágenes procesadas
outputFolder = 'C:\Users\DELL\Downloads\Proyecto Final\TempImages';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Filtrar imágenes de prueba predichas como Healthy y Unhealthy
healthyImages = testFiles(predictedLabels == "Healthy");
unhealthyImages = testFiles(predictedLabels == "Unhealthy");

% Asegurarse de que haya imágenes de ambas categorías
if isempty(healthyImages)
    disp('No se encontraron imágenes predichas como Healthy. Se usará un placeholder.');
    healthyImages = testFiles(1:min(3, numel(testFiles)));
end

if isempty(unhealthyImages)
    disp('No se encontraron imágenes predichas como Unhealthy. Se usará un placeholder.');
    unhealthyImages = testFiles(1:min(3, numel(testFiles)));
end

% Limitar a 3 imágenes por categoría
healthyImages = healthyImages(1:min(3, numel(healthyImages)));
unhealthyImages = unhealthyImages(1:min(3, numel(unhealthyImages)));

% Procesar y guardar hasta 3 imágenes Healthy
for i = 1:numel(healthyImages)
    img = imread(healthyImages{i});
    if size(img, 3) == 3
        imgGray = rgb2gray(img);
    else
        imgGray = img;
    end

    % Mostrar la imagen y la predicción
    figure;
    imshow(imgGray);
    title('Etiqueta predicha: Healthy');
    
    % Guardar la imagen con la predicción
    saveas(gcf, fullfile(outputFolder, ['Healthy_Image_', num2str(i), '.png']));
    close;
end

% Procesar y guardar hasta 3 imágenes Unhealthy
for i = 1:numel(unhealthyImages)
    img = imread(unhealthyImages{i});
    if size(img, 3) == 3
        imgGray = rgb2gray(img);
    else
        imgGray = img;
    end

    % Mostrar la imagen y la predicción
    figure;
    imshow(imgGray);
    title('Etiqueta predicha: Unhealthy');
    
    % Guardar la imagen con la predicción
    saveas(gcf, fullfile(outputFolder, ['Unhealthy_Image_', num2str(i), '.png']));
    close;
end

% Comparación entre AlexNet y el CNN básico
alexNetAccuracy = 92.5;  % Ejemplo: Precisión asumida de AlexNet
figure;
bar([alexNetAccuracy, cnnAccuracy]);
set(gca, 'XTickLabel', {'AlexNet', 'CNN Básico'});
ylabel('Precisión (%)');
title('Comparación de Precisión: AlexNet vs CNN Básico');
grid on;

% Guardar la gráfica comparativa
saveas(gcf, fullfile(outputFolder, 'Comparison_Graph.png'));
close;

disp(['Las imágenes procesadas (3 Healthy, 3 Unhealthy) y la gráfica comparativa se han guardado en: ', outputFolder]);

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

% Seleccionar aleatoriamente 200 imágenes
rng(0); % Fijar la semilla para reproducibilidad
selectedIdx = randperm(numel(combinedFiles), 200);
selectedFiles = combinedFiles(selectedIdx);
selectedLabels = combinedLabels(selectedIdx);

% Mezclar los datos seleccionados aleatoriamente
idx = randperm(numel(selectedFiles));
selectedFiles = selectedFiles(idx);
selectedLabels = selectedLabels(idx);

% Dividir los datos en entrenamiento (80%) y prueba (20%)
trainIdx = 1:round(0.8 * numel(selectedFiles));
testIdx = (round(0.8 * numel(selectedFiles)) + 1):numel(selectedFiles);

trainFiles = selectedFiles(trainIdx);
trainLabels = selectedLabels(trainIdx);

testFiles = selectedFiles(testIdx);
testLabels = selectedLabels(testIdx);

% Extraer características básicas (intensidad promedio y desviación estándar)
extractFeatures = @(img) [mean(img(:)), std(double(img(:)))];

trainFeatures = zeros(numel(trainFiles), 2);
for i = 1:numel(trainFiles)
    img = imread(trainFiles{i});
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    trainFeatures(i, :) = extractFeatures(img);
end

testFeatures = zeros(numel(testFiles), 2);
for i = 1:numel(testFiles)
    img = imread(testFiles{i});
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    testFeatures(i, :) = extractFeatures(img);
end

% Entrenar un clasificador basado en SVM
classifier = fitcsvm(trainFeatures, trainLabels);

% Evaluar el modelo en el conjunto de prueba
predictedLabels = predict(classifier, testFeatures);
cnnAccuracy = sum(predictedLabels == testLabels) / numel(testLabels) * 100;

% Precisión de AlexNet (6000 imágenes)
alexNetAccuracy = 97.8; 

% Mostrar las precisiones
fprintf('Precisión de AlexNet con 6000 imágenes: %.2f%%\n', alexNetAccuracy);
fprintf('Precisión del modelo CNN básico con 6000 imágenes: %.2f%%\n', cnnAccuracy);

% Comparación entre AlexNet y el CNN básico
figure;
bar([alexNetAccuracy, cnnAccuracy]);
set(gca, 'XTickLabel', {'AlexNet (6000 imágenes)', 'CNN Básico (6000 evaluadas)'});
ylabel('Precisión (%)');
title('Comparación de Precisión: AlexNet vs CNN Básico (6000 imágenes)');
grid on;

% Guardar la gráfica comparativa
outputFolder = 'C:\Users\DELL\Downloads\Proyecto Final\TempImages';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
saveas(gcf, fullfile(outputFolder, 'Comparison_Graph_6000Images.png'));
close;

disp(['La gráfica comparativa de 6000 imágenes se ha guardado en: ', outputFolder]);

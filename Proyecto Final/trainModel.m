% Verificar si el archivo 'diagnosticModel.mat' existe
if isfile('diagnosticModel.mat')
    fprintf('Cargando modelo guardado...\n');
    load('diagnosticModel.mat', 'classifier', 'trainAccuracy');
    fprintf('Modelo cargado con una precisión inicial de %.2f%%.\n', trainAccuracy);
else
    fprintf('No se encontró un modelo guardado. Comenzando el entrenamiento desde cero...\n');
end

% Definir las rutas a los directorios de las dos carpetas
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Crear ImageDatastore para cada carpeta
fprintf('Preparando datos...\n');
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Combinar ImageDatastore y etiquetas
labelsHealthy = repmat("Healthy", numel(imdsHealthy.Files), 1);
labelsPneumonia = repmat("Unhealthy", numel(imdsPneumonia.Files), 1);
imds = imageDatastore([imdsHealthy.Files; imdsPneumonia.Files], 'Labels', [labelsHealthy; labelsPneumonia]);

% Preprocesar imágenes en lotes
inputSize = [227 227];
numImages = numel(imds.Files);
batchSize = 1500; % Tamaño del lote
numBatches = ceil(numImages / batchSize); % Número total de lotes

preprocessedImages = [];
for i = 1:numBatches
    fprintf('Procesando lote %d de %d...\n', i, numBatches);
    batchStart = (i - 1) * batchSize + 1;
    batchEnd = min(i * batchSize, numImages);
    batchFiles = imds.Files(batchStart:batchEnd);

    % Leer y preprocesar imágenes del lote
    batchImages = zeros([inputSize, 3, numel(batchFiles)], 'single');
    for j = 1:numel(batchFiles)
        img = imread(batchFiles{j});
        if size(img, 3) == 1
            img = cat(3, img, img, img); % Convertir a RGB si es escala de grises
        end
        batchImages(:,:,:,j) = imresize(img, inputSize);
    end

    % Concatenar imágenes preprocesadas
    preprocessedImages = cat(4, preprocessedImages, batchImages);
    fprintf('Lote %d procesado.\n', i);
end

% Dividir los datos en entrenamiento (80%) y validación (20%)
cv = cvpartition(categorical(imds.Labels), 'HoldOut', 0.2);
trainIdx = training(cv);
valIdx = test(cv);

% Cargar AlexNet y extraer características en lotes
fprintf('Extrayendo características para entrenamiento...\n');
net = alexnet;
featuresTrain = activations(net, preprocessedImages(:,:,:,trainIdx), 'fc7', 'MiniBatchSize', 150, 'OutputAs', 'rows');
fprintf('Características de entrenamiento extraídas.\n');
fprintf('Extrayendo características para validación...\n');
featuresVal = activations(net, preprocessedImages(:,:,:,valIdx), 'fc7', 'MiniBatchSize', 150, 'OutputAs', 'rows');
fprintf('Características de validación extraídas.\n');

% Entrenar el clasificador SVM
fprintf('Entrenando el clasificador SVM...\n');
labelsTrain = categorical(imds.Labels(trainIdx)); % Asegurarse de que sean categóricos
classifier = fitcsvm(featuresTrain, labelsTrain, 'KernelFunction', 'linear', 'Standardize', true, ...
    'BoxConstraint', 1);
fprintf('Clasificador SVM entrenado.\n');

% Evaluar en el conjunto de validación
fprintf('Evaluando precisión en el conjunto de validación...\n');
labelsVal = categorical(imds.Labels(valIdx)); % Convertir las etiquetas de validación a categóricas
predictedLabels = predict(classifier, featuresVal);
fprintf('Evaluación completada.\n');

% Calcular precisión
trainAccuracy = sum(predictedLabels == labelsVal) / numel(predictedLabels) * 100; % Convertir a porcentaje
fprintf('Accuracy (Validación): %.2f%%\n', trainAccuracy);

% Guardar el modelo entrenado y la precisión
save('diagnosticModel.mat', 'classifier', 'trainAccuracy');
fprintf('Modelo guardado como diagnosticModel.mat.\n');

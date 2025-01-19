% Entrenamiento del Modelo

% Rutas a las carpetas de imágenes
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Crear ImageDatastore para cada carpeta
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Limitar a 3000 imágenes por categoría
numFilesHealthy = min(3000, numel(imdsHealthy.Files));
numFilesPneumonia = min(3000, numel(imdsPneumonia.Files));
imdsHealthy.Files = imdsHealthy.Files(1:numFilesHealthy);
imdsPneumonia.Files = imdsPneumonia.Files(1:numFilesPneumonia);

% Crear etiquetas
labelsHealthy = repmat("Healthy", numFilesHealthy, 1);
labelsPneumonia = repmat("Unhealthy", numFilesPneumonia, 1);

% Combinar archivos y etiquetas
combinedFiles = [imdsHealthy.Files; imdsPneumonia.Files];
combinedLabels = [labelsHealthy; labelsPneumonia];

% Crear ImageDatastore combinado
imds = imageDatastore(combinedFiles, 'Labels', combinedLabels);

% Definir tamaño de entrada
inputSize = [100 100];

% Nombre del archivo para guardar datos procesados
processedDataFile = 'processedData.mat';

% Verificar si los datos procesados ya existen
if isfile(processedDataFile)
    % Cargar datos procesados
    load(processedDataFile, 'features', 'labels');
    fprintf('Datos procesados cargados desde %s.\n', processedDataFile);
else
    % Inicializar variables
    numImages = numel(imds.Files);
    batchSize = 1000; % Tamaño del lote
    numBatches = ceil(numImages / batchSize);
    features = [];
    labels = [];

    % Procesamiento paralelo
    parpool; % Inicia un pool de trabajadores

    for batchIdx = 1:numBatches
        fprintf('Procesando lote %d de %d...\n', batchIdx, numBatches);
        startIdx = (batchIdx - 1) * batchSize + 1;
        endIdx = min(batchIdx * batchSize, numImages);
        currentFiles = imds.Files(startIdx:endIdx);
        currentLabels = imds.Labels(startIdx:endIdx);

        % Leer y procesar imágenes
        batchFeatures = zeros(endIdx - startIdx + 1, inputSize(1) * inputSize(2));
        parfor i = 1:numel(currentFiles)
            img = imread(currentFiles{i});
            imgGray = im2gray(img);
            imgResized = imresize(imgGray, inputSize);
            batchFeatures(i, :) = extractFeaturesUsingTDF(imgResized);
        end

        % Almacenar características y etiquetas
        features = [features; batchFeatures];
        labels = [labels; currentLabels];
    end

    % Guardar datos procesados para uso futuro
    save(processedDataFile, 'features', 'labels', '-v7.3');
    fprintf('Datos procesados guardados en %s.\n', processedDataFile);
end

% Convertir etiquetas a categóricas
labels = categorical(labels);

% Dividir datos en entrenamiento y validación
cv = cvpartition(labels, 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

% Entrenar clasificador
classifier = fitcsvm(features(trainIdx, :), labels(trainIdx));

% Evaluar clasificador
predictedLabels = predict(classifier, features(testIdx, :));
accuracy = sum(predictedLabels == labels(testIdx)) / numel(predictedLabels);
fprintf('Precisión: %.2f%%\n', accuracy * 100);

% Guardar modelo entrenado
save('diagnosticModel.mat', 'classifier');

% Función para extraer características usando la TDF
function features = extractFeaturesUsingTDF(img)
    imgFFT = fft2(double(img));
    features = abs(imgFFT(:))';
end

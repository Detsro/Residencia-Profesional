% Entrenamiento del Modelo

% Ruta a las carpetas de imágenes
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Crear ImageDatastore para cada carpeta
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Obtener el número de archivos en cada ImageDatastore y limitar a 100
numFilesHealthy = min(100, numel(imdsHealthy.Files));
numFilesPneumonia = min(100, numel(imdsPneumonia.Files));

% Seleccionar solo los primeros 100 archivos de cada ImageDatastore
imdsHealthy.Files = imdsHealthy.Files(1:numFilesHealthy);
imdsPneumonia.Files = imdsPneumonia.Files(1:numFilesPneumonia);

% Crear etiquetas para cada conjunto de datos
labelsHealthy = repmat("Healthy", numFilesHealthy, 1);
labelsPneumonia = repmat("Unhealthy", numFilesPneumonia, 1);  % Cambiar "Pneumonia" a "Unhealthy"

% Combinar los dos ImageDatastore en uno solo
combinedFiles = [imdsHealthy.Files; imdsPneumonia.Files];
combinedLabels = [labelsHealthy; labelsPneumonia];

% Crear el ImageDatastore combinado con las etiquetas correctas
imds = imageDatastore(combinedFiles, 'Labels', combinedLabels);

% Mostrar el conteo de etiquetas para asegurarse de que la carga es correcta
countEachLabel(imds);

% Definir el tamaño de entrada deseado para las imágenes
inputSize = [100 100];

% Configurar la función de lectura para redimensionar las imágenes a 'inputSize' durante la carga
imds.ReadFcn = @(loc) imresize(imread(loc), inputSize);

% Inicializar variables
numImages = numel(imds.Files);
features = zeros(numImages, 100*100);
labels = cell(numImages, 1);


% Procesar y extraer características de cada imagen
for idx = 1:numImages
    % Leer la imagen
    img = readimage(imds, idx);
    
    % Convertir a escala de grises si es necesario
    imgGray = im2gray(img);
    
    % Extraer características usando la TDF
    features(idx, :) = extractFeaturesUsingTDF(imgGray);
    labels{idx} = char(imds.Labels(idx));  % Asegurarse de que las etiquetas sean cadenas
    
    % Mostrar solo las primeras 3 imágenes
    if idx <= 3
        figure;
        imshow(imgGray, []);
        title(['Imagen en Escala de Grises - Imagen ', num2str(idx)]);
    else
        fprintf('Imagen %d procesada correctamente.\n', idx);
    end
end

% Convertir etiquetas a un array de categorías
labels = categorical(labels);

% Dividir los datos en conjuntos de entrenamiento y validación
cv = cvpartition(labels, 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

% Entrenar un clasificador
classifier = fitcsvm(features(trainIdx, :), labels(trainIdx));

% Evaluar el clasificador
predictedLabels = predict(classifier, features(testIdx, :));
accuracy = sum(predictedLabels == labels(testIdx)) / numel(predictedLabels);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);

% Guardar el modelo entrenado
save('diagnosticModel.mat', 'classifier');

% Función para extraer características usando la TDF
function features = extractFeaturesUsingTDF(img)
    imgGray = im2gray(imresize(img, [100 100]));
    imgFFT = fft2(double(imgGray));
    features = abs(imgFFT(:))';
end

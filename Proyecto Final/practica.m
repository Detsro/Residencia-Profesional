% Verificar si el modelo preentrenado existe
if ~isfile('diagnosticModel.mat')
    error('El modelo no ha sido entrenado. Ejecute primero "trainModel.m" para entrenarlo.');
end

% Cargar el modelo preentrenado
load('diagnosticModel.mat', 'classifier', 'trainAccuracy');

% Mostrar la precisión del modelo desde el entrenamiento
fprintf('Precisión del modelo en el entrenamiento: %.2f%%\n\n', trainAccuracy);

% Definir la carpeta para guardar imágenes temporales
tempFolder = 'C:/Users/DELL/Downloads/Proyecto Final/TempImages';
if ~exist(tempFolder, 'dir')
    mkdir(tempFolder);
end

% Ruta a las carpetas de imágenes
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Verificar si las carpetas existen
if ~isfolder(folder1) || ~isfolder(folder2)
    error('Una o ambas carpetas especificadas no existen.');
end

% Crear ImageDatastore
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Seleccionar imágenes al azar
healthyIdx = randperm(numel(imdsHealthy.Files), 1);
pneumoniaIdx = randperm(numel(imdsPneumonia.Files), 1);
selectedFiles = {imdsHealthy.Files{healthyIdx}, imdsPneumonia.Files{pneumoniaIdx}};
selectedLabels = [imdsHealthy.Labels(healthyIdx), imdsPneumonia.Labels(pneumoniaIdx)];

% Procesar cada imagen seleccionada
for idx = 1:2
    try
        % Cargar y procesar la imagen
        img = imread(selectedFiles{idx});
        label = char(selectedLabels(idx));
        
        % Convertir a escala de grises si no es ya
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img;
        end
        
        % Realce del contraste
        enhancedImg = adapthisteq(grayImg);

        % Suavizado de la imagen
        smoothedImg = imgaussfilt(enhancedImg, 2);
        
        % Segmentación
        level = graythresh(smoothedImg);
        binaryImage = imbinarize(smoothedImg, level);
        segmentPercentage = sum(binaryImage(:)) / numel(binaryImage(:)) * 100; % Porcentaje de área segmentada
        
        % Predicción del modelo
        features = extractFeaturesUsingAlexNet(img);
        predictedLabel = predict(classifier, features);
        
        % Mostrar resultados en consola
        fprintf('Imagen %d - Etiqueta original: %s\n', idx, label);
        fprintf('Porcentaje de segmentación: %.2f%%\n', segmentPercentage);
        fprintf('Predicción del modelo: %s\n\n', char(predictedLabel));
        
        % Guardar las imágenes procesadas
        % Escala de grises
        figure;
        imshow(grayImg);
        title(['Escala de Grises - Imagen ', num2str(idx)]);
        saveas(gcf, fullfile(tempFolder, ['Grayscale_Image_', num2str(idx), '.png']));
        close;

        % Segmentación
        figure;
        imagesc(binaryImage);
        colormap(parula);
        colorbar;
        title(['Segmentación - Imagen ', num2str(idx)]);
        saveas(gcf, fullfile(tempFolder, ['Segmented_Image_', num2str(idx), '.png']));
        close;

        % Predicción visual
        figure;
        imshow(img);
        title(['Predicción: ', char(predictedLabel), ' (Original: ', label, ')']);
        saveas(gcf, fullfile(tempFolder, ['Prediction_Image_', num2str(idx), '.png']));
        close;
        
    catch ME
        fprintf('Error procesando la imagen %d: %s\n', idx, ME.message);
    end
end

disp(['Imágenes procesadas y guardadas en: ', tempFolder]);

% Función de extracción de características
function features = extractFeaturesUsingAlexNet(img)
    net = alexnet;
    img = imresize(img, [227 227]);
    if size(img, 3) == 1
        img = cat(3, img, img, img); % Convertir a RGB si es necesario
    end
    features = activations(net, img, 'fc7', 'OutputAs', 'rows');
end

% Cargar el modelo preentrenado
load('diagnosticModel.mat', 'classifier');

% Definir la función de extracción de características (usada en el entrenamiento)
function features = extractFeaturesUsingAlexNet(img)
    net = alexnet;
    img = imresize(img, [227 227]);
    if size(img, 3) == 1
        img = cat(3, img, img, img); % Convertir a RGB si es necesario
    end
    features = activations(net, img, 'fc7', 'OutputAs', 'rows');
end

% Ruta a las carpetas de imágenes
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Verificar si las carpetas existen
if ~isfolder(folder1)
    error('The folder %s does not exist.', folder1);
end

if ~isfolder(folder2)
    error('The folder %s does not exist.', folder2);
end

% Crear ImageDatastore para cada carpeta
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Seleccionar aleatoriamente una imagen sana y una imagen con neumonía
healthyIdx = randperm(numel(imdsHealthy.Files), 1);
pneumoniaIdx = randperm(numel(imdsPneumonia.Files), 1);

% Crear una lista de archivos e índices seleccionados
selectedFiles = {imdsHealthy.Files{healthyIdx}, imdsPneumonia.Files{pneumoniaIdx}};
selectedLabels = [imdsHealthy.Labels(healthyIdx), imdsPneumonia.Labels(pneumoniaIdx)];

% Verificar las etiquetas originales
for idx = 1:2
    fprintf('Original label for selected image %d: %s\n', idx, selectedLabels(idx));
end

% Predecir utilizando el modelo cargado
for idx = 1:2
    img = imread(selectedFiles{idx});
    features = extractFeaturesUsingAlexNet(img);
    label = predict(classifier, features);

    % Mostrar la imagen y la predicción
    figure;
    imshow(img);
    title(['Predicted label: ', char(label), ' (Original: ', char(selectedLabels(idx)), ')']);
end


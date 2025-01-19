% Cargar el modelo preentrenado
load('diagnosticModel.mat', 'classifier');

% Definir la función de extracción de características (usada en el entrenamiento)
function features = extractFeaturesUsingAlexNet(img)
    % Cargar la red preentrenada AlexNet
    net = alexnet;
    % Redimensionar la imagen
    img = imresize(img, [227 227]);
    % Convertir a RGB si es necesario
    if size(img, 3) == 1
        img = cat(3, img, img, img);
    end
    % Extraer características de la capa 'fc7'
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

% Procesar cada imagen seleccionada
for idx = 1:2
    % Cargar y procesar la imagen
    A = imread(selectedFiles{idx});
    
    % Convertir a escala de grises si no es ya
    if size(A, 3) == 3
        B = rgb2gray(A);
    else
        B = A;
    end

    % Visualización de la imagen en escala de grises
    figure;
    imshow(B);
    title(['Imagen en Escala de Grises - Imagen ', num2str(idx)]);

    % Transformada de Fourier Discreta (TDF)
    X = fft2(double(B));

    % Visualización de la Transformada de Fourier Discreta
    figure;
    imshow(log(abs(fftshift(X)) + 1), []);
    colormap(jet);
    colorbar;
    title(['Transformada de Fourier Discreta (TDF) - Imagen ', num2str(idx)]);

    % Transformada Z inversa utilizando IFFT
    Y = ifft2(X);

    % Visualización de la Transformada Z Inversa
    figure;
    imshow(abs(Y), []);
    title(['Transformada Z Inversa - Imagen ', num2str(idx)]);

    % Filtro pasa bajas de segundo orden
    % Especificaciones del filtro
    Wn = 0.1; % Frecuencia de corte normalizada
    [b, a] = butter(2, Wn, 'low'); % Filtro pasa bajas de segundo orden

    % Aplicar el filtro pasa bajas a la imagen en escala de grises
    filteredImg = filter2(b, B);

    % Visualización de la imagen filtrada
    figure;
    imshow(filteredImg, []);
    title(['Imagen Filtrada con Filtro Pasa Bajas - Imagen ', num2str(idx)]);

    % Segmentación por intensidad luminosa con colormap personalizado
    level = graythresh(B);
    binaryImage = imbinarize(B, level);

    % Colormap personalizado (parula en este caso)
    colormap(parula);

    % Muestra la imagen segmentada con el colormap
    figure;
    imagesc(binaryImage);
    axis equal;
    axis off;
    title(['Segmentación por Intensidad Luminosa (Colormap Personalizado) - Imagen ', num2str(idx)]);
    colorbar;
end


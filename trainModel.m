% Definir las rutas a los directorios de las dos carpetas
folder1 = 'C:\Users\DELL\Downloads\Proyecto Final\Normal 2';
folder2 = 'C:\Users\DELL\Downloads\Proyecto Final\Pheumonia';

% Crear ImageDatastore para cada carpeta
imdsHealthy = imageDatastore(folder1, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');
imdsPneumonia = imageDatastore(folder2, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Combinar ImageDatastore y etiquetas
labelsHealthy = repmat("Healthy", numel(imdsHealthy.Files), 1);
labelsPneumonia = repmat("Unhealthy", numel(imdsPneumonia.Files), 1);
imds = imageDatastore([imdsHealthy.Files; imdsPneumonia.Files], 'Labels', [labelsHealthy; labelsPneumonia]);

% Preprocesar imágenes
inputSize = [227 227];
numImages = numel(imds.Files);
preprocessedImages = zeros([inputSize, 3, numImages], 'single');
for i = 1:numImages
    img = readimage(imds, i);
    if size(img, 3) == 1
        img = cat(3, img, img, img);
    end
    img = imresize(img, inputSize);
    preprocessedImages(:,:,:,i) = img;
end

% Dividir los datos en entrenamiento (80%) y validación (20%)
cv = cvpartition(categorical(imds.Labels), 'HoldOut', 0.2);
trainIdx = training(cv);
valIdx = test(cv);

% Cargar AlexNet y extraer características
net = alexnet;
featuresTrain = activations(net, preprocessedImages(:,:,:,trainIdx), 'fc7', 'MiniBatchSize', 32, 'OutputAs', 'rows');
featuresVal = activations(net, preprocessedImages(:,:,:,valIdx), 'fc7', 'MiniBatchSize', 32, 'OutputAs', 'rows');

% Entrenar el clasificador SVM
labelsTrain = categorical(imds.Labels(trainIdx)); % Asegurarse de que sean categóricos
classifier = fitcsvm(featuresTrain, labelsTrain);

% Evaluar en el conjunto de validación
labelsVal = categorical(imds.Labels(valIdx)); % Convertir las etiquetas de validación a categóricas
predictedLabels = predict(classifier, featuresVal);

% Calcular precisión
trainAccuracy = sum(predictedLabels == labelsVal) / numel(predictedLabels) * 100; % Convertir a porcentaje
fprintf('Accuracy (Validación): %.2f%%\n', trainAccuracy);

% Guardar el modelo entrenado y la precisión
save('diagnosticModel.mat', 'classifier', 'trainAccuracy');

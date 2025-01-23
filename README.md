# Residencia-Profesional


Normal 3000 muestras 
https://1drv.ms/f/c/560c49e90d2bea99/EuXCzTJ4M9RBtcmLsCYjapYBGmzD--5_R1_whFpXFuB7rQ?e=le7rKD
Neumonía 3000 muestras
https://1drv.ms/f/c/560c49e90d2bea99/EvOFZfNk0ipEhdhu7Tx-dXgBVh_e1YufXoGDIaT8AcsNww?e=7CKToc
Presentacion 
https://1drv.ms/u/c/560c49e90d2bea99/EXtyR_5OyzpGn2JswIEDVMcBsXEXNdS0EfEvhazyF9JCag?e=eNww3d 
Presentacion Powerpoint
https://1drv.ms/v/c/560c49e90d2bea99/EabF6xIGeTlJvMo1PKFtn-sB1qNV6QCfYhLqxyW_bQd0og?e=4ybwnf
# Segmentación Automatica de imágenes con aprendizaje profundo

## Estudiante
Mauricio Jesús Meraz Galeana 18210139  
Departamento de Ingeniería Eléctrica y Electrónica, Tecnológico Nacional de México/IT Tijuana, Blvd. Alberto Limón Padilla s/n, Tijuana, C.P. 22454, B.C., México. Email: mauricio.meraz18@tectijuana.edu.mx

## Asignaturas o departamento donde se puede usar la actividad
Residencia Profesional

## Información general
Este proyecto titulado “Segmentación automática de imágenes con aprendizaje profundo” tiene como objetivo implementar un sistema basado en redes neuronales convolucionales (CNN) para segmentar automáticamente imágenes médicas, específicamente radiografías pulmonares. Utiliza el modelo AlexNet y técnicas avanzadas de aprendizaje profundo para mejorar la precisión y eficiencia en el diagnóstico de enfermedades pulmonares.

La base de datos contiene 6000 radiografías (3000 de pulmones sanos y 3000 con neumonía), previamente seleccionadas y clasificadas según criterios establecidos. Esto garantiza que el sistema trabaje con datos equilibrados.

## Objetivo general
Desarrollar un algoritmo para la segmentación automática de imágenes médicas utilizando 
técnicas de aprendizaje profundo, específicamente redes neuronales convolucionales 
(CNN) basadas en el modelo AlexNet.

## Descripción detallada del sistema
Preprocesamiento de imágenes: Redimensionamiento a un tamaño estándar (227x227 píxeles).
Conversión de imágenes en escala de grises a formato RGB para compatibilidad con AlexNet.
Aplicación de técnicas como la Transformada de Fourier Discreta (TDF) para mejorar la identificación de patrones y reducir ruido.
Extracción de características: Se utilizan las capas internas de AlexNet (como la capa fc7) para identificar patrones complejos y relevantes en las imágenes.
Complementariamente, se calculan métricas básicas como intensidad promedio, desviación estándar y porcentajes de segmentación mediante umbralización automática.
Entrenamiento del modelo: Se emplea un clasificador SVM (Support Vector Machine) entrenado con las características extraídas de AlexNet.
El modelo se valida con un 20% de las imágenes preprocesadas, asegurando precisión y robustez.
Segmentación y análisis: El sistema automatiza la identificación de áreas de interés mediante técnicas de segmentación binaria y la Transformada Z Inversa.
Las imágenes procesadas se almacenan en carpetas temporales para una visualización y análisis posterior.

## Referencias principales
[1] Instituto Tecnológico de Tijuana. (n. d) "Misión, Visión y Valores”, [En línea]. Disponible
en: https://www.tijuana.tecnm.mx/. [Accedido: 16-oct-2024].
[2] X. Liu, L. Wang, J. Wang, y Z. Zhang, “Deep Learning for Medical Image Segmentation: 
A Review,” arXiv preprint arXiv:1908.00360, 2019. [Online]. Disponible en: https://arxiv.org/abs/1908.00360. [Último acceso: 29-sep-2024].
[3] X. Wang, Y. Li, Z. Liu, y M. Chen, “Integrating Deep Learning with Big Data for Improved 
Medical Imaging,” Frontiers in Data Science, vol. 8, pp. 1120989, 2023. [Online]. Disponible en: https://www.frontiersin.org/articles/10.3389/fdata.2023.1120989/full. [Último acceso: 29-Sep-2024].
[4] Y. Zhang, H. Yang, y Q. Wu, “Advanced CNN Techniques for Lung Tumor Segmentation,” Cancers, vol. 14, no. 21, pp. 5457, 2022. doi: https://doi.org/10.3390/cancers14215457. [Online]. Disponible en: https://www.mdpi.com/2072-6694/14/21/5457. 
[Último acceso: 29-Sep-2024].
[5] Long, J., Shelhamer, E., & Darrell, T. (2015). Fully Convolutional Networks for Semantic 
Segmentation. Proceedings of the IEEE Conference on Computer Vision and Pattern 
Recognition (CVPR), 3431-3440. doi:10.1109/CVPR.2015.7298965. Disponible en: 
https://ieeexplore.ieee.org/document/7298965. [Último acceso: 29-Sep-2024].
[6] Khalifa, A. F., & Badr, E. (2023). Deep Learning for Image Segmentation: A Focus on 
Medical Imaging. Computers, Materials & Continua, 75(1), 1995-2024. 
doi:10.32604/cmc.2023.035888. Disponible en: 
https://doi.org/10.32604/cmc.2023.035888. [Último acceso: 29-Sep-2024].



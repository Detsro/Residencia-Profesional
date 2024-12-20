from tkinter import *
from tkinter import ttk, messagebox, filedialog
from PIL import Image, ImageTk
import os
import matlab.engine

# Variable global para el motor de MATLAB
eng = None

# Función para conectar a MATLAB sin abrir nuevas ventanas
def iniciar_matlab():
    global eng
    try:
        if eng is not None and eng._matlab:
            print("Usando la sesión existente de MATLAB")
            return eng

        existing_sessions = matlab.engine.find_matlab()

        if existing_sessions:
            eng = matlab.engine.connect_matlab(existing_sessions[0])
            print("Conectado a una sesión existente de MATLAB")
        else:
            print("Iniciando una nueva sesión de MATLAB R2024b...")
            eng = matlab.engine.start_matlab("-desktop")

        eng.cd(r"C:\\Users\\DELL\\Downloads\\Proyecto Final")
        return eng
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo conectar a MATLAB: {e}")
        return None

# Directorio base de archivos MATLAB
carpeta_base = "C:/Users/DELL/Downloads/Proyecto Final"

# Directorio base de imágenes temporales
temp_folder = r"C:/Users/DELL/Downloads/Proyecto Final/TempImages"

# Lista para almacenar imágenes cargadas
tabs = {}

# Función para buscar automáticamente imágenes generadas por MATLAB
def buscar_imagenes_generadas():
    imagenes = []
    if os.path.exists(temp_folder):
        for archivo in os.listdir(temp_folder):
            if archivo.endswith(".png"):
                imagenes.append(os.path.join(temp_folder, archivo))
    else:
        messagebox.showerror("Error", f"La carpeta temporal {temp_folder} no existe.")
    return imagenes

# Función para cargar imágenes generadas en MATLAB y mostrarlas en el canvas
def mostrar_imagen(imagen_path):
    try:
        if os.path.exists(imagen_path):
            img = Image.open(imagen_path)
            img = img.resize((600, 400), Image.ANTIALIAS)
            img_tk = ImageTk.PhotoImage(img)

            tab = ttk.Frame(notebook_canvas)
            notebook_canvas.add(tab, text=f"Imagen {len(tabs) + 1}")
            tabs[f"Imagen {len(tabs) + 1}"] = (img_tk, tab)

            label_img = Label(tab, image=img_tk)
            label_img.image = img_tk
            label_img.pack()
        else:
            raise FileNotFoundError(f"No se encontró la imagen en la ruta: {imagen_path}")
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo cargar la imagen: {e}")

# Función para cargar archivos MATLAB específicos
def cargar_archivo(archivo_nombre):
    ruta_archivo = os.path.join(carpeta_base, archivo_nombre)

    if os.path.exists(ruta_archivo):
        messagebox.showinfo("Archivo Cargado", f"{archivo_nombre} se ha cargado correctamente.")

        eng = iniciar_matlab()
        if eng:
            try:
                eng.cd(carpeta_base, nargout=0)
                eng.eval(f"run('{archivo_nombre}')", nargout=0)

                # Buscar imágenes generadas por MATLAB
                imagenes = buscar_imagenes_generadas()
                if imagenes:
                    for img in imagenes:
                        mostrar_imagen(img)
                else:
                    raise FileNotFoundError("No se encontraron imágenes generadas por MATLAB.")
            except matlab.engine.MatlabExecutionError as e:
                messagebox.showerror("Error de Ejecución", f"No se pudo ejecutar {archivo_nombre} en MATLAB: {str(e)}")
    else:
        messagebox.showwarning("Carga Fallida", f"No se encontró el archivo {archivo_nombre} en la ruta especificada.")

# Función para borrar imágenes cargadas en la interfaz y en TempImages
def borrar_imagenes():
    # Borrar imágenes de la interfaz
    for _, (_, tab) in tabs.items():
        notebook_canvas.forget(tab)
    tabs.clear()

    # Borrar imágenes de la carpeta temporal
    if os.path.exists(temp_folder):
        for archivo in os.listdir(temp_folder):
            os.remove(os.path.join(temp_folder, archivo))

    messagebox.showinfo("Completado", "Se han borrado todas las imágenes de la interfaz y de la carpeta temporal.")

# Configuración de la interfaz gráfica
ventana = Tk()
ventana.title("Sistema de Diagnóstico Asistido por Computadora")
ventana.geometry("900x700")  # Tamaño ajustado para visibilidad

# Crear una sola pestaña para Resultados 1
notebook = ttk.Notebook(ventana)
tab1 = Frame(notebook)
notebook.add(tab1, text="Resultados 1")
notebook.pack(expand=1, fill="both")

# Configuración de la pestaña principal (tab1)
Label(tab1, text="Seleccione la acción de análisis", font=("Arial", 12)).pack(pady=10)

# Contenedor para las imágenes de resultado con pestañas
notebook_canvas = ttk.Notebook(tab1)
notebook_canvas.pack(pady=10, expand=1, fill="both")

# Crear un frame de dos columnas para los botones de carga de carpetas y archivos
frame_carga = Frame(ventana)
frame_carga.pack(pady=10, fill="x")

# Columna izquierda para carga de carpetas
frame_botones_carpetas = Frame(frame_carga)
frame_botones_carpetas.pack(side=LEFT, padx=10)

Label(frame_botones_carpetas, text="Cargar Carpetas de Imágenes", font=("Arial", 10)).pack(pady=5)
Button(frame_botones_carpetas, text="Cargar Carpeta 1 (Radiografías Sano)", command=lambda: filedialog.askdirectory(title="Cargar Carpeta 1"), width=25).pack(pady=2)
Button(frame_botones_carpetas, text="Cargar Carpeta 2 (Radiografías Enfermo)", command=lambda: filedialog.askdirectory(title="Cargar Carpeta 2"), width=25).pack(pady=2)
Button(frame_botones_carpetas, text="Borrar Imágenes", command=borrar_imagenes, width=25).pack(pady=2)  # Botón borrar

# Columna derecha para carga de archivos MATLAB
frame_botones_archivos = Frame(frame_carga)
frame_botones_archivos.pack(side=RIGHT, padx=10)

Label(frame_botones_archivos, text="Cargar Archivos MATLAB", font=("Arial", 10)).pack(pady=5)
Button(frame_botones_archivos, text="Cargar diagnosticModel.m", command=lambda: cargar_archivo("diagnosticModel.m"), width=25).pack(pady=2)
Button(frame_botones_archivos, text="Cargar Modelprediction.m", command=lambda: cargar_archivo("Modelprediction.m"), width=25).pack(pady=2)
Button(frame_botones_archivos, text="Cargar trainModel.m", command=lambda: cargar_archivo("trainModel.m"), width=25).pack(pady=2)
Button(frame_botones_archivos, text="Cargar practica.m", command=lambda: cargar_archivo("practica.m"), width=25).pack(pady=2)
Button(frame_botones_archivos, text="Cargar CNN normal.m", command=lambda: cargar_archivo("CNN normal.m"), width=25).pack(pady=2)  # Botón CNN normal

# Botones de control
frame_botones_control = Frame(ventana)
frame_botones_control.pack(side=BOTTOM, pady=10)

Button(frame_botones_control, text="Salir", command=ventana.quit, width=15).pack(side=LEFT, padx=5)

# Ejecutar la ventana principal de la aplicación
ventana.mainloop()

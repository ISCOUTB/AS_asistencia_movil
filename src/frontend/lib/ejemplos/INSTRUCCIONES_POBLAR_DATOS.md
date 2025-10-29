# Guía para Poblar las Tablas con Datos de Ejemplo

## 📋 Descripción

Este script (`poblar_tablas.py`) llena automáticamente las tablas del sistema de asistencias con datos de ejemplo coherentes y relacionados.

## 🎯 Tablas que se Poblarán

### Tablas de Soporte (Referencias)
1. **DEPARTAMENTOS** (3 registros)
2. **MODALIDADES** (3 registros) - Presencial, Virtual, Híbrida
3. **BANNER_PERIODOS** (3 registros) - Periodos académicos
4. **TIPOS_DE_DOCUMENTO** (3 registros) - CC, TI, CE
5. **PUBLICOS_SERVICIOS** (3 registros) - Estudiantes, Docentes, Administrativos
6. **FACILITADORES** (3 registros)
7. **PERSONAS** (4 registros)

### Tablas Principales
8. **SERVICIOS** (3 registros)
   - Tutoría de Microeconomía
   - Taller de Programación Python
   - Seminario de Liderazgo

9. **SESIONES** (3 registros)
   - Una sesión por cada servicio
   - Con diferentes modalidades

10. **ASISTENCIA_SESIONES** (4 registros)
    - Asistencias distribuidas entre las sesiones

## 🔗 Relaciones entre Tablas

```
DEPARTAMENTOS ──┐
                ├──> SERVICIOS ──> SESIONES ──> ASISTENCIA_SESIONES
PUBLICOS ───────┘                    ▲               ▲
                                     │               │
MODALIDADES ─────────────────────────┘               │
FACILITADORES ───────────────────────────────────────┘
PERSONAS ────────────────────────────────────────────┘
BANNER_PERIODOS ─────────────────────────────────────┘
TIPOS_DOCUMENTO ─────────────────────────────────────┘
```

## 📝 Prerequisitos

1. **Backend corriendo**: El servidor FastAPI debe estar ejecutándose en `http://127.0.0.1:8000`
2. **Python instalado**: Python 3.8 o superior
3. **Librería httpx instalada**:
   ```bash
   pip install httpx
   ```

## 🚀 Cómo Ejecutar el Script

### Paso 1: Iniciar el Backend

Abre una terminal y navega al directorio del API:

```powershell
cd "c:\Documents\JorgeM\Arquitectura de Software\Proyecto\pruebas_lab"
.\venv\Scripts\Activate.ps1
cd src\backend\api
uvicorn app:app --reload
```

Espera a que veas el mensaje:
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

### Paso 2: Ejecutar el Script de Población

Abre **otra terminal** (deja el backend corriendo) y ejecuta:

```powershell
cd "c:\Documents\JorgeM\Arquitectura de Software\Proyecto\pruebas_lab"
.\venv\Scripts\Activate.ps1
python poblar_tablas.py
```

### Paso 3: Verificar los Resultados

Verás un output similar a:

```
================================================================================
POBLANDO TABLAS CON DATOS DE EJEMPLO
================================================================================

[1/9] Insertando DEPARTAMENTOS...
  ✓ Departamento 1 creado
  ✓ Departamento 2 creado
  ✓ Departamento 3 creado

[2/9] Insertando MODALIDADES...
  ✓ Modalidad 1 creada
  ✓ Modalidad 2 creada
  ✓ Modalidad 3 creada

...

================================================================================
PROCESO COMPLETADO
================================================================================

Resumen:
  - 3 Departamentos
  - 3 Modalidades
  - 3 Periodos
  - 3 Tipos de Documento
  - 3 Públicos de Servicios
  - 3 Facilitadores
  - 4 Personas
  - 3 Servicios
  - 3 Sesiones
  - 4 Asistencias
================================================================================
```

## 📊 Verificar los Datos

### Opción 1: Usar la Documentación Interactiva de FastAPI

1. Ve a: `http://127.0.0.1:8000/docs`
2. Prueba los endpoints GET de cada tabla:
   - `/servicios/` - Ver todos los servicios
   - `/sesiones/` - Ver todas las sesiones
   - `/asistencia_sesiones/` - Ver todas las asistencias
   - etc.

### Opción 2: Usar el Archivo JSON de Referencia

Revisa el archivo `datos_ejemplo.json` que contiene todos los datos que se insertarán.

## 🔍 Detalles de los Datos de Ejemplo

### Servicios Creados

1. **Tutoría de Microeconomía**
   - Departamento: Economía
   - Público: Estudiantes
   - Periodo: 2024-1

2. **Taller de Programación Python**
   - Departamento: Ingeniería
   - Público: Estudiantes
   - Periodo: 2024-2

3. **Seminario de Liderazgo**
   - Departamento: Administración
   - Público: Docentes y Estudiantes
   - Periodo: 2025-1

### Sesiones Creadas

1. **Tutoría Microeconomía - Grupo A**
   - Modalidad: Presencial
   - Lugar: Edificio E, Salón 301
   - Facilitador: María González
   - Capacidad: 30 personas

2. **Python Básico - Sesión 1**
   - Modalidad: Virtual
   - Lugar: Plataforma Zoom
   - Facilitador: Carlos Rodríguez
   - Capacidad: 40 personas

3. **Seminario Liderazgo - Sesión Inaugural**
   - Modalidad: Híbrida
   - Lugar: Auditorio Principal + Online
   - Facilitador: Ana Martínez
   - Capacidad: 50 personas

### Asistencias Registradas

- Juan Pérez → Tutoría Microeconomía (Presencial)
- Laura Gómez → Tutoría Microeconomía (Presencial)
- Pedro Sánchez → Taller Python (Virtual)
- Sofia López → Seminario Liderazgo (Híbrida)

## ⚠️ Notas Importantes

1. **IDs Automáticos**: El script asume que los IDs se auto-generan en el orden de inserción (1, 2, 3...)
2. **Duplicados**: Si ejecutas el script múltiples veces, puede generar datos duplicados
3. **Errores**: Si alguna tabla ya tiene datos, el script intentará crear los nuevos registros de todas formas
4. **TIMESTAMPS**: Las fechas se generan dinámicamente basadas en la fecha actual

## 🐛 Solución de Problemas

### Error: "Connection refused"
- **Causa**: El backend no está corriendo
- **Solución**: Inicia el servidor con `uvicorn app:app --reload`

### Error: "Module 'httpx' not found"
- **Causa**: La librería httpx no está instalada
- **Solución**: `pip install httpx`

### Error: "HTTP 400" o "HTTP 500"
- **Causa**: Problema con la estructura de datos o foreign keys
- **Solución**: Revisa que todas las tablas referenciadas existan en la base de datos

### Algunos registros fallan pero otros se crean
- **Esto es normal**: El script es tolerante a fallos y continúa con los siguientes registros
- Revisa el output para ver qué registros fallaron

## 📧 Contacto

Si tienes problemas o preguntas sobre este script, contacta al equipo de desarrollo.

---

**Fecha de creación**: 7 de octubre de 2025  
**Versión**: 1.0

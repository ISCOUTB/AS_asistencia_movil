# /docs/images/arc42-logo.png

**Acerca de arc42**

arc42, La plantilla de documentación para arquitectura de sistemas y de
software.

Por Dr. Gernot Starke, Dr. Peter Hruschka y otros contribuyentes.

Revisión de la plantilla: 7.0 ES (basada en asciidoc), Enero 2017

© Reconocemos que este documento utiliza material de la plantilla de
arquitectura arc42, <https://www.arc42.org>. Creada por Dr. Peter
Hruschka y Dr. Gernot Starke.

# Introducción y Metas

## Vista de Requerimientos

### 👤 Actores principales
- **Estudiantes / Empleados** → Registran su asistencia.
- **Docentes / Jefes / Supervisores** → Validan, consultan reportes y gestionan asistencia.  
- **Administradores** → Configuran horarios, grupos, usuarios y reglas.  
- **Sistema (API / Backend)** → Valida, procesa y guarda los datos.
---
### ✅ Requerimientos Funcionales
1. **Registro de asistencia**
   - Marcar entrada y salida desde la app.  
   - Validación por red Wi-Fi institucional.  
   - Escaneo QR en el aula/empresa.  

2. **Autenticación y autorización**
   - Login seguro con usuario/contraseña o SSO (Google/Microsoft).  
   - Roles: estudiante/empleado, docente/supervisor, administrador.  

3. **Reportes y consultas**
   - Historial de asistencia individual.  
   - Reportes por curso, grupo, departamento o periodo.  
   - Exportación a Excel/PDF.  

4. **Notificaciones**
   - Alertas push para recordar marcar asistencia.  
   - Notificaciones de inasistencias o retrasos.  

5. **Integraciones**
   - API REST para conexión con sistemas académicos.  
   - Panel web admin para gestión centralizada.  
---
### ⚙️ Requerimientos No Funcionales
1. **Disponibilidad**  
   - App y backend accesibles 24/7, con redundancia en servidores críticos.  

2. **Escalabilidad**  
   - Soporte para miles de usuarios concurrentes (universidades/empresas grandes).  

3. **Seguridad**  
   - Comunicación cifrada (HTTPS + TLS).  
   - Tokens JWT / OAuth2 para sesiones seguras.  
   - Protección de datos personales (GDPR / Habeas Data).  

4. **Rendimiento**  
   - Tiempo de respuesta < 2 segundos en operaciones comunes.  
   - Manejo eficiente de reportes masivos.  

5. **Portabilidad**  
   - App disponible en **Android** y **iOS**.  
   - Versión web opcional, compatible con navegadores modernos.  

6. **Usabilidad**  
   - Interfaz intuitiva, multilenguaje.  
   - Accesible según normas WCAG.  

7. **Mantenibilidad**  
   - Código modular (Clean Architecture en app, microservicios en backend).  
   - Documentación clara para integraciones.
---
### 🏗️ Componentes de Arquitectura (Alto Nivel)
- **App móvil (Flutter)**
  → UI, autenticación,  escaneo QR, notificaciones.  

- **API Gateway / Backend (ORACLE Apex)**  
  → Autenticación, lógica de negocio, validación de asistencia, conexión con DB.

- **Base de datos (Oracle Database)**  
  → Usuarios, horarios, registros de asistencia.  

- **Módulo de analítica y reportes**  
  → Generación de reportes, estadísticas, integración BI.

## Metas de Calidad

## Partes interesadas (Stakeholders)

| Rol       | Nombre completo                  | Contacto | Expectativas |
|-----------|----------------------------------|----------|--------------|
| Profesor Titular | Jairo Enrique Serrano Castañeda  | [jserrano@utb.edu.co](mailto:jserrano@utb.edu.co) | Que la arquitectura de la API se integre eficientemente con la aplicación móvil, asegurando escalabilidad, seguridad y un rendimiento óptimo en dispositivos nativos. |
| Ingeniero de Desarrollo TIC | Elian Andres Vega Hernandez      | [vegae@utb.edu.co](mailto:vegae@utb.edu.co) | Que la aplicación móvil facilite el acceso a los registros de asistencia de manera confiable y en tiempo real |

# Restricciones de la Arquitectura 

# Alcance y Contexto del Sistema

## Contexto de Negocio

**\<Diagrama o Tabla>**

**\<optionally: Explanation of external domain interfaces>**

## Contexto Técnico

**\<Diagrama o Tabla>**

**\<Opcional: Explicación de las interfases técnicas>**

**\<Mapeo de Entrada/Salida a canales>**

# Estrategia de solución

# Vista de Bloques

## Sistema General de Caja Blanca

***\<Diagrama general>***

Motivación

:   *\<Explicación en texto>*

Bloques de construcción contenidos

:   *\<Desripción de los bloques de construcción contenidos (Cajas
    negras)>*

Interfases importantes

:   *\<Descripción de las interfases importantes>*

### \<Caja Negra 1>

*\<Propósito/Responsabilidad>*

*\<Interfase(s)>*

*\<(Opcional) Características de Calidad/Performance>*

*\<(Opcional) Ubicación Archivo/Directorio>*

*\<(Opcional) Requerimientos Satisfechos>*

*\<(Opcional) Riesgos/Problemas/Incidentes Abiertos>*

### \<Caja Negra 2>

*\<plantilla de caja negra>*

### \<Caja Negra N>

*\<Plantilla de caja negra>*

### \<Interfase 1>

...

### \<Interfase m>

## Nivel 2 {#_nivel_2}

### Caja Blanca *\<bloque de construcción 1>*

*\<plantilla de caja blanca>*

### Caja Blanca *\<bloque de construcción 2>*

*\<plantilla de caja blanca>*

...

### Caja Blanca *\<bloque de construcción m>*

*\<plantilla de caja blanca>*

## Nivel 3 {#_nivel_3}

### Caja Blanca \<\_bloque de construcción x.1\_\>

*\<plantilla de caja blanca>*

### Caja Blanca \<\_bloque de construcción x.2\_\>

*\<plantilla de caja blanca>*

### Caja Blanca \<\_bloque de construcción y.1\_\>

*\<plantilla de caja blanca>*

# Vista de Ejecución 

## \<Escenario de ejecución 1>

-   *\<Inserte un diagrama de ejecución o la descripción del escenario>*

-   *\<Inserte la descripción de aspectos notables de las interacciones
    entre los bloques de construcción mostrados en este diagrama.\>*

## \<Escenario de ejecución 2>

## ... {#_}

## \<Escenario de ejecución n>

# Vista de Despliegue

## Nivel de infraestructura 1

***\<Diagrama General>***

Motivación

:   *\<Explicación en forma textual>*

Características de Calidad/Rendimiento

:   *\<Explicación en forma textual>*

    Mapeo de los Bloques de Construcción a Infraestructura

    :   *\<Descripción del mapeo>*

## Nivel de Infraestructura 2

### *\<Elemento de Infraestructura 1>*

*\<diagrama + explicación>*

### *\<Elemento de Infraestructura 2>*

*\<diagrama + explicación>*

...

### *\<Elemento de Infraestructura n>*

*\<diagrama + explicación>*

# Conceptos Transversales (Cross-cutting)

## *\<Concepto 1>* {#__emphasis_concepto_1_emphasis}

*\<explicación>*

## *\<Concepto 2>* {#__emphasis_concepto_2_emphasis}

*\<explicación>*

...

## *\<Concepto n>* {#__emphasis_concepto_n_emphasis}

*\<explicación>*

# Decisiones de Diseño

# Requerimientos de Calidad

## Árbol de Calidad {#__rbol_de_calidad}

## Escenarios de calidad {#_escenarios_de_calidad}

# Riesgos y deuda técnica

# Glosario

| Término       | Definición      |
|---------------|-----------------|
| **<Término-1>** | *<definición-1>* |
| **<Término-2>** | *<definición-2>* |


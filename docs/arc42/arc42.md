![Logo arc42](./images/arc42-logo.png)


**Acerca de arc42**

arc42, La plantilla de documentación para arquitectura de sistemas y de
software.

Por Dr. Gernot Starke, Dr. Peter Hruschka y otros contribuyentes.

Revisión de la plantilla: 7.0 ES (basada en asciidoc), Enero 2017

© Reconocemos que este documento utiliza material de la plantilla de
arquitectura arc42, <https://www.arc42.org>. Creada por Dr. Peter
Hruschka y Dr. Gernot Starke.

# 1. Introducción y Metas
Este apartado describe los requisitos relevantes y las fuerzas impulsoras que los arquitectos de software y el equipo de desarrollo deben considerar. Incluye los **objetivos de negocio**, las **funcionalidades esenciales y requisitos funcionales del sistema**, los **objetivos de calidad de la arquitectura** y los **stakeholders con sus expectativas**. Estos serán los objetivos establecidos para este sistema:

| Priority | Descripción                                                                                                      |
|----------|------------------------------------------------------------------------------------------------------------------|
| 1        | Validar la funcionalidad básica de registro de asistencias desde una aplicación móvil con simplicidad y seguridad. |
| 2        | Resolver los problemas de procesos manuales que generan errores, retrasos y falta de información centralizada.    |
| 3        | Prevenir la suplantación o marcas falsas mediante validación de escaneo QR.                     |
| 4        | Permitir autenticación básica de usuarios, gestión mínima de usuarios y horarios.                                |
| 5        | Habilitar consultas de asistencia y generación de reportes simples en el backend.                                |
| 6        | Incluir notificaciones básicas de recordatorio y alertas por ausencias o retrasos.                               |
| 7        | Servir como base para recopilar retroalimentación de usuarios antes de escalar hacia una solución más robusta.   |


## 1.2 Vista de Requerimientos

### 1.2.1 Actores principales
- **Estudiantes / Empleados** → Registran su asistencia.
- **Docentes / Jefes / Supervisores** → Validan, consultan reportes y gestionan asistencia.  
- **Administradores** → Configuran horarios, grupos, usuarios y reglas.  
- **Sistema (API / Backend)** → Valida, procesa y guarda los datos.

### 1.2.2 Requerimientos Funcionales

| Id   | Requirement                 | Explanation                                                                 |
|------|-----------------------------|-----------------------------------------------------------------------------|
| RF1  | Registro de asistencia      | Permitir a los usuarios marcar entrada y salida desde la aplicación móvil. Validación por escaneo QR en el aula/empresa. |
| RF2  | Autenticación y autorización| Acceso seguro mediante usuario/contraseña o SSO (Microsoft). Manejo de roles: estudiante/empleado, docente/supervisor, administrador. |
| RF3  | Reportes y consultas        | Generar historial de asistencia individual y reportes por curso, grupo, departamento o periodo. Posibilidad de exportación a Excel/PDF. |
| RF4  | Notificaciones              | Enviar alertas push para recordar marcar asistencia y notificaciones de inasistencias o retrasos. |
| RF5  | Integraciones               | Proveer API REST para conexión con sistemas académicos y panel web de administración centralizada. |

---

### 1.2.3 Requerimientos No Funcionales

| Id   | Requirement       | Explanation                                                                 |
|------|------------------|-----------------------------------------------------------------------------|
| RNF1 | Disponibilidad   | El sistema debe estar disponible 24/7. Backend con redundancia en servidores críticos. |
| RNF2 | Escalabilidad    | Soporte para miles de usuarios concurrentes (ejemplo: universidades grandes). |
| RNF3 | Seguridad        | Comunicación cifrada (HTTPS + TLS). Tokens JWT / OAuth2. Cumplimiento de GDPR/Habeas Data. |
| RNF4 | Rendimiento      | Tiempo de respuesta < 2 segundos en operaciones comunes. Manejo eficiente de reportes masivos. |
| RNF5 | Portabilidad     | App disponible en Android e iOS. Versión web compatible con navegadores modernos. |
| RNF6 | Usabilidad       | Interfaz intuitiva, multilenguaje y accesible según normas WCAG. |
| RNF7 | Mantenibilidad   | Código modular (Clean Architecture, microservicios). Documentación clara para integraciones. |


### 1.2.4 Componentes de Arquitectura (Alto Nivel)
- **App móvil (Flutter)**
  → UI, autenticación,  escaneo QR, notificaciones.  

- **API Gateway / Backend (ORACLE Apex)**  
  → Autenticación, lógica de negocio, validación de asistencia, conexión con DB.

- **Base de datos (Oracle Database)**  
  → Usuarios, horarios, registros de asistencia.  

- **Módulo de analítica y reportes**  
  → Generación de reportes, estadísticas

## 1.3 Metas de Calidad

| ID    | Meta de Calidad | Descripción                                                                                          | Prioridad |
|-------|-----------------|------------------------------------------------------------------------------------------------------|-----------|
| 1.3.1 | Disponibilidad  | Garantizar **99.5% de disponibilidad** del sistema (24/7).                                           | Alta      |
| 1.3.2 | Escalabilidad   | Soportar al menos **5.000 usuarios concurrentes** en la fase inicial.                                | Alta      |
| 1.3.3 | Seguridad       | Comunicación cifrada con **HTTPS + TLS 1.3**. Autenticación con **JWT / OAuth2**. Cumplimiento de **GDPR / Habeas Data**. | Alta      |
| 1.3.4 | Rendimiento     | Tiempo de respuesta promedio **< 2 segundos** en registros y consultas. Reportes masivos en **< 30 segundos**. | Alta      |
| 1.3.5 | Portabilidad    | Aplicación disponible en **Android** y **iOS**.                                                      | Media     |
| 1.3.6 | Usabilidad      | Interfaz intuitiva, curva de aprendizaje **< 10 min**. Soporte **multilenguaje (ES/EN)**. Cumplimiento de **WCAG 2.1**. | Alta      |
| 1.3.7 | Mantenibilidad  | Arquitectura modular (**Clean Architecture / Microservicios**). Documentación técnica actualizada. | Media     |
| 1.3.8 | Confiabilidad   | Garantizar que el **99% de registros de asistencia** se procesen sin pérdida de datos. Respaldo automático de la base de datos cada **24h**. | Alta      |

## 1.4 Partes interesadas (Stakeholders)

| Rol       | Nombre completo                  | Contacto | Expectativas |
|-----------|----------------------------------|----------|--------------|
| Profesor Titular | Jairo Enrique Serrano Castañeda  | [jserrano@utb.edu.co](mailto:jserrano@utb.edu.co) | Que la arquitectura de la API se integre eficientemente con la aplicación móvil, asegurando escalabilidad, seguridad y un rendimiento óptimo en dispositivos nativos. |
| Ingeniero de Desarrollo TIC | Elian Andres Vega Hernandez      | [vegae@utb.edu.co](mailto:vegae@utb.edu.co) | Que la aplicación móvil facilite el acceso a los registros de asistencia de manera confiable y en tiempo real |

---

# 2. Restricciones de la Arquitectura

## 2.1 Restricciones Tecnológicas  

- La app debe desarrollarse en **Flutter** para asegurar compatibilidad en Android e iOS.  
- El backend debe implementarse en **ORACLE Apex**, priorizando escalabilidad y modularidad.  
- La base de datos debe ser **Oracle**, con **Redis** como caché para optimizar el rendimiento.  
- Toda comunicación debe realizarse mediante **HTTPS/TLS**.  

## 2.2 Restricciones Operativas

- El sistema debe estar disponible **24/7**, con un máximo de **3 horas de inactividad mensual**.  
- Los registros de asistencia deben conservarse por un período mínimo de **2 años**.  
- Solo se permiten integraciones con **APIs públicas y seguras**.  
- La aplicación debe funcionar en redes **Wi-Fi**.  

## 2.3 Restricciones Organizacionales

- Cumplimiento estricto de normativas de protección de datos (**GDPR / Habeas Data**).  
- Acceso a funcionalidades restringido por **roles definidos** (estudiante/empleado, docente/supervisor, administrador).  
- Los reportes solo pueden ser consultados por **docentes, supervisores o administradores**.  
- La arquitectura de software debe seguir principios de **Clean Architecture** y **microservicios**.  

## 2.4 Restricciones de Integración

- El backend debe exponer un **API REST documentado con Swagger/OpenAPI**.  
- El consumo de la API debe limitarse a **1000 requests por minuto por usuario autenticado**.  
- Toda integración externa debe pasar por **módulos autorizados y controlados**.  

## 2.5 Restricciones de Seguridad

- La autenticación debe implementarse con **JWT u OAuth2**.  
- Los datos sensibles (contraseñas, tokens) deben almacenarse de forma **cifrada o hasheada (bcrypt, AES)**.  
- Todos los accesos deben estar controlados por **roles y permisos definidos**.

---

# 3. Alcance y Contexto del Sistema

## 3.1 Alcance del Sistema

El sistema de **Control de Asistencia** tiene como objetivo principal **digitalizar y automatizar el control de asistencia** en instituciones educativas y organizaciones empresariales, reduciendo procesos manuales y mejorando la precisión en los registros.  

### 3.1.1 Funcionalidades dentro del alcance

- Registro de asistencia mediante **app móvil** (entrada y salida).  
- Validación de asistencia mediante **QR**.  
- **Autenticación segura** con usuario/contraseña o SSO (Google/Microsoft).  
- Gestión de **horarios, grupos, cursos, jornadas**.  
- Consulta y generación de **reportes individuales y grupales** en distintos formatos (Excel/PDF).  
- **Notificaciones push** para recordatorios, retrasos e inasistencias.  
- **Panel web administrativo** para gestión centralizada.

### 3.1.2 Funcionalidades fuera del alcance (MVP inicial)

- Reconocimiento facial o biometría avanzada
- Inteligencia artificial para predicción de ausentismo.  
- Funcionalidades offline completas (solo cache limitado).  

## 3.2 Contexto del Sistema  

### 3.2.1 Actores principales

- **Estudiantes / Empleados** → Registran su asistencia desde la app móvil.  
- **Docentes / Supervisores / Jefes** → Validan, consultan y gestionan asistencia.  
- **Administradores** → Configuran horarios, grupos y usuarios.  
- **Sistema (Backend + API)** → Procesa, valida y almacena la información de asistencia.  

### 3.2.2 Interacciones con el entorno

- **App móvil** (Android/iOS) → Punto de interacción principal para usuarios finales.  
- **Panel Web** → Para administradores y supervisores que gestionan y consultan datos.  
- **Base de datos centralizada** (Oracle) → Almacena usuarios, horarios y registros.

## 3.3 Contexto de Negocio

El sistema de **Toma de Asistencia** busca digitalizar y automatizar el proceso de registro y control de asistencia en instituciones educativas y organizaciones.  
El modelo de negocio contempla tres tipos de actores principales:  

- **Estudiantes / Empleados**: registran su asistencia mediante la aplicación móvil, usando mecanismos como GPS, QR, NFC o Wi-Fi institucional.  
- **Docentes / Supervisores**: consultan y validan la asistencia en tiempo real desde la app móvil o un panel web.  
- **Administradores**: gestionan usuarios, horarios, grupos y reglas de asistencia a través de un panel web.  

Además, el sistema debe integrarse con **sistemas académicos y de recursos humanos**, permitiendo exportar registros y sincronizar información con otras plataformas.

```mermaid
flowchart TD
    A[👤 Estudiantes / Empleados] -->|Registrar asistencia| B[📱 App Móvil]
    D[👨‍🏫 Docentes / Supervisores] -->|Validar / Consultar| B
    E[⚙️ Administradores] -->|Configurar horarios / usuarios| B

    B -->|Procesa y valida| C[🖥️ Backend / API]
    C -->|📊 Reportes / Datos| F[📂 Sistemas Académicos / RRHH]
```

## 3.4 Contexto Técnico

El sistema se compone de los siguientes elementos:  

- **App Móvil (Android/iOS)**: punto de interacción principal para estudiantes y empleados, que permite el registro de asistencia y la consulta de historial.  
- **Panel Web**: herramienta administrativa para la gestión de usuarios, horarios y generación de reportes.  
- **Backend / API Gateway**: núcleo de la lógica de negocio, encargado de procesar registros, validar condiciones y exponer APIs REST seguras.  
- **Base de Datos SQL (Oracle)**: almacenamiento principal de usuarios, horarios y registros de asistencia.  
- **Redis**: soporte para cache y consultas rápidas.

### 3.4.1 Mapeo de Entrada/Salida a Canales  

#### Entradas

- Desde **App Móvil**: registro de asistencia (QR), login seguro.  
- Desde **Panel Web**: gestión de usuarios, horarios, grupos y reportes.  

#### Procesamiento

- Validación de identidad y autenticación.  
- Aplicación de reglas de negocio (asistencia válida, tardanza, ausencia).  
- Almacenamiento en base de datos.  
- Uso de cache con Redis para optimizar consultas.  

#### Salidas

- Hacia **App Móvil**: confirmación de asistencia registrada, historial individual y notificaciones push.  
- Hacia **Panel Web**: reportes en PDF/Excel, estadísticas y gestión de datos.  

```mermaid
flowchart TD
  M[📱 App Móvil] -->|API REST| N[🌐 Backend / API Gateway]
  W[💻 Panel Web Admin] -->|Gestión de usuarios/horarios| N
  N -->|📂 CRUD Asistencia| O[(🗄️ Base de Datos)]
  N -->|🔔 Notificaciones| P[(Firebase/Push Service)]
  N -->|🌍 Geolocalización| Q[(Google Maps API)]
```

# 4. Estrategia de solución

## 4.1 Objetivos

Definir cómo se estructurará la arquitectura del sistema de Toma de Asistencias desde App Móvil para garantizar:

- Disponibilidad
- Seguridad
- Escalabilidad
- Rendimiento

## 4.2 Lineamientos Estratégicos

### 4.2.1. Arquitectura Basada en Servicios

- Modularización del sistema:
  - Captura de Asistencia (App móvil)
  - Gestión de Usuarios y Roles
  - Gestión de Horarios y Sesiones
  - API Backend de Validación y Procesamiento
  - Reportes y Analítica
- Beneficios: escalabilidad, mantenibilidad y separación de responsabilidades.

---

### 4.2.2 Interfaz de Usuario (App Móvil)

- Aplicación híbrida (Flutter).
- Funcionalidad offline con sincronización en línea.
- Autenticación segura mediante JWT u OAuth 2.0.

---

### 4.2.3 Comunicación y Backend

- API RESTful para validación y procesamiento de datos.
- Backend ligero (Oracle Apex).
- Control de accesos basado en roles (RBAC).
- Validaciones de integridad en tiempo real.

---

### 4.2.4 Gestión de Datos

- Base de datos relacional (Oracle).
- Cacheo con Redis para mejorar rendimiento.
- Almacenamiento histórico de asistencia con trazabilidad.

---

### 4.2.5 Seguridad

- Encriptación en tránsito (HTTPS + TLS).
- Autenticación con tokens JWT.
- Cumplimiento con normativas de protección de datos.

---

### 4.2.6 Integración con Sistemas Externos

- Reportes automáticos en PDF / Excel.

---

### 4.2.7 Infraestructura

- Despliegue con contenedores Docker.
- Despliegue en la nube (AWS, Azure, GCP) o en servidores locales.
- Balanceadores de carga para asegurar disponibilidad.

---

### 4.2.8 Monitoreo y Observabilidad

- Métricas con Prometheus + Grafana.

---

## 4.3 Decisiones Arquitectónicas

- Arquitectura modular con servicios desacoplados.
- Uso de tecnologías ligeras y escalables (Oracle Apex, Flutter).
- Base de datos relacional con soporte a integridad y relaciones complejas.
- Seguridad como prioridad en autenticación, cifrado y auditoría.

---

## 4.4 Trade-offs

- **Microservicios vs Monolito:** Se inicia con servicios modulares (menor complejidad) con visión futura hacia microservicios completos.
- **Infraestructura en la nube vs on-premise:** Dependerá del presupuesto y políticas de la institución.
- **Funcionalidad offline:** Aumenta complejidad técnica pero garantiza continuidad del servicio.

---

## 4.5 Riesgos Potenciales

- Gestión de seguridad y privacidad de datos sensibles.
- Complejidad en el mantenimiento de sincronización offline/online.
- Escalabilidad limitada si no se implementa orquestación adecuada en fases iniciales.

# 5. Vista de Bloques

## 5.1 Sistema General de Caja Blanca

# 6. Vista de Ejecución

# 7. Vista de Despliegue

# 8. Conceptos Transversales (Cross-cutting)

# 9. Decisiones de Diseño

# 10. Requerimientos de Calidad

## 10.1 Quality Goals

| Meta de Calidad   | Descripción                                                                 | Prioridad |
|-------------------|-----------------------------------------------------------------------------|-----------|
| Seguridad         | Garantizar que los datos de asistencia estén protegidos mediante cifrado y autenticación segura. | Alta |
| Rendimiento       | El sistema debe responder rápidamente a los registros y consultas (<2s promedio). | Alta |
| Usabilidad        | La aplicación móvil debe ser intuitiva y sencilla para estudiantes y docentes. | Alta |
| Mantenibilidad    | El sistema debe ser fácil de extender (ej. agregar biometría o nuevos reportes). | Media |
| Disponibilidad    | El sistema debe estar disponible al menos el 99% del tiempo lectivo.        | Alta |
| Portabilidad      | El sistema debe funcionar en dispositivos Android, iOS y navegadores modernos. | Media |

## 10.2 Escenarios de Calidad

| ID     | Descripción                                                                                          |
|--------|------------------------------------------------------------------------------------------------------|
| 10.2.1 | El sistema deberá garantizar **99.5% de disponibilidad** midiendo el uptime mensual del servicio.     |
| 10.2.2 | La plataforma debe escalar horizontalmente para soportar **5.000 usuarios concurrentes** sin degradar el rendimiento. |
| 10.2.3 | Toda comunicación entre cliente y servidor deberá estar cifrada bajo **HTTPS + TLS 1.3**.             |
| 10.2.4 | El backend deberá validar autenticación mediante **JWT / OAuth2** en cada solicitud de usuario.       |
| 10.2.5 | El sistema deberá cumplir con regulaciones de protección de datos (**GDPR / Habeas Data**).           |
| 10.2.6 | El tiempo promedio de respuesta para operaciones de registro y consulta será **< 2 segundos**.        |
| 10.2.7 | La generación de reportes masivos deberá completarse en menos de **30 segundos**.                     |
| 10.2.8 | La aplicación móvil deberá estar disponible en **Android** y **iOS** desde el MVP.                    |
| 10.2.9 | La interfaz deberá permitir que un nuevo usuario aprenda a usarla en máximo **10 minutos**.           |
| 10.2.10| El sistema deberá ofrecer **soporte multilenguaje (mínimo ES/EN)** desde la interfaz principal.       |
| 10.2.11| La aplicación deberá cumplir con los lineamientos de accesibilidad **WCAG 2.1**.                      |
| 10.2.12| El sistema deberá estar diseñado en **arquitectura modular (Clean / Microservicios)** para facilitar mantenibilidad. |
| 10.2.13| La documentación técnica deberá mantenerse actualizada en el repositorio oficial.                     |
| 10.2.14| El equipo deberá resolver incidencias críticas en un tiempo menor a **48 horas**.                     |
| 10.2.15| El sistema deberá garantizar que el **99% de los registros de asistencia** se procesen sin pérdida de datos. |
| 10.2.16| Se deberán realizar **respaldos automáticos de la base de datos cada 24h** sin interrumpir la operación. |

## 10.3 Árbol de Calidad

# 11. Riesgos y deuda técnica

# 12. Glosario
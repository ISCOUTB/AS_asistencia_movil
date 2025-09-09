# AS_asistencia_movil: Toma de asistencia desde APP móvil

## 📑 Tabla de Contenidos
1. [Resumen](#resumen)  
2. [Características Principales del MVP](#-características-principales-del-mvp)  
   - [Autenticación básica](#-autenticación-básica)  
   - [Registro de asistencia](#-registro-de-asistencia)  
   - [Gestión de usuarios y horarios](#-gestión-de-usuarios-y-horarios)  
   - [Consultas y reportes iniciales](#-consultas-y-reportes-iniciales)  
   - [Notificaciones básicas](#-notificaciones-básicas)  
3. [Soporte Docker](#-soporte-docker)  
4. [Status del Proyecto](#-status-del-proyecto)  
5. [Estructura del Proyecto](#-estructura-del-proyecto)  
6. [Equipo de Desarrollo](#-equipo-de-desarrollo)  

## Resumen

El sistema de Control de Asistencia tiene como objetivo principal digitalizar y automatizar el control de asistencia en instituciones educativas y organizaciones empresariales, reduciendo procesos manuales y mejorando la precisión en los registros.

---

## 🚦 Características Principales del MVP

La solución propuesta es un **MVP de aplicación móvil** conectada a un backend que permita:

- ✅ **Registrar asistencia** mediante validación de escaneo de código QR.  
- ✅ **Autenticación básica de usuarios** (inicio de sesión con credenciales).  
- ✅ **Gestión mínima de usuarios y horarios** (grupos/cursos o turnos).  
- ✅ **Consultas y reportes simples** para estudiantes/empleados y administradores.  
- ✅ **Notificaciones básicas** de recordatorio y alertas de ausencia.  

### 🔑 Autenticación básica

- Inicio de sesión con usuario y contraseña.  
- Roles iniciales: **estudiante/empleado** y **administrador**.  

### 🕒 Registro de asistencia

- Marcación de **entrada y salida**.  
- Validación mediante **código QR** o enlace seguro.  

### 👥 Gestión de usuarios y horarios

- Registro básico de usuarios.  
- Definición de **grupos/cursos o turnos simples**.  

### 📊 Consultas y reportes iniciales

- Visualización de **historial personal** de asistencia.  
- Reportes básicos por **grupo o curso**.  

### 🔔 Notificaciones básicas

- Recordatorio **push** para marcar asistencia.  
- Alerta en caso de **ausencia o retraso**.

---

## 🚀 Soporte Docker

Los ambientes de desarrollo y despliegue se encontrarán contenerizados en un `Dockerfile` personalizado, compatible con sistemas Linux. Eso incluirá toda las configuraciones necesarias y las dependencias para una replicación de ambiente consistente.

---

## 📈 Status del Proyecto

> **Fase Actual:** En progreso

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=ISCODEVUTB_PublicTransitAgency&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=ISCODEVUTB_PublicTransitAgency)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=ISCODEVUTB_PublicTransitAgency&metric=coverage)](https://sonarcloud.io/summary/new_code?id=ISCODEVUTB_PublicTransitAgency)

## 🗂️ Estructura del Proyecto

```
AS_ASISTENCIA_MOVIL
│── .github/
│ └── workflows/
│
│── docs/
│ └── arc42/
│
│── src/
│ ├── apex/
│ │ ├── apex-exports/
│ │ ├── scripts/
│ │ ├── templates/
│ │ └── apex.md
│ │
│ ├── business/
│ │ ├── functions/
│ │ ├── packages/
│ │ └── procedures/
│ │
│ ├── data/
│ │ ├── demo/
│ │ ├── seeds/
│ │ └── data.md
│ │
│ ├── docker/
│ ├── persistance/
│ ├── sequences/
│ ├── tables/
│ ├── triggers/
│ └── views/
│
│── tests/
│ ├── integration/
│ └── unit/
│
│── LICENSE
│── README.md
└── sonar-project.properties
```

---

## 👥 Equipo de Desarrollo

- **William David Lozano Julio - T00078475** 
- **Jorge Mario Benavides Angulo - T00077509**
- **Andrés Felipe Rubiano Marrugo - T00077084**

---

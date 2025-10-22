# UTB Assists - Sistema de Asistencias UTB

## 🚀 Inicio Rápido

### Ejecutar en Motorola
```cmd
ejecutar_en_motorola.bat
```

### Generar APK
```cmd
generar_apk.bat
```

### Iniciar Backend
```cmd
iniciar_backend.bat
```

## � Configuración

**Nombre de la App:** UTB Assists  
**Package:** com.example.asistencia_movil  
**Dispositivo:** Motorola Edge 50 Fusion (ZY22LGHHMP)

## 📁 Estructura
```
├── src/
│   ├── backend/api/     # FastAPI Backend
│   └── frontend/        # Flutter App
├── venv/                # Ambiente Virtual Python
└── *.bat                # Scripts de ejecución
```

## ⚙️ Setup Completado

✅ Ambiente virtual Python creado  
✅ Dependencias instaladas (Python + Flutter)  
✅ Nombre "UTB Assists" configurado  
✅ Scripts de automatización creados  

## 🔧 Comandos Manuales

**Ejecutar en dispositivo:**
```powershell
cd src\frontend
flutter run -d ZY22LGHHMP
```

**Generar APK:**
```powershell
cd src\frontend
flutter build apk --release
```

**Iniciar Backend:**
```powershell
.\venv\Scripts\python.exe -m uvicorn src.backend.api.app:app --reload --host 0.0.0.0 --port 8000
```

## � Notas

- Backend API: http://localhost:8000/docs
- Hot Reload: Presiona `r` cuando la app está corriendo
- Cambios mínimos y reversibles realizados
- Sin modificaciones en integraciones

## 🎯 Próximos Pasos

- Configurar credenciales de Azure AD en `src/frontend/.env`
- Mejorar interfaz gráfica
- Optimizar rendimiento

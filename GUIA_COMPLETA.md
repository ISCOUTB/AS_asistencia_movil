# 📱 UTB Assists - Guía Completa

## ✅ Estado Actual del Proyecto

**Sistema de Login Básico Implementado**

### Login de Prueba:
- **Profesor/Facilitador:** Usa un correo con "profesor" o "facilitador" (ej: `profesor@utb.edu.co`)
- **Estudiante:** Cualquier otro correo (ej: `estudiante@utb.edu.co`)
- **Contraseña:** Cualquiera (por ahora no se valida)

### Configuración Completada:
- ✅ Nombre de la app: "UTB Assists"
- ✅ Login básico funcional
- ✅ Navegación según tipo de usuario
- ✅ Redirect URI corregido
- ✅ Ambiente virtual Python configurado
- ✅ Dependencias instaladas (Backend y Frontend)

---

## 🚀 Comandos Rápidos

### Usar Scripts (Más Fácil):
```cmd
ejecutar_en_motorola.bat    # Ejecutar en tu Motorola
generar_apk.bat              # Crear APK para distribuir
iniciar_backend.bat          # Iniciar servidor API
```

### Comandos Manuales:
```powershell
# Ejecutar en dispositivo
cd src\frontend
flutter run -d ZY22LGHHMP

# Generar APK de producción
cd src\frontend
flutter build apk --release

# Iniciar backend
.\venv\Scripts\python.exe -m uvicorn src.backend.api.app:app --reload --host 0.0.0.0 --port 8000
```

---

## 🎮 Hot Reload (Mientras la App Corre)

Cuando la app está corriendo en tu Motorola, en la terminal puedes usar:
- `r` - Hot reload (recarga cambios rápidamente)
- `R` - Hot restart (reinicia completamente)
- `q` - Salir

---

## ⚙️ Configuración Importante

### Credenciales de Microsoft Azure (Opcional)
Edita `src/frontend/.env` y configura:
```
MICROSOFT_CLIENT_ID=tu_client_id_aqui
MICROSOFT_TENANT_ID=tu_tenant_id_aqui
MICROSOFT_REDIRECT_URI=com.example.asistencia_movil.auth://callback
```

Si no tienes estas credenciales aún, la app seguirá funcionando sin autenticación de Microsoft.

---

## 📦 Generar APK para Instalar en Otros Dispositivos

1. Ejecuta: `generar_apk.bat`
2. El APK se creará en: `src\frontend\build\app\outputs\flutter-apk\app-release.apk`
3. Copia ese archivo a cualquier Android y lo puedes instalar

---

## 🔧 Cambios Realizados (Todos Reversibles)

### Archivos Modificados:
1. `src/frontend/pubspec.yaml` - Descripción actualizada
2. `src/frontend/android/app/src/main/AndroidManifest.xml` - Nombre "UTB Assists"
3. `src/frontend/android/app/build.gradle.kts` - Package corregido
4. `src/frontend/lib/main.dart` - Carga segura del archivo .env

### Archivos Creados:
- `.gitignore` - Para control de versiones
- `README.md` - Documentación
- `src/frontend/.env` - Configuración (no se sube a git)
- `ejecutar_en_motorola.bat` - Script de ejecución
- `generar_apk.bat` - Script para APK
- `iniciar_backend.bat` - Script para backend

**Nota:** NO se modificaron las integraciones ni la lógica de negocio

---

## 🎯 Información Técnica

**Dispositivo:** Motorola Edge 50 Fusion (ID: ZY22LGHHMP)  
**Package:** com.example.asistencia_movil  
**Versión:** 1.0.0+1  
**Backend:** http://localhost:8000/docs

---

## 🐛 Solución de Problemas

### La app no compila o tiene errores:
```powershell
cd src\frontend
flutter clean
flutter pub get
flutter run -d ZY22LGHHMP
```

### El backend no inicia:
```powershell
.\venv\Scripts\python.exe -m pip install -r requirements.txt
iniciar_backend.bat
```

### No se detecta el dispositivo:
1. Habilita "Depuración USB" en tu Motorola
2. Conecta el cable USB
3. Ejecuta: `flutter devices`

---

## 📝 Próximos Pasos Sugeridos

1. **Ahora:** Probar la aplicación en tu dispositivo
2. **Luego:** Configurar credenciales de Azure AD (si las tienes)
3. **Después:** Mejorar la interfaz gráfica
4. **Finalmente:** Generar APK de producción para distribuir

---

**Fecha:** 15 de octubre de 2025  
**Estado:** ✅ Aplicación funcionando correctamente  
**Listo para:** Desarrollo y pruebas

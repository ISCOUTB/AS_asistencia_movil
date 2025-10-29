# 📋 Modelos Pydantic Corregidos

**Fecha:** 7 de octubre de 2025  
**Estado:** ✅ Todos los modelos actualizados según metadata real de Oracle ORDS

---

## 🎯 Resumen de Correcciones

Todos los modelos en `src/backend/api/models/` han sido actualizados para coincidir **exactamente** con la estructura real de las tablas en Oracle ORDS.

### ✅ Modelos Corregidos (15 total)

| # | Modelo | Archivo | Primary Key | Cambios Principales |
|---|--------|---------|-------------|---------------------|
| 1 | **Servicio** | `servicio.py` | `id` (NUMBER) | ✅ Agregados 12 campos faltantes |
| 2 | **Sesion** | `sesion.py` | `id` (NUMBER) | ⚠️ Campo `id_faciltiador` tiene TYPO en BD |
| 3 | **AsistenciaSesion** | `asistencia_sesion.py` | Sin PK en metadata | ✅ Corregidos tipos TIMESTAMP |
| 4 | **Persona** | `persona.py` | `id` (NUMBER) | ✅ Cambiados 7 campos |
| 5 | **Departamento** | `departamento.py` | `id` (NUMBER) | ✅ Agregados campos jefe_centro |
| 6 | **Facilitador** | `facilitador.py` | `id` (NUMBER) | ✅ Estructura completamente nueva |
| 7 | **BannerPeriodos** | `banner_periodos.py` | `codigo` (NUMBER) | ⚠️ PK es `codigo`, no `id` |
| 8 | **BannerCursos** | `banner_cursos.py` | `(materia, curso)` | ⚠️ PK compuesta, sin `id` |
| 9 | **Modalidades** | `modalidades.py` | `id` (NUMBER) | ✅ Solo campo `modalidad` |
| 10 | **TiposDeDocumento** | `tipos_de_documento.py` | `codigo` (VARCHAR2) | ⚠️ PK es `codigo`, no `id` |
| 11 | **PublicosServicios** | `publicos_servicios.py` | `id` (NUMBER) | ✅ Campos `publico` y `admite_externos` |
| 12 | **ResponsableServicio** | `responsable_servicio.py` | `id` (NUMBER) | ✅ Estructura completamente nueva |
| 13 | **LugaresIceberg** | `lugares_iceberg.py` | **Sin PK** | ⚠️ Tabla sin Primary Key |
| 14 | **ConstraintLookup** | `constraint_lookup.py` | `constraint_name` (VARCHAR2) | ⚠️ PK es `constraint_name` |
| 15 | **GcCorreosNombres** | `egc_correos_nombres.py` | N/A | ❌ **Tabla NO existe en ORDS (404)** |

---

## 📊 Detalles por Modelo

### 1. SERVICIOS
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- id_departamento: NUMBER
- nombre_servicio: VARCHAR2
- descripcion: VARCHAR2
- fecha_creacion_servicio: DATE
- id_padre: NUMBER
- id_acumula_asistencia: NUMBER
- id_email: VARCHAR2
- id_responsable: VARCHAR2
- materia: VARCHAR2
- periodo: NUMBER
- nombre_responsable_id: NUMBER
- id_publico: NUMBER
- publicos: VARCHAR2
- jefe_centro: VARCHAR2
- jefe_centro_nombre: VARCHAR2
- nivel: NUMBER
```

**Cambios:**
- ✅ Todos los campos son opcionales (`Optional`)
- ✅ `fecha_creacion_servicio` es `date`, no `datetime`
- ✅ Agregados 12 campos que faltaban

---

### 2. SESIONES
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- id_servicio: NUMBER
- id_periodo: NUMBER
- id_tipo: NUMBER
- descripcion: VARCHAR2
- hora_inicio_sesion: VARCHAR2
- fecha_fin: TIMESTAMP(6)
- nombre_sesion: VARCHAR2
- id_modalidad: NUMBER
- lugar_sesion: VARCHAR2
- fecha: DATE
- id_semana: NUMBER
- hora_inicio: TIMESTAMP(6)
- hora_fin: TIMESTAMP(6)
- id_faciltiador: VARCHAR2  ⚠️ TYPO en BD
- n_maximo_asistentes: NUMBER
- inscritos_actuales: NUMBER
- antes_sesion: NUMBER
- despues_sesion: NUMBER
- gestiona_asis: VARCHAR2
- facilitador_externo: VARCHAR2
```

**⚠️ IMPORTANTE:**
- Campo tiene TYPO en la base de datos: `id_faciltiador` (sin c)
- El modelo refleja el typo real de la BD
- No cambiar a `id_facilitador` o fallará

---

### 3. ASISTENCIA_SESIONES
```python
# Estructura Real ORDS:
- id: NUMBER
- fecha_creacion: TIMESTAMP(6) WITH LOCAL TIME ZONE (auto)
- id_sesiones: NUMBER
- documento_identidad: VARCHAR2
- usuario_creacion: VARCHAR2
- usuario_actualizacion: VARCHAR2
- fecha_actualizacion: TIMESTAMP(6) WITH LOCAL TIME ZONE
- id_modalidades: NUMBER
- id_tipos_documento: VARCHAR2
- codigo_telefonico: VARCHAR2
- geo_latitud: NUMBER
- geo_longitud: NUMBER
- id_persona: NUMBER
- observaciones: VARCHAR2
```

**Cambios:**
- ✅ `fecha_creacion` es auto-generada (solo en Out)
- ✅ Todos los timestamps usan `datetime`
- ✅ Todos los campos opcionales

---

### 4. PERSONAS
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- codigo_banner: VARCHAR2
- documento_identidad: VARCHAR2
- nombre_persona: VARCHAR2
- programa: VARCHAR2
- cargo: VARCHAR2
- tipo_documento: VARCHAR2
- correo_institucional: VARCHAR2
- numero_celular: VARCHAR2
- rol_group: VARCHAR2
- apellidos_personas: VARCHAR2
```

**Cambios:**
- ❌ Eliminado `identificacion` → ✅ `documento_identidad`
- ❌ Eliminado `tipo_de_identificacion` → ✅ `tipo_documento`
- ❌ Eliminado `nombre_asistente` → ✅ `nombre_persona` + `apellidos_personas`
- ✅ Agregados campos institucionales

---

### 5. DEPARTAMENTO_ECO
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- centro: VARCHAR2
- descripcion: VARCHAR2
- jefe_centro_co: VARCHAR2
- jefe_centro_nom: VARCHAR2
- jefe_centro_ape: VARCHAR2
```

**Cambios:**
- ✅ Agregados 3 campos de jefe de centro
- ✅ Descripción ahora opcional

---

### 6. FACILITADORES
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- correo_facilitador: VARCHAR2
- nombre_completo: VARCHAR2
- apellidos_fa: VARCHAR2
- gestiona_asis: VARCHAR2
```

**Cambios:**
- ❌ Eliminada estructura anterior completa
- ✅ Nueva estructura basada en ORDS

---

### 7. BANNER_PERIODOS
```python
# Estructura Real ORDS:
- codigo: NUMBER (PK) ⚠️ NO 'id'
- fecha_fin: TIMESTAMP(6) WITH TIME ZONE
- fecha_inicio: TIMESTAMP(6) WITH TIME ZONE
- nombre_periodo: VARCHAR2
- fecha_actividad: TIMESTAMP(6) WITH TIME ZONE
- apex$sync_step_static_id: VARCHAR2
- apex$row_sync_timestamp: TIMESTAMP(6) WITH TIME ZONE
```

**⚠️ IMPORTANTE:**
- **Primary Key es `codigo`, NO `id`**
- Usar `BannerPeriodosOut.codigo` en respuestas
- Campos con `$` convertidos a `_` en Python (`apex_sync_step_static_id`)

---

### 8. BANNER_CURSOS
```python
# Estructura Real ORDS:
- materia: VARCHAR2 (PK1)
- curso: VARCHAR2 (PK2)
- periodo: VARCHAR2
- estado: VARCHAR2
- creditos: NUMBER
- facultad: VARCHAR2
- departamento: VARCHAR2
- horas_teoria: NUMBER
- horas_laboratorio: NUMBER
- nombre_asignatura: VARCHAR2
- nombre_largo_asignatura: VARCHAR2
- apex$sync_step_static_id: VARCHAR2
- apex$row_sync_timestamp: TIMESTAMP(6) WITH TIME ZONE
```

**⚠️ IMPORTANTE:**
- **Primary Key COMPUESTA: (materia, curso)**
- **NO tiene campo `id`**
- Identificar por combinación `materia` + `curso`

---

### 9. MODALIDADES
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- modalidad: VARCHAR2
```

**Cambios:**
- ✅ Solo 1 campo: `modalidad`
- ❌ Eliminados `codigo_modalidad`, `nombre_modalidad`, `descripcion`

---

### 10. TIPOS_DE_DOCUMENTO
```python
# Estructura Real ORDS:
- id: NUMBER
- codigo: VARCHAR2 (PK) ⚠️
- nombre: VARCHAR2
```

**⚠️ IMPORTANTE:**
- **Primary Key es `codigo` (VARCHAR2), NO `id`**
- `id` existe pero NO es la PK
- Valores: "C.C", "T.I", "P.P", "C.E"

---

### 11. PUBLICOS_SERVICIOS
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- publico: VARCHAR2
- admite_externos: VARCHAR2  # 'Y' o 'N'
```

**Cambios:**
- ✅ Solo 2 campos simples
- ✅ `admite_externos` tipo flag (Y/N)

---

### 12. RESPONSABLE_SERVICIO
```python
# Estructura Real ORDS:
- id: NUMBER (PK)
- correo: VARCHAR2
- centro_id: NUMBER
- nombre_completo: VARCHAR2
- apellidos: VARCHAR2
```

**Cambios:**
- ❌ Eliminada estructura anterior completa
- ✅ Nueva estructura basada en ORDS

---

### 13. LUGARES_ICEBERG
```python
# Estructura Real ORDS:
- status: VARCHAR2
- capacidad: NUMBER
- departamento: VARCHAR2
- numero_salon: VARCHAR2
- capacidad_maxima: NUMBER
- descripcion_salon: VARCHAR2
- apex$sync_step_static_id: VARCHAR2
- apex$row_sync_timestamp: TIMESTAMP(6) WITH TIME ZONE
```

**⚠️ IMPORTANTE:**
- **NO tiene Primary Key definida en ORDS**
- Tabla de solo lectura (sincronizada con Apex)

---

### 14. CONSTRAINT_LOOKUP
```python
# Estructura Real ORDS:
- constraint_name: VARCHAR2 (PK)
- message: VARCHAR2
```

**⚠️ IMPORTANTE:**
- **Primary Key es `constraint_name` (VARCHAR2)**
- Solo 2 campos
- Tabla de referencia para mensajes de error

---

### 15. EGC_CORREOS_NOMBRES
```
⚠️ ADVERTENCIA: Esta tabla NO EXISTE en ORDS (404)
```

**Estado:**
- ❌ Endpoint retorna 404 Not Found
- ⚠️ Modelo mantenido para compatibilidad
- 🔧 Considerar eliminar del proyecto

---

## 🔧 Recomendaciones de Uso

### Formato de Fechas para ORDS
```python
# ✅ CORRECTO para Oracle ORDS:
"fecha_creacion_servicio": "2024-01-15T00:00:00Z"  # ISO 8601 con Z
"fecha": "2024-10-15T00:00:00Z"                     # DATE con tiempo
"hora_inicio": "2024-10-15T14:00:00Z"               # TIMESTAMP con Z

# ❌ INCORRECTO (Oracle rechaza):
"fecha_creacion_servicio": "2024-01-15"             # Falta timestamp
"fecha": "2024-10-15"                               # Sin hora
"hora_inicio": "2024-10-15T14:00:00"                # Sin 'Z'
"hora_inicio": "2024-10-15T14:00:00.123456"         # Microsegundos sin Z
```

### Validación de Datos
```python
# Todos los campos son Optional para flexibilidad
# Validar en lógica de negocio, no en Pydantic
```

---

## ✅ Testing

```bash
# Verificar que no hay errores:
python -m pylint src/backend/api/models/

# Reiniciar backend:
# Ctrl+C en terminal uvicorn
uvicorn src.backend.api.app:app --reload
```

---

## 📝 Notas Importantes

1. **Typo en BD**: `id_faciltiador` (sesiones) tiene typo intencional
2. **PKs no convencionales**: 
   - `banner_periodos.codigo`
   - `tipos_de_documento.codigo`
   - `banner_cursos.(materia, curso)`
   - `constraint_lookup.constraint_name`
3. **Sin PK**: `lugares_iceberg`, `asistencia_sesiones` (en metadata)
4. **Tabla inexistente**: `egc_correos_nombres` (404)
5. **Campos Apex**: Convertir `$` a `_` en nombres de campo

---

**Actualizado:** 7 de octubre de 2025  
**Metadata fuente:** Oracle ORDS `/metadata-catalog/`  
**Estado:** ✅ COMPLETO

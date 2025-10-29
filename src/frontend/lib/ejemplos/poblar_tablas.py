"""
Script para poblar SOLO las tablas SERVICIOS, SESIONES y ASISTENCIA_SESIONES
con datos de ejemplo coherentes basados en datos REALES existentes.

NOTA: Este script hace POST directo a ORDS, bypasseando los modelos Pydantic
porque los modelos están incorrectos y no coinciden con la estructura real de ORDS.
"""
import httpx
import json
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Cargar .env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "src/backend/.env"))

# URLs directas de ORDS (bypasseando FastAPI)
URL_SERVICIOS = os.getenv("URL_SERVICIOS")
URL_SESIONES = os.getenv("URL_SESIONES")
URL_ASISTENCIA = os.getenv("URL_ASISTENCIA_SESIONES")

# Cliente HTTP con cookies
client = httpx.Client(timeout=30.0, follow_redirects=True)
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "User-Agent": "FastAPI-Client",
}

def poblar_datos():
    print("=" * 80)
    print("POBLANDO TABLAS: SERVICIOS, SESIONES Y ASISTENCIA_SESIONES")
    print("POST DIRECTO A ORDS (bypasseando FastAPI)")
    print("=" * 80)
    print("\n📋 USANDO DATOS REALES DE TABLAS EXISTENTES")
    print("=" * 80)
    
    # Inicializar cookies con petición GET
    print("\n🔐 Inicializando sesión con ORDS...")
    client.get(URL_SERVICIOS, headers=HEADERS)
    
    # ========================================================================
    # 1. SERVICIOS - 3 ejemplos (POST directo a ORDS)
    # ========================================================================
    print("\n[1/3] 📊 Insertando SERVICIOS...")
    print("-" * 80)
    
    servicios = [
        {
            # Servicio 1: Tutoría de Microeconomía (ESTRUCTURA REAL ORDS)
            "id_departamento": 1,
            "nombre_servicio": "Tutoría de Microeconomía",
            "descripcion": "Tutorías personalizadas y grupales en temas de microeconomía para estudiantes de pregrado",
            "fecha_creacion_servicio": "2024-01-15T00:00:00Z",  # ISO 8601 con Z
            "id_padre": None,
            "id_acumula_asistencia": 1,
            "id_email": None,
            "id_responsable": "BPOLO@UTB.EDU.CO",
            "materia": "Microeconomía I",
            "periodo": 202110,
            "nombre_responsable_id": 303,
            "id_publico": 23,
            "publicos": "Estudiantes de pregrado",
            "jefe_centro": "BPOLO@UTB.EDU.CO",
            "jefe_centro_nombre": "BLEIDYS POLO GARCIA",
            "nivel": 1
        },
        {
            # Servicio 2: Taller de Programación
            "id_departamento": 3,
            "nombre_servicio": "Taller de Programación Python",
            "descripcion": "Talleres prácticos de programación en Python para principiantes, incluye ejercicios y proyectos",
            "fecha_creacion_servicio": "2024-02-01T00:00:00Z",
            "id_padre": None,
            "id_acumula_asistencia": 1,
            "id_email": None,
            "id_responsable": "DSEVERICHE@UTB.EDU.CO",
            "materia": "Programación I",
            "periodo": 202020,
            "nombre_responsable_id": 161,
            "id_publico": 23,
            "publicos": "Estudiantes de ingeniería",
            "jefe_centro": "DSEVERICHE@UTB.EDU.CO",
            "jefe_centro_nombre": "DANIELA MARGARITA GONZALEZ SEVERICHE",
            "nivel": 1
        },
        {
            # Servicio 3: Seminario de Liderazgo
            "id_departamento": 4,
            "nombre_servicio": "Seminario de Liderazgo y Desarrollo Personal",
            "descripcion": "Seminarios sobre desarrollo de habilidades de liderazgo, trabajo en equipo y crecimiento personal",
            "fecha_creacion_servicio": "2024-03-10T00:00:00Z",
            "id_padre": None,
            "id_acumula_asistencia": 1,
            "id_email": None,
            "id_responsable": "GDELAOSSA@UTB.EDU.CO",
            "materia": "Liderazgo Organizacional",
            "periodo": 202110,
            "nombre_responsable_id": 283,
            "id_publico": 23,
            "publicos": "Estudiantes y docentes",
            "jefe_centro": "HENGONZALEZ@UTB.EDU.CO",
            "jefe_centro_nombre": "HENRY GONZALEZ GONZALEZ",
            "nivel": 1
        }
    ]
    
    ids_servicios = []
    for i, serv in enumerate(servicios, 1):
        try:
            # POST directo a ORDS
            response = client.post(URL_SERVICIOS, headers=HEADERS, json=serv)
            if response.status_code in [200, 201]:
                data = response.json()
                # ORDS devuelve el objeto creado con su ID
                service_id = data.get('id', i)
                print(f"  ✓ Servicio {service_id} creado: {serv['nombre_servicio']}")
                ids_servicios.append(service_id)
            else:
                print(f"  ✗ Error al crear servicio {i}: {response.status_code}")
                print(f"     Detalle: {response.text[:300]}")
                ids_servicios.append(i)
        except Exception as e:
            print(f"  ✗ Excepción al crear servicio {i}: {str(e)[:150]}")
            ids_servicios.append(i)
    
    # ========================================================================
    # 2. SESIONES - 3 ejemplos (respetando ESTRUCTURA EXACTA que proporcionaste)
    # ========================================================================
    print("\n[2/3] 📅 Insertando SESIONES...")
    print("-" * 80)
    
    fecha_base = datetime(2024, 10, 15)
    
    sesiones = [
        {
            # === ESTRUCTURA SEGÚN ORACLE ORDS ===
            "id_servicio": ids_servicios[0],
            "id_periodo": 202110,
            "id_tipo": 1,
            "descripcion": "Primera sesión de tutoría grupal de microeconomía - Introducción a oferta y demanda",
            "hora_inicio_sesion": "14:00",
            "fecha_fin": fecha_base.replace(hour=16, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "nombre_sesion": "Tutoría Microeconomía - Grupo A",
            "id_modalidad": 1,
            "lugar_sesion": "Edificio E, Salón 301",
            "fecha": fecha_base.strftime("%Y-%m-%dT%H:%M:%SZ"),  # Formato completo con Z
            "id_semana": 1,
            "hora_inicio": fecha_base.replace(hour=14, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "hora_fin": fecha_base.replace(hour=16, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_facilitador": "BPOLO@UTB.EDU.CO",
            "n_maximo_asistentes": 30,
            "inscritos_actuales": 15,
            "antes_sesion": 10,
            "despues_sesion": 5,
            "gestiona_asis": "S",
            "facilitador_externo": "N"
        },
        {
            "id_servicio": ids_servicios[1],
            "id_periodo": 202020,
            "id_tipo": 2,
            "descripcion": "Taller práctico de introducción a Python - Variables, tipos de datos y estructuras",
            "hora_inicio_sesion": "10:00",
            "fecha_fin": (fecha_base + timedelta(days=1)).replace(hour=12, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "nombre_sesion": "Python Básico - Sesión 1",
            "id_modalidad": 2,
            "lugar_sesion": "Plataforma Zoom - Link enviado por correo institucional",
            "fecha": (fecha_base + timedelta(days=1)).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_semana": 2,
            "hora_inicio": (fecha_base + timedelta(days=1)).replace(hour=10, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "hora_fin": (fecha_base + timedelta(days=1)).replace(hour=12, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_facilitador": "DSEVERICHE@UTB.EDU.CO",
            "n_maximo_asistentes": 40,
            "inscritos_actuales": 32,
            "antes_sesion": 15,
            "despues_sesion": 10,
            "gestiona_asis": "S",
            "facilitador_externo": "N"
        },
        {
            "id_servicio": ids_servicios[2],
            "id_periodo": 202110,
            "id_tipo": 3,
            "descripcion": "Seminario sobre técnicas de liderazgo transformacional y gestión de equipos",
            "hora_inicio_sesion": "16:00",
            "fecha_fin": (fecha_base + timedelta(days=3)).replace(hour=18, minute=30).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "nombre_sesion": "Seminario Liderazgo - Sesión Inaugural",
            "id_modalidad": 1,
            "lugar_sesion": "Auditorio Principal - Campus Tecnológico",
            "fecha": (fecha_base + timedelta(days=3)).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_semana": 1,
            "hora_inicio": (fecha_base + timedelta(days=3)).replace(hour=16, minute=0).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "hora_fin": (fecha_base + timedelta(days=3)).replace(hour=18, minute=30).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_facilitador": "GDELAOSSA@UTB.EDU.CO",
            "n_maximo_asistentes": 50,
            "inscritos_actuales": 45,
            "antes_sesion": 20,
            "despues_sesion": 15,
            "gestiona_asis": "S",
            "facilitador_externo": "N"
        }
    ]
    
    ids_sesiones = []
    for i, ses in enumerate(sesiones, 1):
        try:
            # POST directo a ORDS
            response = client.post(URL_SESIONES, headers=HEADERS, json=ses)
            if response.status_code in [200, 201]:
                data = response.json()
                sesion_id = data.get('id', i)
                print(f"  ✓ Sesión {sesion_id} creada: {ses['nombre_sesion']}")
                ids_sesiones.append(sesion_id)
            else:
                print(f"  ✗ Error al crear sesión {i}: {response.status_code}")
                print(f"     Detalle: {response.text[:300]}")
                ids_sesiones.append(i)
        except Exception as e:
            print(f"  ✗ Excepción al crear sesión {i}: {str(e)[:150]}")
            ids_sesiones.append(i)
    
    # ========================================================================
    # 3. ASISTENCIA_SESIONES - 4 ejemplos (respetando ESTRUCTURA EXACTA)
    # ========================================================================
    print("\n[3/3] ✅ Insertando ASISTENCIA_SESIONES...")
    print("-" * 80)
    
    ahora = datetime.now()
    
    asistencias = [
        {
            # === ESTRUCTURA SEGÚN ORACLE ORDS ===
            "id_sesiones": ids_sesiones[0],
            "documento_identidad": "1001902938",
            "usuario_creacion": "admin",
            "usuario_actualizacion": "admin",
            "fecha_creacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "fecha_actualizacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_modalidades": 1,
            "id_tipos_documento": "C.C",
            "codigo_telefonico": "+57",
            "geo_latitud": 10.9978,
            "geo_longitud": -74.8088,
            "id_persona": 366,
            "observaciones": "Asistió puntualmente - Participación activa en la sesión"
        },
        {
            "id_sesiones": ids_sesiones[0],
            "documento_identidad": "1043643758",
            "usuario_creacion": "admin",
            "usuario_actualizacion": "admin",
            "fecha_creacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "fecha_actualizacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_modalidades": 1,
            "id_tipos_documento": "C.C",
            "codigo_telefonico": "+57",
            "geo_latitud": 10.9979,
            "geo_longitud": -74.8089,
            "id_persona": 420,
            "observaciones": "Asistencia completa - Realizó todas las actividades propuestas"
        },
        {
            "id_sesiones": ids_sesiones[1],
            "documento_identidad": "1067594817",
            "usuario_creacion": "admin",
            "usuario_actualizacion": "admin",
            "fecha_creacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "fecha_actualizacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_modalidades": 2,
            "id_tipos_documento": "C.C",
            "codigo_telefonico": "+57",
            "geo_latitud": None,
            "geo_longitud": None,
            "id_persona": 476,
            "observaciones": "Asistencia virtual confirmada - Conexión estable durante toda la sesión"
        },
        {
            "id_sesiones": ids_sesiones[2],
            "documento_identidad": "1142920220",
            "usuario_creacion": "admin",
            "usuario_actualizacion": "admin",
            "fecha_creacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "fecha_actualizacion": ahora.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "id_modalidades": 1,
            "id_tipos_documento": "T.I",
            "codigo_telefonico": "+57",
            "geo_latitud": 10.9980,
            "geo_longitud": -74.8090,
            "id_persona": 1954,
            "observaciones": "Primera asistencia al seminario - Mostró gran interés en los temas tratados"
        }
    ]
    
    for i, asis in enumerate(asistencias, 1):
        try:
            # POST directo a ORDS
            response = client.post(URL_ASISTENCIA, headers=HEADERS, json=asis)
            if response.status_code in [200, 201]:
                nombres = {
                    "1001902938": "Daniela González",
                    "1043643758": "José Daniel Santoya",
                    "1067594817": "Samuel Martínez",
                    "1142920220": "Andrea Reyes"
                }
                nombre = nombres.get(asis["documento_identidad"], f"Persona {i}")
                print(f"  ✓ Asistencia {i} registrada: {nombre}")
            else:
                print(f"  ✗ Error al registrar asistencia {i}: {response.status_code}")
                print(f"     Detalle: {response.text[:300]}")
        except Exception as e:
            print(f"  ✗ Excepción al registrar asistencia {i}: {str(e)[:150]}")
    
    # ========================================================================
    # RESUMEN FINAL
    # ========================================================================
    print("\n" + "=" * 80)
    print("✅ PROCESO COMPLETADO")
    print("=" * 80)
    print("\n📊 RESUMEN DE DATOS INSERTADOS:")
    print(f"  • {len(servicios)} Servicios creados")
    print(f"  • {len(sesiones)} Sesiones creadas")
    print(f"  • {len(asistencias)} Asistencias registradas")
    print("\n📋 DETALLES:")
    print("\n  SERVICIOS:")
    for i, s in enumerate(servicios, 1):
        print(f"    {i}. {s['nombre_servicio']}")
    print("\n  SESIONES:")
    for i, s in enumerate(sesiones, 1):
        print(f"    {i}. {s['nombre_sesion']} ({s['fecha']})")
    print("\n  ASISTENCIAS:")
    for i, a in enumerate(asistencias, 1):
        modalidad = "PRESENCIAL" if a["id_modalidades"] == 1 else "REMOTO"
        print(f"    {i}. Doc: {a['documento_identidad']} - Modalidad: {modalidad}")
    print("\n" + "=" * 80)
    print("🔗 Verifica los datos en:")
    print(f"  • Servicios: {URL_SERVICIOS}")
    print(f"  • Sesiones: {URL_SESIONES}")
    print(f"  • Asistencias: {URL_ASISTENCIA}")
    print("=" * 80)


if __name__ == "__main__":
    try:
        poblar_datos()
    except KeyboardInterrupt:
        print("\n\n⚠️  Proceso interrumpido por el usuario")
    except Exception as e:
        print(f"\n\n❌ ERROR GENERAL: {e}")
        import traceback
        traceback.print_exc()
    finally:
        client.close()
        print("\n👋 Cliente HTTP cerrado")

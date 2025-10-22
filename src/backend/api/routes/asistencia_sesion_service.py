import os, httpx, json
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from api.models.asistencia_sesion import AsistenciaSesionIn

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True,
)

BASE_URL = os.getenv("URL_ASISTENCIA_SESIONES")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client",
}

app = APIRouter(prefix="/asistencias", tags=["asistencias"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/")
async def get_todas_asistencias():
    """Obtener todas las asistencias"""
    await ensure_cookies()
    try:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as exc:
        return {
            "error": f"HTTP {exc.response.status_code}",
            "detalle": exc.response.text,
        }
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/{id}")
async def get_asistencia(id: int):
    """Obtener una asistencia específica por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return resp.json()
        if resp.status_code in (400, 404):
            return {"error": f"Asistencia con ID {id} no encontrada"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/persona/{id_persona}")
async def get_asistencias_por_persona(id_persona: int):
    """Obtener todas las asistencias de una persona (histórico)"""
    await ensure_cookies()
    try:
        query = {"id_persona": str(id_persona)}
        url = f"{BASE_URL}?q={json.dumps(query)}"
        resp = await session.get(url, headers=HEADERS)
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as exc:
        return {
            "error": f"HTTP {exc.response.status_code}",
            "detalle": exc.response.text,
        }
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/sesion/{id_sesion}")
async def get_asistencias_por_sesion(id_sesion: int):
    """Obtener todas las asistencias de una sesión específica"""
    await ensure_cookies()
    try:
        query = {"id_sesiones": str(id_sesion)}
        url = f"{BASE_URL}?q={json.dumps(query)}"
        resp = await session.get(url, headers=HEADERS)
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as exc:
        return {
            "error": f"HTTP {exc.response.status_code}",
            "detalle": exc.response.text,
        }
    except Exception as exc:
        return {"error": str(exc)}

@app.post("/")
async def create_asistencia(asistencia_sesion: AsistenciaSesionIn):
    """Crear una nueva asistencia (registro de asistencia a una sesión)"""
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(asistencia_sesion),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 201, 204):
            return {"message": "Asistencia registrada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/{id}")
async def delete_asistencia(id: int):
    """Eliminar una asistencia por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Asistencia con ID {id} eliminada correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"Asistencia con ID {id} no encontrada"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/{id}")
async def update_asistencia(id: int, asistencia_sesion: AsistenciaSesionIn):
    """Actualizar una asistencia existente"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=asistencia_sesion.dict(),
        )
        if resp.status_code in (200, 204):
            return {"message": f"Asistencia con ID {id} actualizada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

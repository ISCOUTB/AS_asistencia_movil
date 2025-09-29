import os, httpx, json
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from models.asistencia_sesion import AsistenciaSesionIn

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

app = APIRouter(prefix="/asistencia_sesion", tags=["asistencia_sesion"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/asistencia_sesiones/{id_estudiante}")
#Endpoint para obtener todas las asistencia de sesiones del estudiante [historico]
async def get_asistencia_sesiones(id_estudiante: int):
    await ensure_cookies()
    try:
        query = {"id_persona": str(id_estudiante)}
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


@app.get("/asistencia_sesiones/{id_estudiante}/{fecha}")
#Endpoint para obtener todas las asistencia de sesiones del estudiante [por fecha especifica] 
async def get_asistencia_sesiones(id_estudiante: int, fecha: str):
    await ensure_cookies()
    try:
        query = {"id_persona": str(id_estudiante), "fecha_creacion":str(fecha)}
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

@app.post("/crear_asistencia_sesion")
async def create_asistencia_sesion(asistencia_sesion: AsistenciaSesionIn):
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(asistencia_sesion),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 204):
            return {"message": "Sesión creada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/eliminar_asistencia_sesion/{id}/{id_estudiante}/{fecha}")
#Endpoint para eliminar asistencia de sesion de estudiante [por fecha especifica, e id especifico] 
async def delete_asistencia_asistencia_sesion(id: int, id_estudiante: int, fecha: str):
    await ensure_cookies()
    query = {"id":str(id), "id_persona": str(id_estudiante), "fecha_creacion":str(fecha)}
    url = f"{BASE_URL}?q={json.dumps(query)}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"asistencia_sesion con ID {id} eliminada correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"asistencia_sesion con ID {id} no encontrada"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/actualizar_sesion/{id}/{id_estudiante}/{fecha}")
async def update_asistencia_asistencia_sesion(id: int, id_estudiante: int, fecha: str, asistencia_sesion: AsistenciaSesionIn):
    await ensure_cookies()
    query = {"id":str(id), "id_persona": str(id_estudiante), "fecha_creacion":str(fecha)}
    url = f"{BASE_URL}?q={json.dumps(query)}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=asistencia_sesion.dict(),
        )
        if resp.status_code in (200, 204):
            # Algunos ORDS devuelven 204 sin contenido al actualizar
            return {"message": f"asistencia_sesion con ID {id} actualizada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

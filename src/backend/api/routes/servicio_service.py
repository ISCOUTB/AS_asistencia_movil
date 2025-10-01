import os
import httpx
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from api.models.servicio import ServicioIn

# Cargar variables de entorno
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True,
)

BASE_URL = os.getenv("URL_SERVICIOS")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client",
}

app = APIRouter(prefix="/servicios", tags=["servicios"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/")
async def get_servicios():
    """Obtener todos los servicios"""
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
async def get_servicio(id: int):
    """Obtener un servicio específico por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return resp.json()
        if resp.status_code in (400, 404):
            return {"error": f"Servicio con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/departamento/{id_departamento}")
async def get_servicios_por_departamento(id_departamento: int):
    """Obtener todos los servicios de un departamento"""
    await ensure_cookies()
    try:
        # Filtrar por departamento usando query parameters
        url = f"{BASE_URL}?q={{\"id_departamento\":{id_departamento}}}"
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
async def create_servicio(servicio: ServicioIn):
    """Crear un nuevo servicio"""
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(servicio),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 201, 204):
            return {"message": "Servicio creado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/{id}")
async def update_servicio(id: int, servicio: ServicioIn):
    """Actualizar un servicio existente"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=servicio.dict(),
        )
        if resp.status_code in (200, 204):
            return {"message": f"Servicio con ID {id} actualizado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/{id}")
async def delete_servicio(id: int):
    """Eliminar un servicio"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Servicio con ID {id} eliminado correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"Servicio con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

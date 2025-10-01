import os
import httpx
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from api.models.facilitador import FacilitadorIn

# Cargar variables de entorno
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True,
)

BASE_URL = os.getenv("URL_FACILITADORES")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client",
}

app = APIRouter(prefix="/facilitadores", tags=["facilitadores"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/")
async def get_facilitadores():
    """Obtener todos los facilitadores"""
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
async def get_facilitador(id: int):
    """Obtener un facilitador específico por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return resp.json()
        if resp.status_code in (400, 404):
            return {"error": f"Facilitador con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.post("/")
async def create_facilitador(facilitador: FacilitadorIn):
    """Crear un nuevo facilitador"""
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(facilitador),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 201, 204):
            return {"message": "Facilitador creado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/{id}")
async def update_facilitador(id: int, facilitador: FacilitadorIn):
    """Actualizar un facilitador existente"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=facilitador.dict(),
        )
        if resp.status_code in (200, 204):
            return {"message": f"Facilitador con ID {id} actualizado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/{id}")
async def delete_facilitador(id: int):
    """Eliminar un facilitador"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Facilitador con ID {id} eliminado correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"Facilitador con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

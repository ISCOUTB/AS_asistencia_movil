import os
import httpx
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from api.models.departamento import DepartamentoIn

# Cargar variables de entorno
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True,
)

BASE_URL = os.getenv("URL_DEPARTAMENTO_ECO")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client",
}

app = APIRouter(prefix="/departamentos", tags=["departamentos"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/")
async def get_departamentos():
    """Obtener todos los departamentos"""
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
async def get_departamento(id: int):
    """Obtener un departamento específico por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return resp.json()
        if resp.status_code in (400, 404):
            return {"error": f"Departamento con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.post("/")
async def create_departamento(departamento: DepartamentoIn):
    """Crear un nuevo departamento"""
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(departamento),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 201, 204):
            return {"message": "Departamento creado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/{id}")
async def update_departamento(id: int, departamento: DepartamentoIn):
    """Actualizar un departamento existente"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=departamento.dict(),
        )
        if resp.status_code in (200, 204):
            return {"message": f"Departamento con ID {id} actualizado correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/{id}")
async def delete_departamento(id: int):
    """Eliminar un departamento"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Departamento con ID {id} eliminado correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"Departamento con ID {id} no encontrado"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

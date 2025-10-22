import os
import httpx
import json
from dotenv import load_dotenv
from fastapi import APIRouter
from fastapi.encoders import jsonable_encoder

from api.models.persona import PersonaIn

# Cargar variables de entorno
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True,
)

BASE_URL = os.getenv("URL_PERSONAS")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client",
}

app = APIRouter(prefix="/personas", tags=["personas"])


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/")
async def get_personas():
    """Obtener todas las personas"""
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
async def get_persona(id: int):
    """Obtener una persona específica por ID"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return resp.json()
        if resp.status_code in (400, 404):
            return {"error": f"Persona con ID {id} no encontrada"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/email/{email}")
async def get_persona_por_email(email: str):
    """Obtener una persona por su correo electrónico"""
    await ensure_cookies()
    try:
        # Buscar en el código banner que normalmente contiene el email
        query = {"codigo_banner": email}
        url = f"{BASE_URL}?q={json.dumps(query)}"
        resp = await session.get(url, headers=HEADERS)
        resp.raise_for_status()
        data = resp.json()
        
        # Si no se encuentra por codigo_banner, intentar búsqueda más amplia
        if not data or (isinstance(data, dict) and data.get("items", []) == []):
            # Obtener todas las personas y filtrar por email manualmente
            all_resp = await session.get(BASE_URL, headers=HEADERS)
            all_resp.raise_for_status()
            all_data = all_resp.json()
            items = all_data.get("items", []) if isinstance(all_data, dict) else all_data
            
            # Filtrar por email en codigo_banner
            filtered = [p for p in items if p.get("codigo_banner", "").lower() == email.lower()]
            return {"items": filtered} if filtered else {"items": []}
        
        return data
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as exc:
        return {
            "error": f"HTTP {exc.response.status_code}",
            "detalle": exc.response.text,
        }
    except Exception as exc:
        return {"error": str(exc)}


@app.get("/documento/{documento}")
async def get_persona_por_documento(documento: str):
    """Obtener una persona por su documento de identidad"""
    await ensure_cookies()
    try:
        query = {"identificacion": documento}
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
async def create_persona(persona: PersonaIn):
    """Crear una nueva persona"""
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=jsonable_encoder(persona),
        )
        resp.raise_for_status()
        if resp.status_code in (200, 201, 204):
            return {"message": "Persona creada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.put("/{id}")
async def update_persona(id: int, persona: PersonaIn):
    """Actualizar una persona existente"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=persona.dict(),
        )
        if resp.status_code in (200, 204):
            return {"message": f"Persona con ID {id} actualizada correctamente"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}


@app.delete("/{id}")
async def delete_persona(id: int):
    """Eliminar una persona"""
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Persona con ID {id} eliminada correctamente"}
        if resp.status_code in (400, 404):
            return {"error": f"Persona con ID {id} no encontrada"}
        return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as exc:
        return {"error": str(exc)}

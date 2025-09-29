import httpx, os
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.encoders import jsonable_encoder
from models.sesion import SesionIn

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))
app = FastAPI()

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True
)

BASE_URL = os.getenv("URL_SESIONES")
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "FastAPI-Client"
}


async def ensure_cookies():
    """
    Hace una petición inicial si aún no se han guardado cookies en la sesión.
    """
    if not session.cookies:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()


@app.get("/sesiones")
async def get_servicios():
    await ensure_cookies()
    try:
        resp = await session.get(BASE_URL, headers=HEADERS)
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP {e.response.status_code}", "detalle": e.response.text}
    except Exception as e:
        return {"error": str(e)}


@app.get("/sesiones/{id}")
async def get_servicio(id: int):
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.get(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Sesion con ID {id} eliminado correctamente"}
        elif resp.status_code in (400, 404):
            return {"error": f"Sesion con ID {id} no encontrado"}
        else:
            return {"status": resp.status_code, "detalle": resp.text}
        
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}


@app.post("/crearsesion")
async def create_servicio(sesion: SesionIn):
    url = f"{BASE_URL}"
    await ensure_cookies()
    try:
        resp = await session.post(BASE_URL, headers={**HEADERS, "Content-Type": "application/json"},
                                   json=jsonable_encoder(sesion))
        resp.raise_for_status()
        if resp.status_code in (200, 204):
            return {"message": f"Sesion con ID {id} creado correctamente"}
        else:
            return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}


@app.delete("/eliminarsesion/{id}")
async def delete_servicio(id: int):
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code in (200, 204):
            return {"message": f"Sesion con ID {id} eliminado correctamente"}
        elif resp.status_code in (400, 404):
            return {"error": f"Sesion con ID {id} no encontrado"}
        else:
            return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:  
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}

@app.put("/actualizarsesion/{id}")
async def update_servicio(id: int, sesion: SesionIn):
    await ensure_cookies()
    url = f"{BASE_URL}{id}"  # la URL específica del recurso
    try:
        resp = await session.put(
            url,
            headers={**HEADERS, "Content-Type": "application/json"},
            json=sesion.dict()
        )
        if resp.status_code in (200, 204):
            # Algunos ORDS devuelven 204 sin contenido al actualizar
            return {"message": f"Sesion con ID {id} actualizado correctamente"}
        else:
            return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}

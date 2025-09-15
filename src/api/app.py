import httpx
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI()

# Cliente global para mantener cookies entre peticiones
session = httpx.AsyncClient(
    timeout=20.0,
    follow_redirects=True
)

BASE_URL = "https://oracleapex.com/ords/as_asistenciamovil/servicios_universitarios/"
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


@app.get("/servicios")
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


@app.get("/servicio/{id}")
async def get_servicio(id: int):
    await ensure_cookies()
    url = f"{BASE_URL}?q={{\"ID\":{{\"$eq\":{id}}}}}"
    try:
        resp = await session.get(url, headers=HEADERS)
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}


class Servicio(BaseModel):
    ID: int
    NOMBRE: str
    TIPO_SERVICIO: str
    FECHA: str
    REPETICION: str
    ID_RESPONSABLE: int


@app.post("/crearservicio")
async def create_servicio(servicio: Servicio):
    await ensure_cookies()
    try:
        resp = await session.post(BASE_URL, headers={**HEADERS, "Content-Type": "application/json"},
                                  json=servicio.dict())
        resp.raise_for_status()
        return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}


@app.delete("/eliminarservicio/{id}")
async def delete_servicio(id: int):
    await ensure_cookies()
    url = f"{BASE_URL}{id}"
    try:
        resp = await session.delete(url, headers=HEADERS)
        if resp.status_code == 204:
            return {"message": f"Servicio con ID {id} eliminado correctamente"}
        elif resp.status_code == 404:
            return {"error": f"Servicio con ID {id} no encontrado"}
        else:
            return {"status": resp.status_code, "detalle": resp.text}
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}

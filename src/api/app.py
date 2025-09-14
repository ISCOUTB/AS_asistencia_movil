import httpx
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI()

@app.get("/servicios")  # METODO PARA OBTENER TODOS
async def get_servicios():
    url = "https://oracleapex.com/ords/as_asistenciamovil/servicios_universitarios/"
    headers = {
        "Accept": "application/json",
        "User-Agent": "FastAPI-Client"
    }
    auth = ("APIUSER", "as_asistencia")  # Usuario y contraseña

    try:
        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            resp = await client.get(url, headers=headers, auth=auth)
            resp.raise_for_status()
            return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except httpx.HTTPStatusError as e:
        return {"error": f"HTTP {e.response.status_code}", "detalle": e.response.text}
    except Exception as e:
        return {"error": str(e)}


@app.get("/servicio/{id}")  # METODO PARA OBTENER UN ID
async def get_servicio(id: int):
    URL = "https://oracleapex.com/ords/as_asistenciamovil/servicios_universitarios/"
    url = f"{URL}?q={{\"ID\":{{\"$eq\":{id}}}}}"
    headers = {
        "Accept": "application/json",
        "User-Agent": "FastAPI-Client"
    }
    auth = ("APIUSER", "as_asistencia")

    try:
        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True, auth=auth) as client:
            resp = await client.get(url, headers=headers)
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
    FECHA: str       # Formato ISO: "YYYY-MM-DD"
    REPETICION: str  # 1 carácter
    ID_RESPONSABLE: int


@app.post("/servicio")  # CREAR SERVICIO
async def create_servicio(servicio: Servicio):
    URL = "https://oracleapex.com/ords/as_asistenciamovil/servicios_universitarios/"
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "User-Agent": "FastAPI-Client"
    }
    auth = ("APIUSER", "as_asistencia")

    try:
        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True, auth=auth) as client:
            resp = await client.post(URL, headers=headers, json=servicio.dict())
            resp.raise_for_status()
            return resp.json()
    except httpx.TimeoutException:
        return {"error": "Timeout: ORDS no respondió"}
    except Exception as e:
        return {"error": str(e)}


@app.delete("/eliminarservicio/{id}")  # ELIMINAR SERVICIO
async def delete_servicio(id: int):
    URL = f"https://oracleapex.com/ords/as_asistenciamovil/servicios/{id}"
    headers = {
        "Accept": "application/json",
        "User-Agent": "FastAPI-Client"
    }
    auth = ("APIUSER", "as_asistencia")

    try:
        async with httpx.AsyncClient(timeout=10.0, follow_redirects=True, auth=auth) as client:
            resp = await client.delete(URL, headers=headers)
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

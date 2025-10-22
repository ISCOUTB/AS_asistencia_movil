import os
import httpx
from fastapi import APIRouter, HTTPException
from dotenv import load_dotenv
from pydantic import BaseModel

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))

app = APIRouter(prefix="/auth", tags=["Auth"])

BASE_URL_PERSONAS = os.getenv("URL_PERSONAS")
BASE_URL_FACILITADORES = os.getenv("URL_FACILITADORES")

session = httpx.AsyncClient(timeout=20.0, follow_redirects=True)

class LoginRequest(BaseModel):
    email: str
    id_token: str
    access_token: str
    user_name: str

class LoginResponse(BaseModel):
    success: bool
    user: dict
    rol: str
    message: str

@app.post("/login", response_model=LoginResponse)
async def login_user(login_data: LoginRequest):
    """
    Endpoint de login que recibe los datos de Microsoft 365
    y busca la información del usuario en la base de datos
    """
    try:
        # Buscar persona por email (código banner)
        persona_url = f"{BASE_URL_PERSONAS}?q={{\"codigo_banner\":\"{login_data.email}\"}}"
        persona_resp = await session.get(persona_url)
        persona_data = persona_resp.json()
        
        # Extraer items de la respuesta
        personas = persona_data.get("items", []) if isinstance(persona_data, dict) else persona_data
        
        if not personas:
            raise HTTPException(
                status_code=404,
                detail="Usuario no encontrado en el sistema. Contacte al administrador."
            )
        
        persona = personas[0] if isinstance(personas, list) else personas
        persona_id = persona.get("id") or persona.get("ID_ASISTENTES") or persona.get("id_persona")
        
        # Verificar si es facilitador
        facilitador_url = f"{BASE_URL_FACILITADORES}"
        facilitador_resp = await session.get(facilitador_url)
        facilitadores_data = facilitador_resp.json()
        facilitadores = facilitadores_data.get("items", []) if isinstance(facilitadores_data, dict) else facilitadores_data
        
        # Buscar si la persona es facilitador
        es_facilitador = False
        facilitador_info = None
        for fac in facilitadores:
            if fac.get("email", "").lower() == login_data.email.lower():
                es_facilitador = True
                facilitador_info = fac
                break
        
        # Determinar rol
        rol = "profesor" if es_facilitador else "estudiante"
        
        # Construir respuesta
        user_data = {
            "id": persona_id,
            "nombre": persona.get("nombre_asistente") or login_data.user_name,
            "email": login_data.email,
            "identificacion": persona.get("identificacion"),
            "codigo_banner": persona.get("codigo_banner"),
            "tipo_identificacion": persona.get("tipo_de_identificacion"),
        }
        
        if es_facilitador and facilitador_info:
            user_data.update({
                "facilitador_id": facilitador_info.get("id") or facilitador_info.get("ID_FACILITADOR"),
                "telefono": facilitador_info.get("telefono"),
                "departamento": facilitador_info.get("nombre"),  # El nombre del facilitador puede incluir departamento
            })
        
        return LoginResponse(
            success=True,
            user=user_data,
            rol=rol,
            message=f"Bienvenido {user_data['nombre']}"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al procesar login: {str(e)}"
        )

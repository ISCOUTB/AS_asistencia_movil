import os
from fastapi import APIRouter, Request,HTTPException
from dotenv import load_dotenv
from fastapi.responses import RedirectResponse, JSONResponse
from msal import ConfidentialClientApplication
from api.core.auth_utils import validar_token_ms

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))
app = APIRouter(prefix="/auth/microsoft", tags=["Microsoft Auth"])

# Variables de entorno (de la app en Azure)
CLIENT_ID = os.getenv("MICROSOFT_CLIENT_ID")
CLIENT_SECRET = os.getenv("MICROSOFT_CLIENT_SECRET")
TENANT_ID = os.getenv("MICROSOFT_TENANT_ID")
REDIRECT_URI = os.getenv("MICROSOFT_REDIRECT_URI")
AUTHORITY = os.getenv("MICROSOFT_AUTHORITY")
MICROSOFT_SCOPES = os.getenv("MICROSOFT_SCOPES", "")
SCOPE = [s.strip() for s in MICROSOFT_SCOPES.split(",") if s.strip()]

# Redirección usuario al login de Microsoft
@app.get("/login")
def login():
    """Redirige al usuario al login de Microsoft"""
    app = ConfidentialClientApplication(
        CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET
    )
    auth_url = app.get_authorization_request_url(SCOPE, redirect_uri=REDIRECT_URI)
    return RedirectResponse(auth_url)

# Callback de Microsoft después del login
@app.get("/auth/redirect")
def auth_redirect(request: Request):
    code = request.query_params.get("code")

    if not code:
        return JSONResponse({"error": "No code received"}, status_code=400)

    app_msal = ConfidentialClientApplication(
        CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET
    )

    result = app_msal.acquire_token_by_authorization_code(
        code, scopes=SCOPE, redirect_uri=REDIRECT_URI
    )

    # Verificar si el flujo fue exitoso
    if "access_token" in result and "id_token_claims" in result:
        return JSONResponse({
            "message": "Autenticación exitosa con Microsoft 365",
            "access_token": result["access_token"],
            "id_token": result.get("id_token"),
            "user_info": result["id_token_claims"]
        })
    else:
        # Si algo sale mal, devolvemos el error detallado
        return JSONResponse(result, status_code=400)
    
@app.post("/auth/verify")
async def verificar_token(request: Request):
    data = await request.json()
    id_token = data.get("id_token")

    if not id_token:
        raise HTTPException(status_code=400, detail="Falta id_token")

    try:
        claims = validar_token_ms(id_token)
        return JSONResponse({
            "status": "ok",
            "user": {
                "name": claims.get("name"),
                "email": claims.get("preferred_username"),
                "oid": claims.get("oid")
            },
            "claims": claims
        })
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token inválido: {str(e)}")
@app.post("/callback")
async def microsoft_callback(request: Request):
    """
    Endpoint que recibe el id_token devuelto por Microsoft
    y valida su autenticidad.
    """
    try:
        data = await request.json()
        id_token = data.get("id_token")

        if not id_token:
            raise HTTPException(status_code=400, detail="Falta el id_token en la solicitud.")

        claims = validar_token_ms(id_token)

        return {
            "success": True,
            "message": "Token válido.",
            "claims": claims  # Devuelve los datos decodificados del usuario
        }

    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Token inválido: {str(e)}")
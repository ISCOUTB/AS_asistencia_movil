import requests, os
from jose import jwt, jwk
from jose.exceptions import JWTError
from dotenv import load_dotenv

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../../.env"))
CLIENT_ID = os.getenv("MICROSOFT_CLIENT_ID")
TENANT_ID = os.getenv("MICROSOFT_TENANT_ID")

AUTHORITY = f"https://login.microsoftonline.com/{TENANT_ID}"
JWKS_URI = f"{AUTHORITY}/discovery/v2.0/keys"

response = requests.get(JWKS_URI)
response.raise_for_status()
jwks_data = response.json()

_jwks_cache = None

def obtener_jwks():
    """Descarga las claves públicas (JWKS) desde Microsoft si no están en cache."""
    global _jwks_cache
    if _jwks_cache is None:
        response = requests.get(JWKS_URI)
        response.raise_for_status()
        keys = response.json()["keys"]
        # Guardamos las claves como un diccionario accesible por 'kid'
        _jwks_cache = {key["kid"]: key for key in keys}
    return _jwks_cache

def validar_token_ms(id_token: str):
    """Valida el id_token devuelto por Microsoft 365 (Azure AD v2.0)."""
    # Obtener encabezado del token sin verificarlo
    header = jwt.get_unverified_header(id_token)
    jwks_keys = obtener_jwks()
    key = jwks_keys.get(header["kid"])

    if not key:
        raise ValueError("No se encontró la clave correspondiente al token.")

    # Construir clave pública RSA desde JWK
    public_key = RSAAlgorithm.from_jwk(key)

    # Decodificar y validar el token
    claims = jwt.decode(
        id_token,
        public_key,
        algorithms=["RS256"],
        audience=CLIENT_ID,
        options={"verify_exp": True, "verify_aud": True},
    )

    return claims
import os, httpx
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
#from backend.app.core.config import settings
#from backend.app.core.middlewares import add_middlewares
#from backend.app.logic.universal_controller_instance import universal_controller
from api.routes import (
    sesion_service
)

# Inicializar la aplicación FastAPI
app = FastAPI()

# Añadir middlewares globales
    #add_middlewares(app)

"""app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4967",  # solo si aún pruebas en local
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)"""

# Cliente global para mantener cookies entre peticiones
# Incluir rutas de los microservicios
app.include_router(sesion_service.app)
import os, httpx
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
#from api.core.config import settings
#from api.core.middlewares import add_middlewares
from api.routes import (
    sesion_service,
    asistencia_sesion_service,
    servicio_service,
    persona_service,
    departamento_service,
    facilitador_service
)

# Inicializar la aplicación FastAPI
app = FastAPI(
    title="AS_ASISTENCIAMOVIL",
    description="Documentación automática con Swagger (FastAPI)",
    version="1.0.0"
)

# Añadir middlewares globales

#add_middlewares(app)

"""app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8000",  # solo si aún pruebas en local
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)"""

# Cliente global para mantener cookies entre peticiones
# Incluir rutas de los microservicios
app.include_router(sesion_service.app)
app.include_router(asistencia_sesion_service.app)
app.include_router(servicio_service.app)
app.include_router(persona_service.app)
app.include_router(departamento_service.app)
app.include_router(facilitador_service.app)
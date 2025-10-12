from fastapi import FastAPI
from api.core  import auth
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

# Incluir rutas de los microservicios
app.include_router(auth.app)
app.include_router(sesion_service.app)
app.include_router(asistencia_sesion_service.app)
app.include_router(servicio_service.app)
app.include_router(persona_service.app)
app.include_router(departamento_service.app)
app.include_router(facilitador_service.app)
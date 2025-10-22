from pydantic import BaseModel
from typing import Optional


# Modelo de entrada (crear o actualizar una persona)
class PersonaIn(BaseModel):
    codigo_banner: Optional[str] = None
    identificacion: str  # Documento de identidad
    tipo_de_identificacion: Optional[str] = None
    nombre_asistente: str


# Modelo de salida (lo que devuelve la API al cliente)
class PersonaOut(PersonaIn):
    id: int  # Primary Key (puede llamarse ID_PERSONA o ID_ASISTENTES)

    class Config:
        orm_mode = True

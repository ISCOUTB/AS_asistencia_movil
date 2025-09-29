from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Modelo de entrada (crear o actualizar una asistencia)
class AsistenciaSesionIn(BaseModel):
    id_sesiones: int
    documento_identidad: str
    id_persona: int
    usuario_creacion: str
    usuario_actualizacion: Optional[str] = None
    fecha_actualizacion: Optional[datetime] = None
    id_modalidades: Optional[int] = None
    id_tipos_documento: Optional[str] = None
    codigo_telefonico: Optional[str] = None
    geo_latitud: Optional[float] = None
    geo_longitud: Optional[float] = None
    observaciones: Optional[str] = None


# Modelo de salida (lo que devuelve la API al cliente)
class AsistenciaSesionOut(BaseModel):
    id: int
    fecha_creacion: datetime
    id_sesiones: int
    documento_identidad: str
    id_persona: int
    usuario_creacion: str
    usuario_actualizacion: Optional[str] = None
    fecha_actualizacion: Optional[datetime] = None
    id_modalidades: Optional[int] = None
    id_tipos_documento: Optional[str] = None
    codigo_telefonico: Optional[str] = None
    geo_latitud: Optional[float] = None
    geo_longitud: Optional[float] = None
    observaciones: Optional[str] = None

    class Config:
        orm_mode = True


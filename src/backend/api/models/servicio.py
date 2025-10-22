from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Modelo de entrada (crear o actualizar un servicio)
class ServicioIn(BaseModel):
    id_departamento: int  # FK a DEPARTAMENTOS
    id_padre: Optional[int] = None
    nombre_servicio: str
    fecha_creacion_servicio: Optional[datetime] = None
    descripcion: Optional[str] = None


# Modelo de salida (lo que devuelve la API al cliente)
class ServicioOut(ServicioIn):
    id: int  # Primary Key

    class Config:
        orm_mode = True

from pydantic import BaseModel
from typing import Optional


# Modelo de entrada (crear o actualizar un facilitador)
class FacilitadorIn(BaseModel):
    nombre: str
    email: Optional[str] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = True


# Modelo de salida (lo que devuelve la API al cliente)
class FacilitadorOut(FacilitadorIn):
    id: int  # Primary Key

    class Config:
        orm_mode = True

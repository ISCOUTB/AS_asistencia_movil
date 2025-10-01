from pydantic import BaseModel
from typing import Optional


# Modelo de entrada (crear o actualizar un departamento)
class DepartamentoIn(BaseModel):
    centro: Optional[str] = None
    descripcion: str


# Modelo de salida (lo que devuelve la API al cliente)
class DepartamentoOut(DepartamentoIn):
    id: int  # Primary Key

    class Config:
        orm_mode = True

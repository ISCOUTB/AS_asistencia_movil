from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime

# 📥 Modelo de entrada (crear o actualizar una sesión)
class SesionIn(BaseModel):
    id_servicio: int
    id_periodo: int
    id_tipo: int
    descripcion: Optional[str] = None
    hora_inicio_sesion: Optional[str] = None
    fecha_fin: Optional[datetime] = None
    nombre_sesion: str
    id_modalidad: Optional[int] = None
    lugar_sesion: Optional[str] = None
    fecha: date
    id_semana: Optional[int] = None
    hora_inicio: Optional[datetime] = None
    hora_fin: Optional[datetime] = None
    id_faciltiador: Optional[str] = None
    n_maximo_asistentes: Optional[int] = None
    inscritos_actuales: Optional[int] = None
    antes_sesion: Optional[int] = None
    despues_sesion: Optional[int] = None
    gestiona_asis: Optional[str] = None
    facilitador_externo: Optional[str] = None

# 📤 Modelo de salida (lo que devuelves al cliente)
class SesionOut(SesionIn):
    id: int  # La clave primaria generada por la base de datos

    class Config:
        orm_mode = True

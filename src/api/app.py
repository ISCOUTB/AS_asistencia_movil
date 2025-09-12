from fastapi import FastAPI, Query
import requests

app = FastAPI()

URL = "https://oracleapex.com/ords/as_asistenciamovil/servicios/"
HEADERS = {
    "Cookie": (
        "ak_bmsc=7D5C7A60874802818F22C8DC1D219671~000000000000000000000000000000~"
        "YAAQF5x6XPv08jSZAQAAaDcxPx0r/ZprKTbVECB9DweoZTKeMyNFJ976DSu1xO1296KnvnIbnsGC3SrAIS9aajYp8RhmG38dGuqF7gH/2BGtVdln3kzDpHhUrZDInTW1g//3d2T9vlFPL/fdLjeL0ZFUOwi4ktOb7JtIQz1v7C8XolQjMAocVnmDHgrC6nE0ZtHRPR73xLlwRXZv/M3zUnQRC4lvIpQ3KPFmwwQRPu6SphwNy/qEQXdlzkcsjTDuKKPubpG12MBR/oq6DLzKZgL2L33kdvSdmS8Hwhudx+ZvdmHIHJlCLxY2t7jz/QFQuQ/yRZVT8CeM39GjoYBOutxe3dEVLQ50g0vCHsJSxt2a;"
        " bm_sv=A6D99E4E0EF5129EC02E8B42E0575193~YAAQGZx6XCEWEu6YAQAAmdVlPx1vEtb6IZXrFNCXHDgPWWl9sZaZatdJ66G/Ab/zW3HJKvUJLBgKaExvB5oG8fHRj/y7Qc/sKRaV1OT6peNy0BDlqhx9oLIkU8SmhaU6AUuHgV6x/mDisABstg/KMWKTYE0CgnrZbHqDxikx5XcV/2lABneWCZygM6a+cOJVF4u7AHXljSol3g2F4s1EHGq/8IdFxnw75kOgylEzehau6D0WY+7nTB465IA9+YdFr/dmMQ==~1"
    ),
    "Cache-Control": "no-cache",
    "User-Agent": "PostmanRuntime/7.39.1",
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive"
}

@app.get("/datos")
#SOLICITUD GET
def obtener_datos():
    response = requests.get(URL, headers=HEADERS)
    try:
        data = response.json()
        return data.get("items", [])
    except ValueError:
        # Si no devuelve JSON, retorna el texto de la respuesta
        return {"error": "Respuesta no es JSON", "contenido": response.text}
    
@app.delete("/eliminar/")
#solicitud DELETE
def eliminar_dato(id: int = Query(..., description="ID del registro a eliminar")):
    url = f"{URL}?q={"ID":{"$eq":{id}}}"  # Construimos la URL con el ID
    response = requests.delete(url, headers=HEADERS)
    try:
        data = response.json()
        return {"status_code": response.status_code, "response": data}
    except ValueError:
        return {"status_code": response.status_code, "response": response.text}
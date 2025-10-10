from fastapi import Request, FastAPI
from fastapi.responses import JSONResponse

async def catch_exceptions_middleware(request: Request, call_next):
    """
    Middleware to catch exceptions globally and return a generic error response.

    Args:
        request (Request): The incoming request.
        call_next: A function to get the response from the next middleware or endpoint.

    Returns:
        JSONResponse: A JSON response with status code 500 and a generic error message.
    """
    try:
        return await call_next(request)
    except Exception:
        return JSONResponse(status_code=500, content={"detail": "Internal server error"})


def add_middlewares(app: FastAPI):
    """
    Adds the global exception handling middleware to the FastAPI app.

    Args:
        app (FastAPI): The FastAPI application instance.
    """
    app.middleware("http")(catch_exceptions_middleware)
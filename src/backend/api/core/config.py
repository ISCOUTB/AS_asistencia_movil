import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    PROJECT_NAME: str = "Public Transit Agency"
    ALLOWED_ORIGINS: list = [origin.strip() for origin in os.getenv("ALLOWED_ORIGINS", "*").split(",")]

    # --- Microsoft 365 (Entra ID) ---
    MICROSOFT_CLIENT_ID: str = os.getenv("MICROSOFT_CLIENT_ID")
    MICROSOFT_CLIENT_SECRET: str = os.getenv("MICROSOFT_CLIENT_SECRET")
    MICROSOFT_TENANT_ID: str = os.getenv("MICROSOFT_TENANT_ID")
    MICROSOFT_REDIRECT_URI: str = os.getenv("MICROSOFT_REDIRECT_URI")
    MICROSOFT_AUTHORITY: str = os.getenv("MICROSOFT_AUTHORITY")
    MICROSOFT_SCOPES: list = [scope.strip() for scope in os.getenv("MICROSOFT_SCOPES", "").split(",")]

settings = Settings()

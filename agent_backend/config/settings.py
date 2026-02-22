import os
from dotenv import load_dotenv
from pydantic import Field
from pydantic_settings import BaseSettings

load_dotenv()

class Settings(BaseSettings):
    GOOGLE_API_KEYS: str = os.getenv("GOOGLE_API_KEYS", "")
    GOOGLE_API_KEY: str = os.getenv("GOOGLE_API_KEY", "")
    GOOGLE_PROJECT_ID: str = os.getenv("GOOGLE_PROJECT_ID", "")
    GOOGLE_LOCATION: str = os.getenv("GOOGLE_LOCATION", "us-central1")
    
    DEBUG: bool = os.getenv("DEBUG", "true").lower() == "true"
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    
    GEMINI_FLASH_MODEL: str = os.getenv("GEMINI_FLASH_MODEL", "gemini-flash-latest")
    GEMINI_PRO_MODEL: str = os.getenv("GEMINI_PRO_MODEL", "gemini-pro-latest")
    
    RATE_LIMIT: int = int(os.getenv("RATE_LIMIT", "10"))

    @property
    def api_keys(self) -> list[str]:
        keys = []
        if self.GOOGLE_API_KEYS:
            keys.extend([k.strip() for k in self.GOOGLE_API_KEYS.split(",") if k.strip()])
        if self.GOOGLE_API_KEY and self.GOOGLE_API_KEY not in keys:
            keys.append(self.GOOGLE_API_KEY.strip())
        return keys

    def validate_api_key(self):
        if not self.api_keys:
            raise ValueError("No GOOGLE_API_KEY or GOOGLE_API_KEYS found")
        for key in self.api_keys:
            if not key.startswith("AIza"):
                raise ValueError(f"Invalid API Key format: {key[:10]}...")

settings = Settings()
settings.validate_api_key()

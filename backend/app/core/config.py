"""
ContextOps — Application Configuration
"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # FalkorDB
    falkordb_host: str = "localhost"
    falkordb_port: int = 6379
    falkordb_password: str = ""
    falkordb_graph_name: str = "contextops"

    # Backend
    backend_host: str = "0.0.0.0"
    backend_port: int = 8000
    backend_debug: bool = True
    backend_cors_origins: str = "http://localhost:3000"

    # LLM (to be configured during implementation)
    # llm_provider: str = ""
    # llm_api_key: str = ""
    # llm_model: str = ""

    @property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.backend_cors_origins.split(",")]

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()

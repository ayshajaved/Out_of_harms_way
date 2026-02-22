from typing import List, Optional, Dict
from pydantic import BaseModel, Field, validator
from datetime import datetime
import uuid

# --- Agent Models ---

class AgentInput(BaseModel):
    user_prompt: str = Field(..., min_length=10, max_length=1000)
    language: str # python, javascript, java, go, rust
    framework: Optional[str] = None
    context: Optional[Dict] = {}

class AgentOutput(BaseModel):
    success: bool
    data: Dict
    error: Optional[str] = None
    tokens_used: int = 0
    latency_ms: int = 0

# --- Orchestrator / API Models ---

class CodeRequest(BaseModel):
    prompt: str = Field(..., min_length=10, max_length=1000)
    language: str
    user_id: str
    session_id: Optional[str] = None

    @validator('language')
    def validate_language(cls, v):
        allowed = ["python", "javascript", "java", "go", "rust"]
        if v.lower() not in allowed:
            raise ValueError(f"Language must be one of {allowed}")
        return v.lower()

class CodeResponse(BaseModel):
    success: bool
    final_code: Optional[str] = None
    security_score: int = 0
    explanation: str = ""
    agent_steps: List[str] = []
    vulnerabilities_found: Optional[List[Dict]] = []
    patterns_used: Optional[List[str]] = []
    latency_seconds: float = 0.0
    error: Optional[str] = None

class OrchestratorState(BaseModel):
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    original_prompt: str
    current_step: str = "initialization"
    step_history: List[str] = []
    requirements: Optional[Dict] = None
    threats: Optional[List[Dict]] = []
    generated_code: Optional[str] = None
    vulnerabilities: Optional[List[Dict]] = []
    patterns_used: List[str] = []
    remediated_code: Optional[str] = None
    final_code: Optional[str] = None
    explanation: Optional[str] = None
    start_time: datetime = Field(default_factory=datetime.now)
    end_time: Optional[datetime] = None
    errors: List[str] = []

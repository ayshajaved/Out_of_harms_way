from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import json
from datetime import datetime
import uvicorn
import time
import asyncio

from config.settings import settings
from models.schemas import CodeRequest, CodeResponse
from services.gemini_service import GeminiService
from services.orchestrator import Orchestrator

app = FastAPI(
    title="Out of Harm's Way Backend",
    description="Multi-agent secure code generation system",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, restrict to Flutter web origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
gemini_service = GeminiService()
orchestrator = Orchestrator(gemini_service)

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "mode": "single_call",
        "rate_limit_rpm": 4
    }

@app.post("/generate", response_model=CodeResponse)
async def generate_code(request: CodeRequest):
    try:
        response = await orchestrator.run(request)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/generate/stream")
async def generate_code_stream(request: CodeRequest):
    """Streams progress events before returning the final result."""
    async def event_generator():
        queue = asyncio.Queue()

        async def callback(data):
            await queue.put(data)

        # Run orchestrator in a background task
        task = asyncio.create_task(orchestrator.run(request, on_progress=callback))

        while not task.done():
            try:
                # Wait for progress data
                data = await asyncio.wait_for(queue.get(), timeout=1.0)
                yield f"data: {json.dumps(data)}\n\n"
            except asyncio.TimeoutError:
                continue

        # Send final result
        result = await task
        yield f"data: {json.dumps({'step': 'complete', 'result': result.dict()})}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")

@app.post("/dev/mock", response_model=CodeResponse)
async def mock_generate(request: CodeRequest):
    """Returns a mock response for frontend testing."""
    return CodeResponse(
        success=True,
        final_code="def login():\n    print('Mock secure login')",
        security_score=95,
        explanation="This is a mock response for testing.",
        agent_steps=["mock_step"],
        vulnerabilities_found=[],
        patterns_used=["Mock Pattern"],
        latency_seconds=0.5
    )

@app.post("/generate/stream/mock")
async def generate_code_stream_mock(request: CodeRequest):
    """Streams a realistic mock sequence of progress events without calling Gemini."""
    async def event_generator():
        # Simulate Initialization
        yield f"data: {json.dumps({'step': 'initialization', 'status': 'Initializing mock secure generation engine...'})}\n\n"
        await asyncio.sleep(1.5)
        
        # Simulate Generation
        yield f"data: {json.dumps({'step': 'generation', 'status': 'Analyzing threats and generating secure implementation...'})}\n\n"
        await asyncio.sleep(2.0)
        
        # Simulate Completion
        yield f"data: {json.dumps({'step': 'complete', 'status': 'Generation successful!'})}\n\n"
        
        mock_result = {
            "success": True,
            "final_code": "def parse_xml_securely(xml_string):\n    import defusedxml.ElementTree as ET\n    # Using defusedxml to prevent XML External Entity (XXE) attacks\n    try:\n        root = ET.fromstring(xml_string)\n        return root\n    except Exception as e:\n        return str(e)",
            "security_score": 100,
            "explanation": "This mock response simulates a secure XML parser. It mitigates XXE vulnerabilities by using the `defusedxml` package instead of the standard library `xml` module.",
            "agent_steps": ["requirements", "threat_modeling", "generator", "scanner", "explanation"],
            "vulnerabilities_found": [{"category": "Information Disclosure (XXE)", "mitigation": "Used defusedxml"}],
            "patterns_used": ["Safe XML Parsing", "Exception Handling"],
            "latency_seconds": 3.7
        }
        
        yield f"data: {json.dumps({'step': 'complete', 'result': mock_result})}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")

@app.get("/agents")
async def list_agents():
    return [
        {"name": "Master Agent", "role": "Single-call secure generation (Gemini Flash)"}
    ]

if __name__ == "__main__":
    uvicorn.run(
        "main:app", 
        host=settings.HOST, 
        port=settings.PORT, 
        reload=settings.DEBUG
    )

from typing import List, Optional, Callable
import asyncio
import time
from datetime import datetime

from models.schemas import CodeRequest, CodeResponse, OrchestratorState
from services.gemini_service import GeminiService
from services.single_call_service import SingleCallService

class Orchestrator:
    def __init__(self, gemini_service: GeminiService):
        self.gemini_service = gemini_service
        self.single_call_service = SingleCallService(gemini_service)

    async def run(self, request: CodeRequest, on_progress: Optional[Callable] = None) -> CodeResponse:
        async def report_progress(step: str, status: str):
            if on_progress:
                if asyncio.iscoroutinefunction(on_progress):
                    await on_progress({"step": step, "status": status})
                else:
                    on_progress({"step": step, "status": status})

        start_time = time.time()
        
        try:
            # Step 1: Initialization
            await report_progress("initialization", "Initializing secure generation engine...")
            
            # Step 2: Single Call Generation
            await report_progress("generation", "Analyzing threats and generating secure implementation...")
            
            # We use the SingleCallService which handles the master prompt logic
            response = await self.single_call_service.generate_secure_code(request)
            
            # Step 3: Completion
            if response.success:
                await report_progress("complete", "Generation successful!")
            else:
                await report_progress("error", f"Generation failed: {response.error}")
            
            # Update latency to reflect total orchestrator time
            response.latency_seconds = round(time.time() - start_time, 2)
            return response
            
        except Exception as e:
            latency = time.time() - start_time
            return CodeResponse(
                success=False,
                error=f"Orchestrator encountered critical error: {str(e)}",
                latency_seconds=round(latency, 2)
            )

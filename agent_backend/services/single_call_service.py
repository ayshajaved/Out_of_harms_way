import json
import re
import time
from typing import Dict, Any, Optional
from services.gemini_service import GeminiService
from services.prompt_templates import MASTER_PROMPT_TEMPLATE
from models.schemas import CodeRequest, CodeResponse

class SingleCallService:
    def __init__(self, gemini_service: GeminiService):
        self.gemini_service = gemini_service

    def _prepare_prompt(self, request: CodeRequest) -> str:
        prompt = MASTER_PROMPT_TEMPLATE
        prompt = prompt.replace("{{language}}", request.language)
        prompt = prompt.replace("{{prompt}}", request.prompt)
        return prompt

    def _clean_json(self, text: str) -> str:
        # Remove markdown code blocks if present
        text = re.sub(r'```json\s*', '', text)
        text = re.sub(r'```\s*', '', text)
        text = text.strip()
        
        # Handle trailing commas in JSON (common Gemini issue)
        text = re.sub(r',\s*}', '}', text)
        text = re.sub(r',\s*]', ']', text)
        
        return text

    async def generate_secure_code(self, request: CodeRequest) -> CodeResponse:
        start_time = time.time()
        
        master_prompt = self._prepare_prompt(request)
        
        # Call Gemini Flash for cost/speed efficiency as per request
        response_data = await self.gemini_service.generate_content(
            model_type="flash",
            system_prompt="You are a JSON-only security expert.",
            user_prompt=master_prompt,
            temperature=0.2,
            response_format="json"
        )
        
        if response_data.get("error"):
            return CodeResponse(
                success=False,
                error=f"Gemini API Error: {response_data['error']}",
                latency_seconds=round(time.time() - start_time, 2)
            )

        try:
            cleaned_json = self._clean_json(response_data["text"])
            parsed = json.loads(cleaned_json)
            
            latency = time.time() - start_time
            
            return CodeResponse(
                success=True,
                final_code=parsed.get("code", ""),
                security_score=parsed.get("security_score", 0),
                explanation=parsed.get("explanation", ""),
                agent_steps=["requirements", "threat_modeling", "generator", "scanner", "explanation"],
                vulnerabilities_found=parsed.get("vulnerabilities_found", []),
                patterns_used=parsed.get("patterns_used", []),
                latency_seconds=round(latency, 2)
            )
        except Exception as e:
            return CodeResponse(
                success=False,
                error=f"Failed to parse model response: {str(e)}",
                latency_seconds=round(time.time() - start_time, 2)
            )

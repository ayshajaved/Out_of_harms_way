import time
import asyncio
import json
import httpx
import random
from typing import Optional, Dict, Any
from config.settings import settings

class GeminiService:
    def __init__(self):
        self.api_keys = settings.api_keys
        if not self.api_keys:
            raise ValueError("No API keys found in settings")
        
        self.current_key_idx = 0
        self.lock = asyncio.Lock()
        
        # Safety settings: For code generation, we want minimal filtering 
        self.safety_settings = [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
            {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        ]

    def _get_current_key(self) -> str:
        return self.api_keys[self.current_key_idx]

    async def _rotate_key(self):
        async with self.lock:
            self.current_key_idx = (self.current_key_idx + 1) % len(self.api_keys)
            print(f"[GEMINI] Rotated to API key index {self.current_key_idx}")

    async def generate_content(
        self, 
        model_type: str, 
        system_prompt: str, 
        user_prompt: str, 
        temperature: float = 0.1,
        max_tokens: int = 4096,
        response_format: Optional[str] = None
    ) -> Dict[str, Any]:
        model_name = settings.GEMINI_PRO_MODEL if model_type == "pro" else settings.GEMINI_FLASH_MODEL
        
        start_time = time.time()
        max_retries = 5
        base_delay = 1.0
        
        full_prompt = f"System Instruction: {system_prompt}\n\nUser Request: {user_prompt}"
        if response_format == "json":
            full_prompt += "\nOutput MUST be strictly valid JSON."

        for attempt in range(max_retries):
            api_key = self._get_current_key()
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
            
            payload = {
                "contents": [{"parts": [{"text": full_prompt}]}],
                "generationConfig": {
                    "temperature": temperature,
                    "maxOutputTokens": max_tokens
                },
                "safetySettings": self.safety_settings
            }

            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.post(url, json=payload)
                
                latency_ms = int((time.time() - start_time) * 1000)

                if response.status_code == 200:
                    data = response.json()
                    
                    try:
                        text_output = data["candidates"][0]["content"]["parts"][0]["text"]
                        return {
                            "text": text_output,
                            "tokens_input": 0,
                            "tokens_output": 0,
                            "latency_ms": latency_ms,
                            "error": None
                        }
                    except (KeyError, IndexError):
                        finish_reason = data.get("candidates", [{}])[0].get("finishReason", "UNKNOWN")
                        return {
                            "text": "",
                            "tokens_input": 0,
                            "tokens_output": 0,
                            "latency_ms": latency_ms,
                            "error": f"Model returned empty or blocked response. Reason: {finish_reason}"
                        }
                elif response.status_code == 429:
                    print(f"[GEMINI] Rate limit reached (429) for key {self.current_key_idx}.")
                    # If we have multiple keys, try to rotate and retry immediately (once per loop)
                    if len(self.api_keys) > 1:
                        await self._rotate_key()
                        # Allow immediate retry on the new key, but don't count it as a full delay penalty
                        await asyncio.sleep(0.5)
                        continue
                    else:
                        raise Exception("Quota Exhausted")
                else:
                    response.raise_for_status()

            except Exception as e:
                # Exponential backoff with jitter
                if attempt < max_retries - 1:
                    delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
                    print(f"[GEMINI] Request failed: {str(e)}. Retrying in {delay:.2f}s...")
                    await asyncio.sleep(delay)
                else:
                    return {
                        "text": "",
                        "tokens_input": 0,
                        "tokens_output": 0,
                        "latency_ms": int((time.time() - start_time) * 1000),
                        "error": str(e)
                    }

    async def generate_with_history(self, model_type: str, history: list, user_message: str):
        pass

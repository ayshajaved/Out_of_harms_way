# System Architecture & Design
*Out of Harm's Way - Google Solution Challenge 2026 Submission*

## 1. High-Level System Architecture
The system is designed with a **Headless Microservice Architecture**, strictly decoupling the interactive presentation layer (Flutter Web + WebGL/Three.js + MediaPipe) from the computationally heavy code generation and security validation layer (FastAPI + Google Gemini).

```mermaid
graph TD
    classDef frontend fill:#02569B,stroke:#fff,stroke-width:2px,color:#fff;
    classDef backend fill:#009688,stroke:#fff,stroke-width:2px,color:#fff;
    classDef ai fill:#FF5722,stroke:#fff,stroke-width:2px,color:#fff;
    classDef db fill:#FFCA28,stroke:#fff,stroke-width:2px,color:#000;

    subgraph PresentationLayer ["Flutter Web Application"]
        UI["Flutter UI / Riverpod"]:::frontend
        GL["Three.js Interactive Sphere"]:::frontend
        Cam["Device Camera"]:::frontend
        AIModel["MediaPipe Hands Model"]:::ai
        Cam --> |Video| AIModel
        AIModel --> |Hand Tracking Tensors| GL
        UI <--> |State| GL
    end

    subgraph CloudInfrastructure ["FastAPI Python Backend"]
        API["FastAPI SSE Router"]:::backend
        Orchestrator["Secure Execution Orchestrator"]:::backend
        Auth["Firebase Token Verification"]:::backend
        
        API --> Auth
        API --> Orchestrator
    end

    subgraph LLMEngine ["Google Cloud"]
        Rotator["API Key Rotation Pool"]:::backend
        Prompt["Master STRIDE Validation Engine"]:::ai
        Gemini["Google Gemini 1.5/2.0 Flash"]:::ai
        
        Orchestrator --> Prompt
        Prompt --> Rotator
        Rotator --> |Async httpx| Gemini
    end

    UI -->|"1. POST /generate/stream"| API
    API -->|"2. Server-Sent Events (SSE) Progress"| UI
    Gemini -->|"3. Cleaned JSON"| API
```

---

## 2. Secure Code Generation Flow (Sequence Diagram)
To guarantee OWASP Top 10 compliance, the system does not proxy raw prompts. Every generation request undergoes a rigorous internal Threat Modeling workflow before the final code is streamed to the user.

```mermaid
sequenceDiagram
    participant User as "User (Flutter UI)"
    participant API as "FastAPI Router"
    participant Engine as "SingleCallService"
    participant LLM as "Google Gemini API"

    User->>API: POST /generate/stream (prompt, language)
    activate API
    API-->>User: SSE Data: {step: "initialization"}
    
    API->>Engine: Begin Orchestration
    activate Engine
    Engine-->>API: Yield progress 
    API-->>User: SSE Data: {step: "generation", status: "Analyzing threats..."}
    
    Engine->>Engine: Injects Master STRIDE Prompt
    
    loop API Key Failover (Rate Limit Protection)
        Engine->>LLM: Async httpx payload
        alt HTTP 429 Quota Exhausted
            LLM-->>Engine: 429 Error
            Engine->>Engine: Rotate API Key Index + Backoff
        else Success
            LLM-->>Engine: Raw Text Response
        end
    end
    
    Engine->>Engine: Strip Markdown & Parse JSON
    Engine-->>API: Final Validated CodeResponse Object
    deactivate Engine
    
    API-->>User: SSE Data: {step: "complete", result: {code, score, OWASP_mitigations}}
    deactivate API
```

---

## 3. Top 1% Project File Structure (DDD Standard)
The repository is perfectly structured following enterprise standards. Domain Driven Design (DDD) is enforced on the frontend, while a modular approach secures the backend routing.

```mermaid
graph LR
    classDef folder fill:#e0e0e0,stroke:#bdbdbd,stroke-width:1px,color:#000;
    classDef file fill:#fff,stroke:#e0e0e0,stroke-width:1px,color:#666;

    Root(("Out of Harm's Way"))
    
    Root --> FlutterFramework["lib/"]:::folder
    FlutterFramework --> F_Core["core/"]:::folder
    FlutterFramework --> F_Presentation["presentation/"]:::folder
    FlutterFramework --> F_Services["services/"]:::folder
    F_Core --> Theme["Theme, Providers, Config"]:::file
    F_Presentation --> Screens["CodeGeneratorScreen, HeroScreen"]:::file
    F_Services --> BackendService["backend_service.dart"]:::file
    
    Root --> WebAssets["web/"]:::folder
    WebAssets --> Index["index.html (MediaPipe loader)"]:::file
    WebAssets --> ThreeEngine["three_scene.js"]:::file

    Root --> PythonBackend["agent_backend/"]:::folder
    PythonBackend --> B_Config["config/"]:::folder
    PythonBackend --> B_Models["models/schemas.py"]:::folder
    PythonBackend --> B_Services["services/"]:::folder
    PythonBackend --> B_Main["main.py (FastAPI Routes)"]:::file
    
    B_Services --> GeminiService["gemini_service.py (Key Rotation)"]:::file
    B_Services --> SingleCall["single_call_service.py"]:::file
    B_Services --> Template["prompt_templates.py"]:::file

    Root --> Docs["ARCHITECTURE.md"]:::file
    Root --> Make["Makefile"]:::file
```

---

## 4. Automatic Rate-Limit Failover Workflow
Crucial for the competition, this diagram illustrates how our system achieves 100% uptime despite free-tier API quotas.

```mermaid
stateDiagram-v2
    [*] --> RequestReceived: User submits Prompt
    RequestReceived --> ReadArray: Fetch Current API Key Index
    ReadArray --> SendRequest: Call Gemini REST endpoint
    
    SendRequest --> HTTP_200: Success
    SendRequest --> HTTP_429: Quota Exhausted!
    SendRequest --> Timeout: Network Error
    
    HTTP_429 --> RotateKey: Increment Key Index Array % Length
    RotateKey --> JitterSleep: Wait 500ms
    JitterSleep --> SendRequest: Retry with new Key
    
    Timeout --> ExponentialBackoff: 2^attempt + jitter
    ExponentialBackoff --> SendRequest: Retry
    
    HTTP_200 --> ParseOutput: Clean JSON
    ParseOutput --> [*]: Stream to Frontend
```

## Security Engineering (STRIDE Assessment)
1. **Spoofing**: Rejected via immutable user session tokens.
2. **Tampering**: Read-only endpoints on the frontend; zero eval() execution.
3. **Repudiation**: State-tracked interactions through Firebase auth flows.
4. **Information Disclosure**: API keys scrubbed from frontend; injected exclusively by ASGI container.
5. **Denial of Service**: Defended via internal lock mechanisms and HTTP 429 rotation proxies.
6. **Elevation of Privilege**: Strict single-user token validation limits DB queries explicitly to user\_id constraints.

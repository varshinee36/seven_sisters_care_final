from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from routes.auth import router as auth_router
from routes.auth import router as auth_router
from routes.patient import router as patient_router

app = FastAPI(
    title="Seven Sisters Care API",
    description="Backend API for Seven Sisters Care – Dementia Care Application",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(patient_router)

# Include Authentication Router
app.include_router(auth_router)


@app.get("/", tags=["Health"])
def health_check():
    return {
        "status": "healthy",
        "app": "Seven Sisters Care API",
        "docs": "/docs",
    }

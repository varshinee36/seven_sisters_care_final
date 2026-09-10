from fastapi import APIRouter, HTTPException
from models.analytics import GamePerformanceRecord
from services.analytics_service import (
    get_dashboard_analytics,
    save_game_performance,
)

router = APIRouter(
    prefix="/analytics",
    tags=["Analytics"]
)


@router.get("/dashboard/{patient_id}")
def get_patient_dashboard_analytics(patient_id: str):
    """
    Returns dashboard analytics for a given patient.
    If no game records exist, returns safe default values without error.
    """
    try:
        return get_dashboard_analytics(patient_id)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving analytics for patient {patient_id}: {str(e)}"
        )


@router.post("/record")
def record_game_result(record: GamePerformanceRecord):
    """
    Records game session performance results into the game_performance collection.
    Future-ready endpoint for Memory Hunt, Pair Finder, and other cognitive games.
    """
    try:
        return save_game_performance(record)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error saving game performance: {str(e)}"
        )

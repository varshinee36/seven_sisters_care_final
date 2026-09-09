from fastapi import APIRouter, HTTPException
from models.patient import PatientRegister
from services.patient_service import (
    register_patient,
    get_patients_by_caregiver
)

router = APIRouter(
    prefix="/patient",
    tags=["Patient"]
)


@router.post("/register")
def create_patient(patient: PatientRegister):
    try:
        return register_patient(patient)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


@router.get("/{caregiver_username}")
def get_patients(caregiver_username: str):
    try:
        return get_patients_by_caregiver(caregiver_username)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
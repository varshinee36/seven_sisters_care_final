from typing import Literal
from pydantic import BaseModel, Field


class PatientRegister(BaseModel):
    caregiver_username: str = Field(
        ..., min_length=3, description="Caregiver username"
    )

    patient_name: str = Field(
        ..., min_length=2, max_length=100, description="Patient full name"
    )

    dob: str = Field(
        ..., description="Date of birth (YYYY-MM-DD)"
    )

    gender: Literal["Male", "Female", "Other"] = Field(
        ..., description="Patient gender"
    )

    language_preference: str = Field(
        ..., description="Preferred language"
    )

    reading_preference: bool = Field(
    ...,
    description="Can the patient read text? true = Yes, false = No"
)

    dementia_stage: Literal[
        "Mild",
        "Moderate",
        "Severe"
    ] = Field(
        ..., description="Dementia stage"
    )


class PatientResponse(BaseModel):
    message: str
    patient_name: str
    caregiver_username: str
class PatientResponse(BaseModel):
    message: str
    patient_id: str
    patient_name: str
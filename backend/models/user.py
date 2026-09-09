from typing import Literal
from pydantic import BaseModel, Field


class UserRegister(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, description="Unique username")
    password: str = Field(..., min_length=6, description="Password (minimum 6 characters)")
    role: Literal["patient", "caregiver"] = Field(..., description="Role must be 'patient' or 'caregiver'")


class UserLogin(BaseModel):
    username: str = Field(..., min_length=1, description="Username")
    password: str = Field(..., min_length=1, description="Password")


class UserResponse(BaseModel):
    message: str = Field(default="Success", description="Operation status message")
    username: str = Field(..., description="Account username")
    role: str = Field(..., description="Account role")

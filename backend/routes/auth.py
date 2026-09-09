from fastapi import APIRouter, status
from models.user import UserRegister, UserLogin, UserResponse
from services.auth_service import register_user, login_user

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
    description="Creates a new user account with unique username, hashed password, and specified role (patient or caregiver).",
)
def register(user_data: UserRegister):
    return register_user(user_data)


@router.post(
    "/login",
    response_model=UserResponse,
    status_code=status.HTTP_200_OK,
    summary="Login user",
    description="Authenticates user credentials and returns account role upon successful verification.",
)
def login(login_data: UserLogin):
    return login_user(login_data)

from fastapi import HTTPException, status
from database import users_collection
from models.user import UserRegister, UserLogin, UserResponse
from utils.security import hash_password, verify_password


def register_user(user_data: UserRegister) -> UserResponse:
    """
    Register a new user account in MongoDB.
    Validates username uniqueness, hashes the password with bcrypt,
    and saves the user document.
    """
    try:
        # Check if username already exists in MongoDB
        existing_user = users_collection.find_one({"username": user_data.username})
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already exists",
            )

        # Hash password and prepare user document
        hashed_pwd = hash_password(user_data.password)
        new_user = {
            "username": user_data.username,
            "password": hashed_pwd,
            "role": user_data.role,
        }

        # Store user in users collection
        users_collection.insert_one(new_user)

        return UserResponse(
            message="User registered successfully",
            username=user_data.username,
            role=user_data.role,
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


def login_user(login_data: UserLogin) -> UserResponse:
    """
    Authenticate an existing user.
    Finds the user by username, verifies the hashed password,
    and returns a success response with the user's role.
    """
    try:
        # Find user by username
        user = users_collection.find_one({"username": login_data.username})
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials",
            )

        # Verify password hash
        if not verify_password(login_data.password, user["password"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials",
            )

        return UserResponse(
            message="Login successful",
            username=user["username"],
            role=user.get("role", "patient"),
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )

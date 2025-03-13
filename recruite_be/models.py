from typing import Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime
from enum import Enum

# Định nghĩa Enum đúng cách
class UserRole(str, Enum):
    RECRUITER = "recruiter"
    JOB_SEEKER = "job_seeker"

# User Model (Dữ liệu trả về)
class User(BaseModel):
    id: int
    username: str
    password: str
    email: EmailStr
    verified: bool
    created_at: datetime
    resume: Optional[int]

# Dữ liệu client gửi lên khi tạo user
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    resume: Optional[int] = None

# UserInfo (Hồ sơ người dùng)
class UserInfo(BaseModel):
    id: int
    user_id: int
    avatar_url: Optional[str]
    role: Optional[UserRole]
    bio: Optional[str]
    location: Optional[str]
    headline: Optional[str]

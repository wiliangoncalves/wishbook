from fastapi import FastAPI, APIRouter, status, HTTPException

from pydantic import BaseModel

from src.models.models import User as Db_User

import re

from passlib.hash import pbkdf2_sha256 as bcrypt

import secrets

from .activate_email import send_activation_email

import os
from dotenv import load_dotenv
load_dotenv()
SECRET_KEY = os.getenv('SECRET_KEY')

register = FastAPI()

register = APIRouter(
    prefix='/register',
    tags=['register']
)

class User(BaseModel):
    firstname: str
    lastname: str
    email: str
    password: str

@register.post('/')
async def set_register(user:User):

    hash_password = bcrypt.hash(user.password)

    def email_check(email):
        pat = "^[a-zA-Z0-9-_]+@[a-zA-Z0-9]+\.[a-z]{1,3}$"
        if re.match(pat,email):
            return True
        return False

    database_check_email = await Db_User.filter(email=user.email).values()

    if len(user.firstname) < 4 or len(user.firstname.strip()) < 4:
        raise HTTPException(
            detail="Name must be at least 4 characters!",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if len(user.lastname) < 4 or len(user.lastname.strip()) < 4:
        raise HTTPException(
            detail="Lastname must be at least 4 characters!",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if(email_check(user.email) == False):
        raise HTTPException(
            detail="Please fill out E-mail",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if len(database_check_email) > 0:
        raise HTTPException(
            detail="E-mail is already in use",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if len(user.password) < 8:
        raise HTTPException(
            detail="Password must be at least 8 characters long",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if not re.search("[a-z]", user.password):
        raise HTTPException(
            detail="Password should have at least one lowercase letter",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if not re.search("[A-Z]", user.password):
        raise HTTPException(
            detail="Password should have at least one uppercase letter",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if not re.search("[0-9]", user.password): 
        raise HTTPException(
            detail="Password should have at least one digit",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    activate_link = secrets.token_hex(32)
    await Db_User.create(firstname=user.firstname, lastname=user.lastname, email=user.email, password=hash_password, activate_link=activate_link)


    await send_activation_email(user.email, user.firstname, activate_link)

    return {
        "status": status.HTTP_200_OK
    }
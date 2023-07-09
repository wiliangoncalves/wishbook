from fastapi import FastAPI, APIRouter, status, HTTPException
from pydantic import BaseModel

from src.models.models import User as Db_User

from passlib.hash import pbkdf2_sha256 as bcrypt
from jose import jwt

import os
from dotenv import load_dotenv
load_dotenv()
SECRET_KEY = os.getenv('SECRET_KEY')
ALGORITHM = os.getenv('ALGORITHM')

login = FastAPI()

login = APIRouter(
    prefix='/login',
    tags=['login']
)

class User(BaseModel):
    email: str
    password: str

@login.post('/')
async def post_login(user: User):
    print(f"Valor do email: {user.email}")

    data = await Db_User.filter(email=user.email).values()
    print(f"Valor de data: {data}")

    if len(data) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="E-mail or password is incorrect!"
        )

    id = data[0]['id']
    password = data[0]['password']

    token = {"Authorization: Bearer ": id}

    token_encoded = jwt.encode(token, SECRET_KEY, algorithm=ALGORITHM)

    hashPassword = bcrypt.verify(user.password, password)

    if hashPassword == False:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="E-mail or password is incorrect!"
        )
    
    if data[0]['is_verified'] == False:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Please, verify your e-mail"
        )

    return {"status": status.HTTP_200_OK, "Authorization": "Bearer "+token_encoded}
from fastapi import FastAPI, APIRouter, HTTPException, status, Depends
from fastapi.security.http import HTTPAuthorizationCredentials, HTTPBearer

from jose import jwt

import typing as t

from decouple import config

auth = FastAPI()

auth = APIRouter(
    prefix='/auth',
    tags=['auth']
)

SECRET_KEY = config('SECRET_KEY')
ALGORITHM = config('ALGORITHM')

get_bearer_token = HTTPBearer(auto_error=False)

async def get_auth(auth: t.Optional[HTTPAuthorizationCredentials] = Depends(get_bearer_token)):
    if auth == None:
        raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Token error, please login in again!'
            )
    else:
        try:
            token = jwt.decode(token=auth.credentials, key=SECRET_KEY, algorithms=ALGORITHM)['Authorization: Bearer ']
        except:
            print(auth.credentials)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Token error, please login in again!'
            )
        else:
            return {"status": status.HTTP_200_OK, "token": token}
from fastapi import FastAPI, APIRouter, Depends
from src.routes.auth import get_auth

profile = FastAPI()

profile = APIRouter(
  prefix='/profile',
  tags=['profile']
)

@profile.get('/')
async def get_profile(authorization: str = Depends(get_auth)):
  print(' PROFILE TOKEN ', authorization)
  return {'Login': 'ativado'}

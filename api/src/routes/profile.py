from fastapi import FastAPI, APIRouter, Depends, HTTPException, status
from src.routes.auth import get_auth

from src.models.models import User as Db_User

profile = FastAPI()

profile = APIRouter(
  prefix='/profile',
  tags=['profile']
)

@profile.get('/')
async def get_profile(authorization: str = Depends(get_auth)):
  data = await Db_User.filter(id=authorization['token']).values()

  is_verified = data[0]['is_verified']
  avatar = data[0]['avatar']
  firstname = data[0]['firstname']
  lastname = data[0]['lastname']
  email = data[0]['email']

  if is_verified == False:
    raise HTTPException(
      detail='Please verify your email',
      status_code=status.HTTP_401_UNAUTHORIZED
    )
  else:
    return {
      "avatar": avatar,
      "firstname": firstname,
      "lastname": lastname,
      "email": email
    }

@profile.put('/')
async def put_profile(new_firstname: str | None=None, new_lastname: str | None=None, new_avatar: str | None=None, authorization: str = Depends(get_auth)):
  data = await Db_User.get(id=authorization['token'])

  is_verified = data.is_verified
  avatar = data.avatar
  firstname = data.firstname
  lastname = data.lastname
  email = data.email

  if is_verified == False:
    raise HTTPException(
      detail='Please verify your email',
      status_code=status.HTTP_401_UNAUTHORIZED
    )
  else:
    if new_firstname == None or len(new_firstname) < 3:
      new_firstname = firstname

    if len(new_firstname.strip()) < 3:
        raise HTTPException(
            detail="Name must be at least 3 characters!",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    if new_lastname == None or len(new_lastname) < 3:
      new_lastname = lastname

    if len(new_lastname.strip()) < 3:
        raise HTTPException(
            detail="Lastname must be at least 3 characters!",
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    if new_avatar == None or len(new_avatar) < 3:
      new_avatar = avatar

    if len(new_avatar.strip()) < 3:
        raise HTTPException(
            detail="avatar cannot be empty!",
            status_code=status.HTTP_400_BAD_REQUEST
        )

    data.firstname = new_firstname
    data.lastname = new_lastname
    data.avatar = new_avatar
    await data.save()

    return {"status": status.HTTP_200_OK}

@profile.delete('/')
async def delete_profile(authorization: str = Depends(get_auth)):
  data = await Db_User.get(id=authorization['token'])

  is_verified = data.is_verified

  if is_verified == False:
    raise HTTPException(
      detail='Please verify your email',
      status_code=status.HTTP_401_UNAUTHORIZED
    )
  else:
    await data.delete()
  return {"status": status.HTTP_200_OK}
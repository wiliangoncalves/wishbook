from fastapi import FastAPI, APIRouter, Depends, HTTPException, status, Query
from src.routes.auth import get_auth
from pydantic import BaseModel

from typing import List

from src.models.models import Book as Db_Book

books = FastAPI()

books = APIRouter(
  prefix='/books',
  tags=['books']
)

aqui = ['fiction', 'horror']

@books.get('/')
async def get_book(authorization: str = Depends(get_auth)):
  try:
    data = await Db_Book.get(owner_id=authorization['token'])
  except:
    raise HTTPException(
      status_code=status.HTTP_404_NOT_FOUND,
      detail='None book founded!'
    )
  else:
    return {"books": data}

@books.post('/')
async def set_book(title: str,author: str,year: int, read: bool, cover: str | None=None, genre: List[str] = Query(None), authorization: str = Depends(get_auth)):

  data = await Db_Book.create(title=title, author=author, year=year, genre=genre, read=read, owner_id=authorization['token'])

  if title == None or len(title) < 3:
    raise HTTPException(
      detail='Title must be at least 3 characters!',
      status_code=status.HTTP_400_BAD_REQUEST
    )
  
  if author == None or len(author) < 3:
    raise HTTPException(
      detail='Author must be at least 3 characters!',
      status_code=status.HTTP_400_BAD_REQUEST
    )
  
  if year == None:
    raise HTTPException(
      detail='Year must be at least 2 numbers!',
      status_code=status.HTTP_400_BAD_REQUEST
    )

  await data.save()
  return {"status": status.HTTP_200_OK}
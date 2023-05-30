from fastapi import FastAPI, APIRouter, Depends, HTTPException, status, Query
from src.routes.auth import get_auth

from typing import List

from src.models.models import Book as Db_Book

book = FastAPI()

book = APIRouter(
  prefix='/book',
  tags=['book']
)

@book.get('/')
async def get_book(search_for_title: str | None=None, genre: str | None=None, read: bool | None=None, authorization: str = Depends(get_auth)):
  _title = 'title'
  _cover = 'cover'
  _author = 'author'
  _year = 'year'
  _read = 'read'
  _genre = 'genre'
  _table = 'book'
  _owner_id = 'owner_id'
  try:
    if search_for_title == None and genre == None and read == None:
      data = await Db_Book.filter(owner_id=authorization['token']).values()
    elif genre != None:
        try:
          data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_genre} LIKE '%{genre}%' AND {_owner_id} = {authorization['token']}")
        except:
          raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail='None book founded!'
          )
        else:
          return {"books": data}
    elif read != None:
      try:
        data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_read} = {read} AND {_owner_id} = {authorization['token']}")
      except:
        raise HTTPException(
          status_code=status.HTTP_404_NOT_FOUND,
          detail='None book founded!'
        )
      else:
        return {"books": data}
    else:
      data = await Db_Book.raw(f"SELECT {_title}, {_cover}, {_author}, {_year}, {_read}, {_genre} FROM {_table} WHERE {_title} LIKE '{search_for_title}%' and {_owner_id} = {authorization['token']}")
  except:
    raise HTTPException(
      status_code=status.HTTP_404_NOT_FOUND,
      detail='None book founded!'
    )
  else:
    return {"books": data}
  
# @book.get('/genres')
# async def get_book_genre(genre: str, authorization: str = Depends(get_auth)):
#   _genre = 'genre'
#   _table = 'book'
#   _owner_id = 'owner_id'

#   try:
#     data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_genre} LIKE '%{genre}%' AND {_owner_id} = {authorization['token']}")
#   except:
#     raise HTTPException(
#       status_code=status.HTTP_404_NOT_FOUND,
#       detail='None book founded!'
#     )
#   else:
#     return {"books": data}
  
# @book.get('/read')
# async def get_book_genre(read: bool, authorization: str = Depends(get_auth)):
#   _read = 'read'
#   _table = 'book'
#   _owner_id = 'owner_id'

#   try:
#     data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_read} = {read} AND {_owner_id} = {authorization['token']}")
#   except:
#     raise HTTPException(
#       status_code=status.HTTP_404_NOT_FOUND,
#       detail='None book founded!'
#     )
#   else:
#     return {"books": data}

@book.post('/')
async def set_book(title: str,author: str,year: int, read: bool, cover: str | None=None, genre: List[str] = Query(None), authorization: str = Depends(get_auth)):

  if cover == None:
    cover = 'https://iili.io/HrlBU3F.png'

  data = await Db_Book.create(cover=cover, title=title, author=author, year=year, genre=genre, read=read, owner_id=authorization['token'])

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

  print(authorization['token'])
  return {"status": status.HTTP_200_OK}

@book.put('/')
async def put_book(book_id : str, author: str | None=None, year: int | None=None, read: bool | None=None, cover: str | None=None, genre: List[str] = Query(None) ,authorization: str = Depends(get_auth)):
  data = await Db_Book.filter(owner_id=authorization['token']).get(id=book_id)

  Db_author = data.author
  Db_year = data.year
  Db_read = data.read
  Db_cover = data.cover
  Db_genre = data.genre

  if author == None:
    data.author = Db_author
  else:
    data.author = author

  if year == None:
    data.year = Db_year
  else:
    data.year = year

  if read == None:
    data.read = Db_read
  else:
    data.read = read

  if cover == None:
    data.cover = Db_cover
  else:
    data.cover = cover

  if genre == None:
    data.genre = Db_genre
  else:
    data.genre = genre

  await data.save()

  return {"status": status.HTTP_200_OK}

@book.delete('/')
async def delete_book(book_id : str, authorization: str = Depends(get_auth)):
  data = await Db_Book.filter(owner_id=authorization['token']).get(id=book_id)

  await data.delete()

  return {"status": status.HTTP_200_OK}
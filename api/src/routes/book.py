from fastapi import FastAPI, APIRouter, Depends, HTTPException, status, Query
from src.routes.auth import get_auth

from pydantic import BaseModel

from typing import List

from src.models.models import Book as Db_Book
from src.models.models import Author as Db_Author
from src.models.models import Genre as Db_Genre

from src.models.models import Book_Author
from src.models.models import Book_Genre

book = FastAPI()

book = APIRouter(
  prefix='/book',
  tags=['book']
)

@book.get('/')
async def get_book(author: List[str] = Query(), title: str | None=None, genre: str | None=None, read: bool | None=None, authorization: str = Depends(get_auth)):

  _title = 'title'
  _cover = 'cover'
  _author = 'author'
  _year = 'year'
  _read = 'read'
  _genre = 'genre'
  _table = 'book'
  _owner_id = 'owner_id'

  if title == None and genre == None and read == None:
    book = await Db_Book.filter(owner_id=authorization['token']).values()
    Author = await Db_Author.filter(name='George Orwell').all().values()

    # for y in Author:
    #   return y

    # for x in book:
    #   x['author'] = Author[0].name

    return {"tamanho": Author}

  # try:
  #   if title == None and genre == None and read == None:
  #     data = await Db_Book.filter(owner_id=authorization['token']).values()
  #   elif genre != None:
  #       try:
  #         data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_genre} LIKE '%{genre}%' AND {_owner_id} = {authorization['token']}")
  #       except:
  #         raise HTTPException(
  #           status_code=status.HTTP_404_NOT_FOUND,
  #           detail='None book founded!'
  #         )
  #       else:
  #         return {"books": data}
  #   elif read != None:
  #     try:
  #       data = await Db_Book.raw(f"SELECT * FROM {_table} WHERE {_read} = {read} AND {_owner_id} = {authorization['token']}")
  #     except:
  #       raise HTTPException(
  #         status_code=status.HTTP_404_NOT_FOUND,
  #         detail='None book founded!'
  #       )
  #     else:
  #       return {"books": data}
  #   else:
  #     data = await Db_Book.raw(f"SELECT {_title}, {_cover}, {_author}, {_year}, {_read}, {_genre} FROM {_table} WHERE {_title} LIKE '%{title}%' and {_owner_id} = {authorization['token']}")
    # except:
  #   raise HTTPException(
  #     status_code=status.HTTP_404_NOT_FOUND,
  #     detail='None book founded!'
  #   )
  # else:
  #   return {"books": data}

@book.post('/')
async def set_book(title: str, year: int, read: bool, description, author: List[str] = Query(), genre: List[str] = Query(), cover: str | None=None, authorization: str = Depends(get_auth)):

  if cover == None:
    cover = 'https://iili.io/HrlBU3F.png'

  Book = await Db_Book.create(cover=cover, title=title, year=year, read=read, description=description ,owner_id=authorization['token'])

  get_book_id = await Book.filter(owner_id=authorization['token']).only('id')
  book_id = get_book_id[-1].id

  for x in author:
    Author = await Db_Author.create(name=x)
    Book_author = await Book_Author.create(author_id=Author.pk, book_id=book_id)

  # await Book_Author.raw(f"INSERT INTO author (author_id, book_id) VALUES ('eu'), ('aqui')")
  
  # get_author_id = await Author.all().only('id')
  # author_id = get_author_id[-1].id

  for x in genre:
    Genre = await Db_Genre.create(name=x)
  
  get_genre_book_id = await Genre.all().only('id')
  genre_id = get_genre_book_id[-1].id

  Genre_book = await Book_Genre.create(book_id=book_id, genre_id=genre_id)

  if title == None or len(title) < 3:
    raise HTTPException(
      detail='Title must be at least 3 characters!',
      status_code=status.HTTP_400_BAD_REQUEST
    )
  
  if read == None:
    raise HTTPException(
      detail="Read can't be None!",
      status_code=status.HTTP_400_BAD_REQUEST
    )
  
  if year == None:
    raise HTTPException(
      detail='Year must be at least 2 numbers!',
      status_code=status.HTTP_400_BAD_REQUEST
    )

  await Book.save()
  await Author.save()
  await Book_author.save()
  await Genre_book.save()

  return {"status": status.HTTP_200_OK, "get_book_id": book_id, "author_id": "Author.pk"}

@book.put('/')
async def put_book(book_id : str, author: str | None=None, year: int | None=None, read: bool | None=None, cover: str | None=None, genre: List[str] = Query(None) ,authorization: str = Depends(get_auth)):

  pass

@book.delete('/')
async def delete_book(book_id : str, authorization: str = Depends(get_auth)):
  data = await Db_Book.filter(owner_id=authorization['token']).get(id=book_id)

  await data.delete()

  return {"status": status.HTTP_200_OK}
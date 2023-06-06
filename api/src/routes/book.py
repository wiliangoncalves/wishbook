from fastapi import FastAPI, APIRouter, Depends, HTTPException, status, Query
from src.routes.auth import get_auth

from typing import List

from src.models.models import Book as Db_Book
from src.models.models import Author as Db_Author

from src.models.models import Book_Author

book = FastAPI()

book = APIRouter(
  prefix='/book',
  tags=['book']
)

@book.get('/')
async def get_book(read: bool, title: str | None=None, genre: List[str] = Query(None), authorization: str = Depends(get_auth)):
  book = await Db_Book.filter(owner_id=authorization['token']).values()

  books = await Db_Book.all().filter(owner_id=authorization['token']).prefetch_related('book_authors__author')
  result = []
  for book in books:
    authors_id = [book_author.author.id for book_author in book.book_authors]
    authors = [book_author.author.author for book_author in book.book_authors]
    result.append({
      'title': book.title,
      'books_id': book.id,
      'authors': authors,
      'authors_id': authors_id
    })

  if title != None:
    books = await Db_Book.all().filter(title__contains=title, owner_id=authorization['token']).prefetch_related('book_authors__author')
    result = []
    for book in books:
      authors_id = [book_author.author.id for book_author in book.book_authors]
      authors = [book_author.author.author for book_author in book.book_authors]
      result.append({
        'title': book.title,
        'books_id': book.id,
        'authors': authors,
        'authors_id': authors_id
      })

    return {"book_found": result}
  
  if read == True:
    books = await Db_Book.all().filter(read=True, owner_id=authorization['token']).prefetch_related('book_authors__author')
    result = []
    for book in books:
      authors_id = [book_author.author.id for book_author in book.book_authors]
      authors = [book_author.author.author for book_author in book.book_authors]
      result.append({
        'title': book.title,
        'books_id': book.id,
        'authors': authors,
        'authors_id': authors_id
      })

    return {"book_found": result}

  return {"data": result}

@book.post('/')
async def set_book(title: str, year: int, read: bool, description, author: List[str] = Query(), genre: List[str] = Query(), cover: str | None=None, authorization: str = Depends(get_auth)):

  if cover == None:
    cover = 'https://iili.io/HrlBU3F.png'

  Book = await Db_Book.create(cover=cover, title=title, year=year, read=read, description=description, genre=genre, owner_id=authorization['token'])

  get_book_id = await Book.filter(owner_id=authorization['token']).only('id')
  book_id = get_book_id[-1].id

  for x in author:
    Author = await Db_Author.create(author=x)
    Book_author = await Book_Author.create(author_id=Author.pk, book_id=book_id)

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

  return {"status": status.HTTP_200_OK}

@book.put('/')
async def put_book(
  book_id : int, 
  title: str | None=None, 
  author_id: int | None=None,
  new_author: str | None=None,
  year: int | None=None, 
  read: bool | None=None, 
  cover: str | None=None, 
  genre: List[str] = Query(None),
  authorization: str = Depends(get_auth)
):
  data = await Db_Book.filter(owner_id=authorization['token']).get(id=book_id)

  Db_title = data.title
  Db_year = data.year
  Db_read = data.read
  Db_cover = data.cover

  if title == None:
    data.title = Db_title
  else:
    data.title = title

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

  await data.save()

  return {"status": status.HTTP_200_OK}

@book.delete('/')
async def delete_book(book_id : int, authorization: str = Depends(get_auth)):
  data = await Db_Book.filter(owner_id=authorization['token']).get(id=book_id)

  await data.delete()

  return {"status": status.HTTP_200_OK}
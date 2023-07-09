from tortoise import Model, fields

class User(Model):
    id = fields.IntField(pk = True, index = True,  AUTO_INCREMENT = True)
    avatar = fields.CharField(max_length=255, null = False, default='https://i.ibb.co/MPGG9nn/avatar.jpg')
    firstname = fields.CharField(max_length=50, null = False)
    lastname = fields.CharField(max_length=50, null = False)
    email = fields.CharField(max_length=200, null = False, unique = True)
    password = fields.CharField(max_length=255, null = False)
    activate_link = fields.CharField(max_length=64)
    is_verified = fields.BooleanField(default=False, null=False)

class Book(Model):
    id = fields.IntField(pk = True, index = True, AUTO_INCREMENT = True)
    title = fields.CharField(max_length=255, null = False)
    year = fields.IntField(null = False)
    read = fields.BooleanField(default=False)
    cover = fields.CharField(max_length=255, default='https://iili.io/HrlBU3F.png')
    description = fields.CharField(max_length=255, null = False)
    genre = fields.CharField(max_length=255, null = False)
    owner = fields.ForeignKeyField("models.User", related_name="owner_book")

class Book_Author(Model):
    book = fields.ForeignKeyField("models.Book", related_name="book_authors")
    author = fields.ForeignKeyField("models.Author", related_name="author_books")

class Author(Model):
    id = fields.IntField(pk = True, index = True, AUTO_INCREMENT = True)
    author = fields.CharField(max_length=255, null = False)
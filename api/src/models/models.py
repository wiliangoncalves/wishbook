from tortoise import Model, fields
from tortoise.contrib.pydantic import pydantic_model_creator

class User(Model):
    id = fields.IntField(pk = True, index = True,  AUTO_INCREMENT = True)
    avatar = fields.CharField(max_length=255, default='https://i.ibb.co/MPGG9nn/avatar.jpg')
    firstname = fields.CharField(max_length=50, null = False)
    lastname = fields.CharField(max_length=50, null = False)
    email = fields.CharField(max_length=200, null = False, unique = True)
    password = fields.CharField(max_length=255, null = False)
    is_verified = fields.BooleanField(default=False)

class Book(Model):
    id = fields.IntField(pk = True, index = True, AUTO_INCREMENT = True)
    title = fields.CharField(max_length=255, null = False)
    author = fields.CharField(max_length=255, null = False)
    year = fields.IntField(null = False)
    genre = fields.TextField()
    read = fields.BooleanField(default=False)
    cover = fields.CharField(max_length=255, default='https://iili.io/HrlBU3F.png')
    owner = fields.ForeignKeyField("models.User", related_name="Book")

class Collection(Model):
    id = fields.IntField(pk = True, index = True, AUTO_INCREMENT = True)
    owner = fields.ForeignKeyField("models.User", related_name="Collection")
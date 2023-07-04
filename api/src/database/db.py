from main import app

from tortoise import Tortoise

from tortoise.contrib.fastapi import register_tortoise

import os
from dotenv import load_dotenv
load_dotenv()
USER = os.getenv('USER')
HOST = os.getenv('HOST')
DATABASE = os.getenv('DATABASE')
PASSWORD = os.getenv('PASSWORD')

Tortoise.init_models(["src.models.models"], "models")
async def init():
    await Tortoise.init(
        db_url='postgres://{USER}:{PASSWORD}@{HOST}:5432/{DATABASE}',
        modules={"models": ["src.models.models"]},
    )

register_tortoise(
    app,
    db_url=f"postgres://{os.getenv('ROOT')}:{os.getenv('PASSWORD')}@{os.getenv('HOST')}:5432/{os.getenv('DATABASE')}",
    modules={"models": ["src.models.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)
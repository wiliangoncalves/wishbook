from main import app

from tortoise import Tortoise

from tortoise.contrib.fastapi import register_tortoise

from decouple import config
ROOT = config('ROOT')
HOST = config('HOST')
DATABASE = config('DATABASE')
PASSWORD = config('PASSWORD')

Tortoise.init_models(["src.models.models"], "models")
async def init():
    await Tortoise.init(
        db_url='postgres://{ROOT}:{PASSWORD}@{HOST}:5432/{DATABASE}',
        modules={"models": ["src.models.models"]},
    )

register_tortoise(
    app,
    db_url='postgres://wile:wile9090@localhost:5432/wishbook',
    modules={"models": ["src.models.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)
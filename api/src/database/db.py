from main import app
from tortoise import Tortoise
from tortoise.contrib.fastapi import register_tortoise
import os
from dotenv import load_dotenv

load_dotenv()

SPACE_USER_DB = os.getenv('SPACE_USER_DB')
SPACE_HOST_DB = os.getenv('SPACE_HOST_DB')
SPACE_DATABASE_DB = os.getenv('SPACE_DATABASE_DB')
SPACE_PASSWORD_DB = os.getenv('SPACE_PASSWORD_DB')

async def init():
    await Tortoise.init(
        db_url=f"postgres://{SPACE_USER_DB}:{SPACE_PASSWORD_DB}@{SPACE_HOST_DB}:5432/{SPACE_DATABASE_DB}",
        modules={"models": ["src.models.models"]},
    )

async def startup():
    await init()

register_tortoise(
    app,
    db_url=f"postgres://{SPACE_USER_DB}:{SPACE_PASSWORD_DB}@{SPACE_HOST_DB}:5432/{SPACE_DATABASE_DB}",
    modules={"models": ["src.models.models"]},
    generate_schemas=True,
    add_exception_handlers=True,
)


# from main import app

# from tortoise import Tortoise

# from tortoise.contrib.fastapi import register_tortoise

# import os
# from dotenv import load_dotenv
# load_dotenv()
# USER = os.getenv('USER')
# HOST = os.getenv('HOST')
# DATABASE = os.getenv('DATABASE')
# PASSWORD = os.getenv('PASSWORD')

# Tortoise.init_models(["src.models.models"], "models")
# async def init():
#     await Tortoise.init(
#         db_url='postgres://{USER}:{PASSWORD}@{HOST}:5432/{DATABASE}',
#         modules={"models": ["src.models.models"]},
#     )

# register_tortoise(
#     app,
#     db_url=f"postgres://{os.getenv('ROOT')}:{os.getenv('PASSWORD')}@{os.getenv('HOST')}:5432/{os.getenv('DATABASE')}",
#     modules={"models": ["src.models.models"]},
#     generate_schemas=True,
#     add_exception_handlers=True,
# )
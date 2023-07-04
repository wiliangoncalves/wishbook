from fastapi import FastAPI
from tortoise.contrib.fastapi import register_tortoise
from tortoise import Tortoise
import os
from dotenv import load_dotenv

load_dotenv()

USER = os.getenv('USER')
HOST = os.getenv('HOST')
DATABASE = os.getenv('DATABASE')
PASSWORD = os.getenv('PASSWORD')
PORT = os.getenv('PORT')

# Crie uma instância do aplicativo FastAPI
app = FastAPI()

# Defina as configurações do banco de dados
db_url = f"postgres://{USER}:{PASSWORD}@{HOST}/{DATABASE}"
db_config = {
    "connections": {"default": db_url},
    "apps": {
        "models": {
            "models": ["src.models.models"],
            "default_connection": "default",
        },
    },
}

# Inicialize o Tortoise ORM e gere os esquemas
async def init_db():
    await Tortoise.init(config=db_config)
    await Tortoise.generate_schemas()

# Adicione o evento de inicialização do aplicativo para inicializar o banco de dados
@app.on_event("startup")
async def startup_event():
    await init_db()

# Registre as rotas do Tortoise ORM com o FastAPI
register_tortoise(
    app,
    config=db_config,
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
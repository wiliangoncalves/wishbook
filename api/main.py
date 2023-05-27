from fastapi import FastAPI

app = FastAPI()

from src.database.database import register_tortoise

from src.routes.login import login
from src.routes.register import register
from src.routes.profile import profile

@app.on_event("startup")
async def tortoise_register():
    register_tortoise

app.include_router(login)
app.include_router(register)
app.include_router(profile)
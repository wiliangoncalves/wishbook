from fastapi import FastAPI
import uvicorn

from src.routes.login import login as login_router
from src.routes.register import register as register_router
from src.routes.profile import profile as profile_router
from src.routes.book import book as book_router
from src.routes.activate_email import activate_email as activate_email_router

import os
from dotenv import load_dotenv
load_dotenv()
YOUR_IP = os.getenv('YOUR_IP')

SPACE_USER_DB = os.getenv('SPACE_USER_DB')
SPACE_HOST_DB = os.getenv('SPACE_HOST_DB')
SPACE_DATABASE_DB = os.getenv('SPACE_DATABASE_DB')
SPACE_PASSWORD_DB = os.getenv('SPACE_PASSWORD_DB')

app = FastAPI()

from src.database.db import register_tortoise

@app.on_event("startup")
async def startup_event():
    register_tortoise(
        app,
        db_url=f"postgres://{SPACE_USER_DB}:{SPACE_PASSWORD_DB}@{SPACE_HOST_DB}:5432/{SPACE_DATABASE_DB}",
        modules={"models": ["src.models.models"]},
        generate_schemas=True,
        add_exception_handlers=True,
    )

app.include_router(login_router)
app.include_router(register_router)
app.include_router(profile_router)
app.include_router(book_router)
app.include_router(activate_email_router)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

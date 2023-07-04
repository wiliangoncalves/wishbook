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

app = FastAPI()

app.include_router(login_router)
app.include_router(register_router)
app.include_router(profile_router)
app.include_router(book_router)
app.include_router(activate_email_router)

if __name__ == "__main__":
    from src.database.db import register_tortoise

    @app.on_event("startup")
    async def startup_event():
        await register_tortoise()

    # uvicorn.run("main:app", host=YOUR_IP ,port=10000, log_level="info")

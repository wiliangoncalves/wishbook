from fastapi import FastAPI, APIRouter, status, HTTPException

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from jinja2 import Environment, FileSystemLoader

from src.models.models import User as Db_User

import os
from dotenv import load_dotenv
load_dotenv()
SENDER_EMAIL = os.getenv('SENDER_EMAIL')
SMTP_USERNAME = os.getenv('SMTP_USERNAME')
SMTP_PASSWORD = os.getenv('SMTP_PASSWORD')
ACTIVATION_LINK = os.getenv('ACTIVATION_LINK')

activate_email = FastAPI()

activate_email = APIRouter(
    prefix='/activate_email',
    tags=['activate_email']
)

async def send_activation_email(receiver, username, activation_link):
    smtp_server = 'smtp.gmail.com'
    smtp_port = 587
    smtp_username = SMTP_USERNAME
    smtp_password = SMTP_PASSWORD

    # Carrega o template
    env = Environment(loader=FileSystemLoader('src/template'))
    template = env.get_template('activation_email_template.html')

    # Renderiza o template com os valores fornecidos
    html_content = template.render(username=username, activation_link=ACTIVATION_LINK+activation_link)

    msg = MIMEMultipart('alternative')
    msg['Subject'] = 'Please verify, your WishBook account'
    msg['From'] = SENDER_EMAIL
    msg['To'] = receiver

    # Adiciona a parte HTML ao e-mail
    html_part = MIMEText(html_content, 'html')
    msg.attach(html_part)

    server = smtplib.SMTP(smtp_server, smtp_port)
    server.starttls()
    server.login(smtp_username, smtp_password)
    server.sendmail(SENDER_EMAIL, [receiver], msg.as_string())
    server.quit()

@activate_email.get('/')
async def get_activate_email(activate_link: str):
    try:
        data = await Db_User.get(activate_link=activate_link)
    except:
        raise HTTPException(
            detail="Invalid validation link",
            status_code=status.HTTP_401_UNAUTHORIZED
        )
    else:
        data.is_verified = True
        await data.save()
        return {
            "status": status.HTTP_200_OK,
            "message": "successfully activated user",
        }
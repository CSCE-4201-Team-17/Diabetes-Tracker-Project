import os
import boto3
from boto3.dynamodb.conditions import Key
import uuid
import bcrypt


#Connects to DynamoDB using .env credentials
dynamodb = boto3.resource(
    "dynamodb",
    region_name=os.getenv("AWS_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
)

#Reference the table we created
GLUCOSE_TABLE = dynamodb.Table("GlucoseReadings")


def save_glucose_reading(user_id: str, reading: dict):
    """
    Save a single glucose reading for a user.
    """
    item = {
        "userId": user_id,
        "timestamp": reading["timestamp"],   
        "value": reading["value"],
        "type": reading["type"],
    }

    if reading.get("notes"):
        item["notes"] = reading["notes"]

    GLUCOSE_TABLE.put_item(Item=item)


def get_glucose_readings(user_id: str):
    """
    Return all glucose readings for a user.
    """
    resp = GLUCOSE_TABLE.query(
        KeyConditionExpression=Key("userId").eq(user_id)
    )
    return resp.get("Items", [])

#Meals table
MEALS_TABLE = dynamodb.Table("Meals")


def save_meal(user_id: str, timestamp: str, image_url: str, extra_data: dict = None):
    """
    Save a meal entry (image upload event) to DynamoDB.
    This is called right after user uploads a meal photo.
    """
    item = {
        "userId": user_id,
        "timestamp": timestamp,
        "image_url": image_url,
    }

    #Adds AI results or filename/status if provided
    if extra_data:
        item.update(extra_data)

    MEALS_TABLE.put_item(Item=item)


def get_meals_for_user(user_id: str):
    """Retrieve all meals for a user."""
    resp = MEALS_TABLE.query(
        KeyConditionExpression=Key("userId").eq(user_id)
    )
    return resp.get("Items", [])

dynamodb = boto3.resource(
    "dynamodb",
    region_name=os.getenv("AWS_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY")
)

USERS_TABLE = dynamodb.Table("Users")

def create_user(email, password, name):
    hashed_pw = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
    user_id = str(uuid.uuid4())

    USERS_TABLE.put_item(Item={
    "email": email,
    "userId": user_id,
    "name": name,
    "password_hash": hashed_pw
})


    return user_id




def get_user(email):
    resp = USERS_TABLE.get_item(Key={"email": email})
    return resp.get("Item")


def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode(), hashed.encode())
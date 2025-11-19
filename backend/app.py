from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
from groq import Groq
import os
import boto3
import uuid
from werkzeug.utils import secure_filename
load_dotenv()
import time
from flask import Flask, request, jsonify

app = Flask(__name__)
CORS(app)

# In-memory storage for readings (no DB yet)
# { "userId": [ { value, timestamp, type, notes }, ... ] }
readings = {}

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
client = Groq(api_key=GROQ_API_KEY) 
 
S3_BUCKET= os.getenv("S3_BUCKET")
AWS_REGION = os.getenv("AWS_REGION")

#initialize aws S3 client
s3 = boto3.client(
    "s3",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    region_name=os.getenv("AWS_REGION"),
)



@app.post("/api/glucose")
def add_glucose():
    data = request.json
    user_id = data.get("userId")

    if not user_id:
        return jsonify({"error": "Missing userId"}), 400

    reading = {
        "value": data["value"],
        "timestamp": data["timestamp"],
        "type": data["type"],
        "notes": data.get("notes"),
    }

    if user_id not in readings:
        readings[user_id] = []

    readings[user_id].append(reading)
    print(f"Added reading for {user_id}: {reading}")
    return jsonify({"success": True}), 201




@app.post("/api/upload")
def upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}),400
    
    file = request.files['file']

    if file.filename == "":
        return jsonify({"error": "No selected file"}), 400
    
    #generate a unique filename 
    filename = f"{uuid.uuid4().hex}_{secure_filename(file.filename)}"

    try:
        s3.upload_fileobj(
            file,
            BUCKET_NAME,
            filename,
            ExtraArgs={"ContentType": file.content_type}
        )

        file_url = f"https://{BUCKET_NAME}.s3.{os.getenv('AWS_REGION')}.amazonaws.com/{filename}"

        return jsonify( {
            "message":"File uploaded successfully",
            "url": file_url
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Get user readings
@app.get("/api/users/<user_id>/glucose")
def get_user_glucose(user_id):
    print(f"Get readings for {user_id}")
    return jsonify(readings.get(user_id, [])), 200


# AI Chat Assistant
@app.post("/api/ai/chat")
def ai_chat():
    global client
    print("AI endpoint HIT")
    data = request.json
    user_id = data.get("userId")
    message = data.get("message")

    # Get readings & meds sent from Flutter
    readings_from_frontend = data.get("readings") or []
    meds_from_frontend = data.get("medications") or []

    print(f"Received {len(readings_from_frontend)} readings from frontend")
    print(f"Received {len(meds_from_frontend)} medications from frontend")

    # Format readings into text for the model
    if readings_from_frontend:
        readings_text = "\n".join(
            f"- {r.get('timestamp', 'unknown time')}: "
            f"{r.get('value', '?')} mg/dL ({r.get('type', 'unknown type')})"
            for r in readings_from_frontend
        )
    else:
        readings_text = "No readings available."

    # Format meds into text for the model
    if meds_from_frontend:
        meds_text = "\n".join(
            f"- {m.get('name', 'Unknown med')} {m.get('dosage', '')} "
            f"at {m.get('hour', 0):02d}:{m.get('minute', 0):02d}"
            for m in meds_from_frontend
        )
    else:
        meds_text = "No medications recorded."

    prompt = f"""
You are a friendly diabetes assistant for ONE user.

You are given:
1) Their recent blood sugar readings
2) Their current medications
3) Their question

Your job:
- Describe patterns in THEIR data only.
- Mention if values are generally low, in range, or high.
- If trends look like they are rising or falling, say that.
- Explain in simple language.
- Do NOT give medical advice or dosage changes.
- Encourage them to talk to their doctor for decisions.

--- USER DATA START ---

Recent glucose readings:
{readings_text}

Current medications:
{meds_text}

--- USER DATA END ---

User question:
{message}
"""

    try:
        response = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful, friendly diabetes assistant. You never give medical advice.",
                },
                {"role": "user", "content": prompt},
            ],
        )

        reply = response.choices[0].message.content
        print("Groq reply (first 200 chars):", reply[:200])
        return jsonify({"reply": reply}), 200

    except Exception as e:
        print("Groq API error:", e)
        return jsonify({"error": "AI service unavailable"}), 500
    
@app.route("/api/upload_meal", methods=["POST"])
def upload_meal():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image = request.files["image"]

    # Make a unique file name for S3
    filename = f"meal_{int(time.time())}.jpg"

    try:
        s3.upload_fileobj(
            image,
            S3_BUCKET,
            filename,
            ExtraArgs={"ContentType": image.content_type}
        )

        # Build the public image URL
        s3.upload_fileobj(image, S3_BUCKET, filename)
        image_url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{filename}"

        return jsonify({"image_url": image_url}), 200

    except Exception as e:
        print("S3 Upload Error:", e)
        return jsonify({"error": "S3 upload failed"}), 500
 


if __name__ == "__main__":
    # NOTE: port 6000 to match what you're already running
    app.run(host="0.0.0.0", port=5001, debug=True)

from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
load_dotenv()
from groq import Groq
import os
from datetime import datetime
from flask import request, jsonify


import boto3
import uuid
from werkzeug.utils import secure_filename

import time
from flask import Flask, request, jsonify
print("AWS KEY:", os.getenv("AWS_ACCESS_KEY_ID"))


from database import save_glucose_reading, get_glucose_readings
from database import save_meal
from datetime import datetime
import time 

from database import create_user, get_user, verify_password


app = Flask(__name__)
CORS(app)


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
    data = request.json or {}
    user_id = data.get("userId")

    if not user_id:
        return jsonify({"error": "Missing userId"}), 400

    required_fields = ["value", "timestamp", "type"]
    for f in required_fields:
        if f not in data:
            return jsonify({"error": f"Missing field: {f}"}), 400

    reading = {
        "value": data["value"],
        "timestamp": data["timestamp"],
        "type": data["type"],
        "notes": data.get("notes"),
    }

    save_glucose_reading(user_id, reading)

    print(f"[DynamoDB] Added reading for {user_id}: {reading}")
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

#Get user readings
@app.get("/api/users/<user_id>/glucose")
def get_user_glucose(user_id):
    items = get_glucose_readings(user_id)
    return jsonify(items), 200


def compute_future_predictions(readings):
    """
    readings: list of dicts with keys: value (number), timestamp (ISO string)
    Returns a list of (label, predicted_value) using simple linear regression
    over time in DAYS since the first reading.

    It predicts roughly 1, 2, and 3 weeks into the future.
    """
    if not readings or len(readings) < 2:
        return []

    #Parse timestamps safely
    parsed = []
    for r in readings:
        try:
            ts = datetime.fromisoformat(r.get("timestamp"))
            val = float(r.get("value", 0))
            parsed.append((ts, val))
        except Exception:
            continue

    if len(parsed) < 2:
        return []

    #Sort by time and compute x = days since first reading
    parsed.sort(key=lambda x: x[0])
    t0 = parsed[0][0]
    xs = [(t - t0).total_seconds() / 86400.0 for (t, _) in parsed]  # days
    ys = [v for (_, v) in parsed]

    n = len(xs)
    mean_x = sum(xs) / n
    mean_y = sum(ys) / n

    num = 0.0
    den = 0.0
    for i in range(n):
        num += (xs[i] - mean_x) * (ys[i] - mean_y)
        den += (xs[i] - mean_x) ** 2
    if den == 0:
        den = 1e-6

    slope = num / den
    intercept = mean_y - slope * mean_x

    last_x = xs[-1]

    future_points = [
        ("In about 1 week", last_x + 7),
        ("In about 2 weeks", last_x + 14),
        ("In about 3 weeks", last_x + 21),
    ]

    predictions = []
    for label, future_x in future_points:
        y_pred = slope * future_x + intercept
        predictions.append((label, round(y_pred)))

    return predictions


@app.post("/api/glucose/predict")
def predict_glucose():
    data = request.json
    readings = data.get("readings", [])
    hours_ahead = data.get("hoursAhead", 2)

    if len(readings) < 3:
        return jsonify({
            "prediction": None,
            "message": "Not enough data to predict yet. Log more readings."
        }), 200

    #convert to (t, value) where t = hours since first reading
    parsed = []
    for r in readings:
        ts = datetime.fromisoformat(r["timestamp"])
        parsed.append((ts, r["value"]))

    #sort by time
    parsed.sort(key=lambda x: x[0])
    t0 = parsed[0][0]

    xs = [(t - t0).total_seconds() / 3600.0 for (t, _) in parsed]
    ys = [v for (_, v) in parsed]

    #simple linear regression: y = a*x + b
    n = len(xs)
    mean_x = sum(xs) / n
    mean_y = sum(ys) / n
    num = sum((xs[i] - mean_x) * (ys[i] - mean_y) for i in range(n))
    den = sum((xs[i] - mean_x) ** 2 for i in range(n)) or 1e-6
    a = num / den
    b = mean_y - a * mean_x

    #predict future point
    last_t = xs[-1]
    future_t = last_t + hours_ahead
    pred_value = a * future_t + b

    return jsonify({
        "prediction": round(pred_value),
        "hoursAhead": hours_ahead,
        "trend": "rising" if a > 0 else "falling" if a < 0 else "flat",
        "message": (
            f"If your recent trend continues, your glucose in about "
            f"{hours_ahead} hours might be around {round(pred_value)} mg/dL. "
            "This is only an estimate for learning, not medical advice."
        )
    }), 200

#AI Chat Assistant
@app.post("/api/ai/chat")
def ai_chat():
    global client
    print("AI endpoint HIT")
    data = request.json or {}

    message = data.get("message", "")
    user_id = data.get("userId")

    #Read readings + meds passed from Flutter
    readings_from_frontend = data.get("readings") or []
    meds_from_frontend = data.get("medications") or []

    print(f"message: {message}")
    print(f"user_id: {user_id}")
    print(f"{len(readings_from_frontend)} readings, {len(meds_from_frontend)} meds")

    #Format readings into text
    if readings_from_frontend:
        readings_text = "\n".join(
            f"- {r.get('timestamp', 'unknown time')}: "
            f"{r.get('value', '?')} mg/dL ({r.get('type', 'unknown type')})"
            for r in readings_from_frontend
        )
    else:
        readings_text = "No readings available."

    #Format medications into text
    if meds_from_frontend:
        meds_text = "\n".join(
            f"- {m.get('name', 'Unknown med')} {m.get('dosage', '')} "
            f"at {m.get('hour', 0):02d}:{m.get('minute', 0):02d}"
            for m in meds_from_frontend
        )
    else:
        meds_text = "No medications recorded."

    #numeric future estimates (simple linear trend)
    predictions = compute_future_predictions(readings_from_frontend)
    if predictions:
        predictions_lines = "\n".join(
            f"- {label}: about {value} mg/dL"
            for (label, value) in predictions
        )
        predictions_text = (
            "Rough linear-trend estimates (for learning only, NOT medical advice):\n"
            f"{predictions_lines}"
        )
    else:
        predictions_text = (
            "Not enough data yet to estimate future levels. "
            "Try logging more readings over time."
        )

    #Build prompt for the LLM
    prompt = f"""
You are a friendly diabetes assistant. You help users understand their blood sugar trends.

You are given:
1) Their recent glucose readings
2) Their medications
3) Some simple linear-trend numeric estimates calculated by the app
4) The user's question

Your goals:
- Describe the current pattern (low / in-range / high, rising / falling / stable).
- Explain what *could* happen in the next days/weeks if this trend continued, using the estimates.
- Clearly say that this is only an estimate for learning, not medical advice.
- Encourage the user to talk to a doctor for any medical decisions.
- Keep the language simple and supportive.

--- USER DATA START ---

Recent glucose readings:
{readings_text}

Current medications:
{meds_text}

App-calculated rough future estimates:
{predictions_text}

--- USER DATA END ---

User question:
{message}
"""

    try:
        #Using existing Groq client here
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",  
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful, friendly diabetes assistant. You never give medical advice or change medication doses.",
                },
                {"role": "user", "content": prompt},
            ],
        )

        ai_reply = completion.choices[0].message.content

        if predictions:
            ai_reply += (
                "\n\nHere are rough numeric estimates based on your recent trend "
                "(for learning only, NOT medical advice):\n"
            )
            for (label, value) in predictions:
                ai_reply += f"- {label}: about {value} mg/dL\n"

        return jsonify({"reply": ai_reply}), 200

    except Exception as e:
        print("AI / Groq error:", e)
        return jsonify({"error": "AI service unavailable"}), 500
    
@app.route("/api/upload_meal", methods=["POST"])
def upload_meal():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image = request.files["image"] 

    #User passes userId (later Cognito will supply it automatically)
    user_id = request.form.get("userId") or request.args.get("userId")

    if not user_id:
        return jsonify({"error": "Missing userId"}), 400

    #Create unique S3 filename
    timestamp = datetime.utcnow().isoformat()
    filename = f"{user_id}_meal_{int(time.time())}.jpg"

    try:
        #Upload to S3
        s3.upload_fileobj(
            image,
            S3_BUCKET,
            filename,
            ExtraArgs={"ContentType": image.content_type}
        )

        #Public URL
        image_url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{filename}"

        #Saves in DynamoDB
        save_meal(
            user_id=user_id,
            timestamp=timestamp,
            image_url=image_url,
            extra_data={
                "filename": filename,
                "status": "uploaded"  #Lambda changes later to 'processed'
            }
        )

        return jsonify({
            "image_url": image_url,
            "filename": filename
        }), 200

    except Exception as e:
        print("S3 Upload Error:", e)
        return jsonify({"error": "S3 upload failed"}), 500
 

@app.post("/api/auth/register")
def register():
    data = request.json or {}
    email = data.get("email")
    password = data.get("password")
    name = data.get("name")  

    if not email or not password or not name:
        return jsonify({"error": "Missing required fields"}), 400

    # Check if user already exists
    existing = get_user(email)
    if existing:
        return jsonify({"error": "User already exists"}), 400

    # Create user in DynamoDB
    user_id = create_user(email, password, name)

    return jsonify({
        "success": True,
        "user": {
            "id": user_id,
            "email": email,
            "name": name
        }
    }), 201

@app.post("/api/auth/login")
def login():
    data = request.json or {}
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Missing email or password"}), 400

    user = get_user(email)
    if not user:
        return jsonify({"error": "Invalid email or password"}), 401

    if not verify_password(password, user["password_hash"]):
        return jsonify({"error": "Invalid email or password"}), 401

    return jsonify({
        "success": True,
        "user": {
            "id": user["userId"],
            "email": user["email"],
            "name": user.get("name", "")    
        }
    }), 200




if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
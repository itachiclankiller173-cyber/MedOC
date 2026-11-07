from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os
import uuid
from ai_engine import analyze_burn_image
from ai_engine import generate_health_response
from pydantic import BaseModel
from models.gait_model import analyze_gait as run_gait_analysis

# ==========================================================
# MEDOC ECG LIVE DATA
# ==========================================================

latest_vitals = {}

latest_ecg = {
    "device_id": "medoc_esp32",
    "sampling_rate": 250,
    "leads_connected": False,
    "samples": [],
    "received_at": None,
}


class ECGSamplesRequest(BaseModel):
    device_id: str = "medoc_esp32"
    sampling_rate: int = 250
    leads_connected: bool = False
    samples: list[int]

app = FastAPI(
    title="MEDOC AI Backend",
    description="AI backend for Gait Analysis, FootCheck and Burn Assessment",
    version="1.0.0",
)

# Allow Flutter/web applications to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads folder
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@app.get("/")
def home():
    return {
        "message": "MEDOC AI Backend is running",
        "status": "online",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": "MEDOC AI Backend",
    }


async def save_upload_file(upload_file: UploadFile):
    """
    Save uploaded image or video temporarily.
    """

    file_extension = os.path.splitext(
        upload_file.filename or ""
    )[1]

    file_name = f"{uuid.uuid4()}{file_extension}"

    file_path = os.path.join(
        UPLOAD_FOLDER,
        file_name,
    )

    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(
                upload_file.file,
                buffer,
            )

        return file_path

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Could not save uploaded file: {str(e)}",
        )


# ==========================================================
# MEDOC AI CHAT — GEMINI INTEGRATION
# ==========================================================

class ChatRequest(BaseModel):
    message: str
    language: str = "English"


@app.post("/chat")
async def chat(request: ChatRequest):
    message = request.message.strip()

    if not message:
        raise HTTPException(
            status_code=400,
            detail="Please enter a message.",
        )

    try:
        reply = generate_health_response(
            message=message,
            language=request.language,
        )

        return {
            "success": True,
            "reply": reply,
        }

    except Exception:
        raise HTTPException(
            status_code=502,
            detail="MedOC AI could not generate a response. Please try again.",
        )
# ==========================================================
# GAIT ANALYSIS
# ==========================================================
# ==========================================================
# GAIT ANALYSIS
# ==========================================================

@app.post("/analyze-gait")
async def analyze_gait_endpoint(
    video: UploadFile = File(...),
):
    file_path = await save_upload_file(video)

    try:
        # Run MediaPipe gait AI
        result = run_gait_analysis(file_path)

        return result

    finally:
        if os.path.exists(file_path):
            os.remove(file_path)# ==========================================================
# FOOTCHECK
# ==========================================================

@app.post("/analyze-foot")
async def analyze_foot(
    image: UploadFile = File(...),
):
    """
    Receives a foot image.
    Later this endpoint will connect to:
    TensorFlow / PyTorch foot analysis model.
    """

    file_path = await save_upload_file(image)

    try:
        # --------------------------------------------------
        # AI PROCESSING WILL BE CONNECTED HERE
        # --------------------------------------------------

        result = {
            "success": True,
            "analysis_type": "footcheck",
            "message": "Foot image analysis completed",

            "results": {
                "skin_condition": "Analysis pending",
                "visible_abnormality": "Analysis pending",
                "swelling_indicator": "Analysis pending",
                "color_change": "Analysis pending",
            },

            "risk_level": "Unknown",

            "disclaimer": (
                "Image analysis is not a medical diagnosis. "
                "Please consult a healthcare professional "
                "for proper evaluation."
            ),
        }

        return result

    finally:
        if os.path.exists(file_path):
            os.remove(file_path)


# ==========================================================
# BURN ASSESSMENT — GEMINI IMAGE ANALYSIS
# ==========================================================

import json


@app.post("/analyze-burn")
async def analyze_burn(image: UploadFile = File(...)):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Please upload a valid image.",
        )

    file_path = await save_upload_file(image)

    try:
        try:
            raw_result = analyze_burn_image(
                image_path=file_path,
                mime_type=image.content_type,
            )

            # Parse the JSON returned by Gemini.
            cleaned_result = raw_result.strip()

            if cleaned_result.startswith("```"):
                cleaned_result = cleaned_result.replace(
                    "```json", ""
                ).replace("```", "").strip()

            result = json.loads(cleaned_result)

            return {
                "success": True,
                "analysis_type": "burn_assessment",
                "results": result,
                "disclaimer": (
                    "AI image analysis is not a medical diagnosis. "
                    "A photograph cannot reliably establish burn depth "
                    "or severity. Seek professional medical care."
                ),
            }

        except Exception:
            raise HTTPException(
                status_code=502,
                detail=(
                    "Burn image analysis failed. Check the Gemini "
                    "API key, model availability, and backend logs."
                ),
            )

    finally:
        if os.path.exists(file_path):
            os.remove(file_path)
# ==========================================================
# MEDOC ESP32 SENSOR DATA API
# ==========================================================

from datetime import datetime, timezone
from typing import Optional


# ==========================================================
# MEDOC ECG LIVE WAVEFORM STORAGE
# ==========================================================

# Latest sensor readings
latest_vitals = {}

# Latest ECG sample batch
latest_ecg = {}


class EcgSamplesRequest(BaseModel):
    device_id: str = "medoc_esp32"
    sampling_rate: int = 250
    leads_connected: bool = False
    samples: list[int]


@app.post("/api/ecg/samples")
async def receive_ecg_samples(request: EcgSamplesRequest):
    """
    Receive a batch of real ECG ADC samples from ESP32.
    """

    global latest_ecg

    if request.sampling_rate < 1 or request.sampling_rate > 1000:
        raise HTTPException(
            status_code=400,
            detail="Invalid ECG sampling rate."
        )

    if not request.samples or len(request.samples) > 500:
        raise HTTPException(
            status_code=400,
            detail="Send between 1 and 500 ECG samples."
        )

    if any(sample < 0 or sample > 4095 for sample in request.samples):
        raise HTTPException(
            status_code=400,
            detail="ECG samples must be between 0 and 4095."
        )

    latest_ecg = {
        "device_id": request.device_id,
        "sampling_rate": request.sampling_rate,
        "leads_connected": request.leads_connected,
        "samples": request.samples,
        "received_at": datetime.now(timezone.utc).isoformat()
    }

    print(
        f"[MEDOC ECG] Received {len(request.samples)} samples. "
        f"Leads connected: {request.leads_connected}"
    )

    return {
        "success": True,
        "message": "ECG samples received",
        "sample_count": len(request.samples),
        "received_at": latest_ecg["received_at"]
    }


@app.get("/api/ecg/samples")
async def get_ecg_samples():
    """
    Return the latest ECG sample batch to Flutter.
    """

    if not latest_ecg:
        return {
            "success": True,
            "message": "No ECG samples received yet",
            "data": None
        }

    return {
        "success": True,
        "data": latest_ecg
    }


class VitalsRequest(BaseModel):
    device_id: str = "medoc_esp32"

    # DHT11 room sensor
    temperature: Optional[float] = None
    humidity: Optional[float] = None

    # ECG
    ecg_raw: Optional[int] = None
    ecg_leads_connected: Optional[bool] = None

    # NTC temperature probe
    ntc_adc: Optional[int] = None
    ntc_temperature_c: Optional[float] = None
    ntc_temperature_f: Optional[float] = None
    body_temp_warning_99f: Optional[bool] = None

    # PIR motion sensor
    pir_motion: Optional[bool] = None

    # MAX30102
    max30102_ir: Optional[int] = None
    max30102_red: Optional[int] = None
    max30102_finger_present: Optional[bool] = None

    # Calculated health readings
    heart_rate_bpm: Optional[int] = None
    spo2_percent: Optional[int] = None


@app.post("/api/vitals")
async def receive_vitals(request: VitalsRequest):
    """
    Receive sensor readings from the MedOC ESP32.
    """

    global latest_vitals

    # Store the most recently received readings in memory.
    latest_vitals = request.model_dump()

    latest_vitals["received_at"] = datetime.now(
        timezone.utc
    ).isoformat()

    print("[MEDOC] ESP32 sensor data received:")
    print(latest_vitals)

    return {
        "success": True,
        "message": "MedOC sensor data received successfully",
        "device_id": request.device_id,
        "received_at": latest_vitals["received_at"],
    }


@app.get("/api/vitals")
async def get_latest_vitals():
    """
    Return the latest sensor readings received from ESP32.
    """

    if not latest_vitals:
        return {
            "success": True,
            "message": "No sensor data received yet",
            "data": None,
        }

    return {
        "success": True,
        "data": latest_vitals,
    }
@app.post("/api/ecg/samples")
async def receive_ecg_samples(request: ECGSamplesRequest):
    global latest_ecg

    if len(request.samples) > 500:
        raise HTTPException(
            status_code=400,
            detail="Maximum 500 ECG samples allowed per batch."
        )

    latest_ecg = {
        "device_id": request.device_id,
        "sampling_rate": request.sampling_rate,
        "leads_connected": request.leads_connected,
        "samples": request.samples,
        "received_at": datetime.now(timezone.utc).isoformat()
    }

    return {
        "success": True,
        "message": "ECG samples received",
        "sample_count": len(request.samples)
    }


@app.get("/api/ecg/samples")
async def get_ecg_samples():
    return {
        "success": True,
        "data": latest_ecg
    }
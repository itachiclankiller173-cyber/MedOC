import json


import os
from google import genai
from google.genai import types

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise RuntimeError("GEMINI_API_KEY environment variable is missing")

client = genai.Client(api_key=GEMINI_API_KEY)
MODEL = "models/gemini-3.6-flash"


# ============================================================
# SYSTEM PROMPT
# ============================================================

SYSTEM_PROMPT = """
You are MedOC AI.

You are an AI healthcare assistant.

Rules:

- Answer ONLY healthcare-related questions.
- Never claim to provide a confirmed medical diagnosis.
- Never prescribe medicines or dosages.
- Explain diseases, symptoms, laboratory reports, nutrition,
  exercise, first aid, and healthy lifestyle.
- Recommend consulting a healthcare professional when appropriate.
- If symptoms suggest a medical emergency, clearly advise seeking
  immediate emergency medical care.
- Use clear, simple, and friendly language.
"""


# ============================================================
# LANGUAGE HELPER
# ============================================================

def get_language_instruction(language: str) -> str:

    languages = {
        "English": (
            "Reply only in English. "
            "Use simple and easy-to-understand English."
        ),

        "Malayalam": (
            "Reply only in Malayalam. "
            "Use simple, clear, and natural Malayalam. "
            "Do not unnecessarily mix English words."
        ),

        "Hindi": (
            "Reply only in Hindi. "
            "Use simple and clear Hindi in Devanagari script."
        ),

        "Tamil": (
            "Reply only in Tamil. "
            "Use simple and clear Tamil in Tamil script."
        ),
    }

    return languages.get(
        language,
        languages["English"],
    )


# ============================================================
# GEMINI REQUEST
# ============================================================

def ask_gemini(prompt: str) -> str:
    """Send a prompt to Gemini and return the text response."""

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt,
    )

    return response.text.strip()


# ============================================================
# AI HEALTH CHAT
# ============================================================

def generate_health_response(
    message: str,
    language: str = "English",
):

    language_instruction = get_language_instruction(language)

    prompt = f"""
{SYSTEM_PROMPT}

LANGUAGE INSTRUCTION:

{language_instruction}

User Question:

{message}

Answer in a friendly, informative, and concise way.

Important:

{language_instruction}

If the user is describing symptoms that may require urgent or
emergency medical attention, clearly advise them to seek immediate
medical care.
"""

    try:
        return ask_gemini(prompt)

    except Exception as e:
        return f"MedOC AI Error:\n{str(e)}"


# ============================================================
# AI DISEASE PREDICTION
# INFORMATIONAL ONLY
# ============================================================

def predict_disease(symptoms: str):

    prompt = f"""
{SYSTEM_PROMPT}

Patient Symptoms:

{symptoms}

Analyze the symptoms.

Return ONLY valid JSON.

Format:

{{
  "possible_conditions": [
    "...",
    "...",
    "..."
  ],
  "confidence": "0-100%",
  "recommended_specialist": "...",
  "advice": "...",
  "emergency": "Yes/No"
}}

Do NOT include markdown.
Do NOT include explanations outside JSON.
Do NOT state that the condition is confirmed.
"""

    try:

        result = ask_gemini(prompt)

        if result.startswith("```"):
            result = result.replace("```json", "")
            result = result.replace("```", "")
            result = result.strip()

        return json.loads(result)

    except Exception as e:

        return {
            "possible_conditions": [],
            "confidence": "0%",
            "recommended_specialist": "General Physician",
            "advice": (
                f"Unable to analyze symptoms. Error: {str(e)}"
            ),
            "emergency": "Unknown"
        }


# ============================================================
# AI MEDICAL REPORT EXPLAINER
# ============================================================

def explain_medical_report(report_text: str):

    prompt = f"""
{SYSTEM_PROMPT}

Explain this medical report in simple English.

Medical Report:

{report_text}

Explain:

1. Normal findings
2. Abnormal findings
3. What they may mean
4. Questions to discuss with a doctor

Keep the explanation simple.
"""

    try:
        return ask_gemini(prompt)

    except Exception as e:
        return f"Unable to explain report.\n{str(e)}"


# ============================================================
# MEDICINE INFORMATION
# ============================================================

def medicine_information(medicine_name: str):

    prompt = f"""
{SYSTEM_PROMPT}

The user wants information about this medicine:

{medicine_name}

Provide:

1. What it is used for
2. Common side effects
3. Common precautions
4. Important warnings
5. When to seek medical advice

Do NOT recommend a dosage.
Do NOT prescribe medicines.
Keep the explanation simple.
"""

    try:
        return ask_gemini(prompt)

    except Exception as e:
        return f"Unable to retrieve medicine information.\n{str(e)}"
# ============================================================
# GEMINI BURN IMAGE ANALYSIS
# ============================================================

from google.genai import types


def analyze_burn_image(image_path: str, mime_type: str = "image/jpeg"):
    """Analyze visible features in a burn image using Gemini."""

    prompt = """
You are MedOC AI, a cautious healthcare assistant.

Examine the provided image for visible features that may be
consistent with a skin burn.

Return ONLY valid JSON with these keys:
{
  "visible_observations": "Description of visible features",
  "possible_concern": "Cautious, non-diagnostic description",
  "risk_level": "Needs medical assessment",
  "recommended_action": "Appropriate next steps",
  "limitations": "A photograph cannot reliably determine burn depth"
}

Rules:
- Do not claim a confirmed diagnosis.
- Do not claim to determine burn depth reliably from an image.
- Do not invent findings if the image is unclear.
- Do not prescribe medication or dosages.
- Recommend prompt medical assessment for concerning burns.
- Advise urgent medical care for large or deep burns, burns
  involving the face, hands, feet, genitals or major joints,
  chemical or electrical burns, or breathing difficulties.
- If the image is not suitable for assessment, say so.
- Return valid JSON only, without Markdown fences.
"""

    with open(image_path, "rb") as image_file:
        image_bytes = image_file.read()

    response = client.models.generate_content(
        model=MODEL,
        contents=[
            prompt,
            types.Part.from_bytes(
                data=image_bytes,
                mime_type=mime_type,
            ),
        ],
    )

    if not response.text:
        raise ValueError("Gemini returned an empty response.")

    return response.text.strip()

import cv2
import mediapipe as mp
import numpy as np
import math


def calculate_distance(point1, point2):
    """Calculate the distance between two body landmarks."""

    return math.sqrt(
        (point2.x - point1.x) ** 2
        + (point2.y - point1.y) ** 2
    )


def calculate_angle(point1, point2, point3):
    """
    Calculate the angle between three landmarks.
    point2 is the center point.
    """

    a = np.array([point1.x, point1.y])
    b = np.array([point2.x, point2.y])
    c = np.array([point3.x, point3.y])

    radians = np.arctan2(
        c[1] - b[1],
        c[0] - b[0],
    ) - np.arctan2(
        a[1] - b[1],
        a[0] - b[0],
    )

    angle = abs(radians * 180.0 / np.pi)

    if angle > 180.0:
        angle = 360.0 - angle

    return float(angle)


def analyze_gait(video_path):
    """
    Analyze a walking video using MediaPipe Pose.

    This is a basic computer-vision gait analysis.
    It is not a medical diagnostic tool.
    """

    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        return {
            "success": False,
            "message": "Could not open video file",
        }

    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    if fps <= 0:
        fps = 30

    video_duration = total_frames / fps

    mp_pose = mp.solutions.pose

    detected_frames = 0

    left_knee_angles = []
    right_knee_angles = []

    left_hip_angles = []
    right_hip_angles = []

    step_distances = []

    # Analyze the video frame by frame
    with mp_pose.Pose(
        static_image_mode=False,
        model_complexity=1,
        smooth_landmarks=True,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    ) as pose:

        while cap.isOpened():

            success, frame = cap.read()

            if not success:
                break

            rgb_frame = cv2.cvtColor(
                frame,
                cv2.COLOR_BGR2RGB,
            )

            results = pose.process(rgb_frame)

            if not results.pose_landmarks:
                continue

            detected_frames += 1

            landmarks = results.pose_landmarks.landmark

            # Get important landmarks
            left_hip = landmarks[
                mp_pose.PoseLandmark.LEFT_HIP.value
            ]

            right_hip = landmarks[
                mp_pose.PoseLandmark.RIGHT_HIP.value
            ]

            left_knee = landmarks[
                mp_pose.PoseLandmark.LEFT_KNEE.value
            ]

            right_knee = landmarks[
                mp_pose.PoseLandmark.RIGHT_KNEE.value
            ]

            left_ankle = landmarks[
                mp_pose.PoseLandmark.LEFT_ANKLE.value
            ]

            right_ankle = landmarks[
                mp_pose.PoseLandmark.RIGHT_ANKLE.value
            ]

            # -------------------------------
            # Knee angles
            # -------------------------------

            left_knee_angle = calculate_angle(
                left_hip,
                left_knee,
                left_ankle,
            )

            right_knee_angle = calculate_angle(
                right_hip,
                right_knee,
                right_ankle,
            )

            left_knee_angles.append(left_knee_angle)
            right_knee_angles.append(right_knee_angle)

            # -------------------------------
            # Hip angles
            # -------------------------------

            left_hip_angle = calculate_angle(
                left_knee,
                left_hip,
                right_hip,
            )

            right_hip_angle = calculate_angle(
                right_knee,
                right_hip,
                left_hip,
            )

            left_hip_angles.append(left_hip_angle)
            right_hip_angles.append(right_hip_angle)

            # -------------------------------
            # Ankle distance
            # Used as a basic step-width indicator
            # -------------------------------

            ankle_distance = calculate_distance(
                left_ankle,
                right_ankle,
            )

            step_distances.append(ankle_distance)

    cap.release()

    # ---------------------------------------
    # Check if enough pose data was detected
    # ---------------------------------------

    if detected_frames == 0:
        return {
            "success": False,
            "message": (
                "No person or body landmarks were detected. "
                "Please upload a clear walking video."
            ),
        }

    # ---------------------------------------
    # Calculate averages
    # ---------------------------------------

    avg_left_knee = float(np.mean(left_knee_angles))
    avg_right_knee = float(np.mean(right_knee_angles))

    avg_left_hip = float(np.mean(left_hip_angles))
    avg_right_hip = float(np.mean(right_hip_angles))

    avg_step_width = float(np.mean(step_distances))

    # ---------------------------------------
    # Calculate symmetry
    # ---------------------------------------

    knee_difference = abs(
        avg_left_knee - avg_right_knee
    )

    hip_difference = abs(
        avg_left_hip - avg_right_hip
    )

    if knee_difference < 8:
        knee_symmetry = "Good"
    elif knee_difference < 15:
        knee_symmetry = "Moderate"
    else:
        knee_symmetry = "Low"

    if hip_difference < 8:
        hip_symmetry = "Good"
    elif hip_difference < 15:
        hip_symmetry = "Moderate"
    else:
        hip_symmetry = "Low"

    # ---------------------------------------
    # Overall gait pattern
    # ---------------------------------------

    if (
        knee_symmetry == "Good"
        and hip_symmetry == "Good"
    ):
        gait_pattern = "No major asymmetry detected"
        risk_level = "Low"

    elif (
        knee_symmetry == "Low"
        or hip_symmetry == "Low"
    ):
        gait_pattern = (
            "Movement asymmetry detected. "
            "Professional evaluation may be helpful."
        )
        risk_level = "Moderate"

    else:
        gait_pattern = (
            "Some movement asymmetry detected."
        )
        risk_level = "Low"

    # ---------------------------------------
    # Return analysis
    # ---------------------------------------

    return {
        "success": True,

        "message": "Gait analysis completed",

        "video": {
            "duration_seconds": round(
                video_duration,
                2,
            ),

            "frames_analyzed": detected_frames,
        },

        "gait_analysis": {
            "left_knee_average_angle": round(
                avg_left_knee,
                2,
            ),

            "right_knee_average_angle": round(
                avg_right_knee,
                2,
            ),

            "knee_difference": round(
                knee_difference,
                2,
            ),

            "knee_symmetry": knee_symmetry,

            "left_hip_average_angle": round(
                avg_left_hip,
                2,
            ),

            "right_hip_average_angle": round(
                avg_right_hip,
                2,
            ),

            "hip_difference": round(
                hip_difference,
                2,
            ),

            "hip_symmetry": hip_symmetry,

            "average_ankle_distance": round(
                avg_step_width,
                4,
            ),

            "gait_pattern": gait_pattern,

            "risk_level": risk_level,
        },

        "disclaimer": (
            "This computer-vision analysis is for informational "
            "purposes only and is not a medical diagnosis."
        ),
    }
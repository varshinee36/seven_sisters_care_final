from datetime import datetime
from database import patients_collection


def calculate_age(dob_str):
    dob = datetime.strptime(dob_str, "%Y-%m-%d")
    today = datetime.today()

    age = today.year - dob.year

    if (today.month, today.day) < (dob.month, dob.day):
        age -= 1

    return age


def register_patient(patient_data):
    patient_dict = patient_data.dict()

    patient_dict["age"] = calculate_age(patient_dict["dob"])

    result = patients_collection.insert_one(patient_dict)

    patient_id = str(result.inserted_id)

    return {
        "message": "Patient registered successfully",
        "patient_id": patient_id,
        "patient_name": patient_dict["patient_name"]
    }


def get_patients_by_caregiver(caregiver_username):
    patients = list(
        patients_collection.find(
            {"caregiver_username": caregiver_username},
            {"_id": 0}
        )
    )

    return patients
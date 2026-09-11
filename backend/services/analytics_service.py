from datetime import datetime
from database import game_performance_collection
from models.analytics import GamePerformanceRecord


def get_default_analytics() -> dict:
    """Returns safe fallback analytics values when no game records exist."""
    return {
        "overallPerformance": 0,
        "accuracy": 0,
        "correctResponses": 0,
        "wrongResponses": 0,
        "averageCompletionTime": 0,
        "currentDifficulty": "Easy",
        "currentTimer": 60,
        "adaptiveAction": "No Data",
        "rlState": "No Data",
        "lastPlayedGame": "No Data",
        "finalLevelReached": 0,
        "lastTimerUsed": 60,
        "finalPerformanceScore": 0,
        "memoryHunt": {
            "performance": 0,
            "level": 1,
            "difficulty": "Easy",
        },
        "pairFinder": {
            "performance": 0,
            "level": 1,
            "difficulty": "Easy",
        },
    }


def save_game_performance(record: GamePerformanceRecord | dict) -> dict:
    """Saves a completed game performance record into the game_performance collection."""
    if isinstance(record, GamePerformanceRecord):
        data = record.model_dump()
    else:
        data = dict(record)

    if not data.get("timestamp"):
        data["timestamp"] = datetime.utcnow().isoformat()

    # Ensure required default fields
    data.setdefault("game_id", "")
    data.setdefault("final_performance_score", 0.0)
    data.setdefault("cumulative_accuracy", 0.0)
    data.setdefault("cumulative_correct_answers", 0)
    data.setdefault("cumulative_wrong_answers", 0)
    data.setdefault("average_completion_time", 0.0)
    data.setdefault("final_level_reached", 1)
    data.setdefault("last_timer_used", 60)
    data.setdefault("current_difficulty", "Easy")
    data.setdefault("adaptive_action", "Maintain Difficulty + Maintain Timer")
    data.setdefault("rl_state", "Good Performance")

    result = game_performance_collection.insert_one(data)
    return {
        "message": "Game performance recorded successfully",
        "id": str(result.inserted_id),
        "game_name": data.get("game_name"),
    }


def get_dashboard_analytics(patient_id: str) -> dict:
    """
    Retrieves aggregated and latest analytics for the caregiver dashboard for a given patient.
    Returns safe default values if no records exist.
    """
    if not patient_id or patient_id.strip() == "":
        return get_default_analytics()

    records = list(
        game_performance_collection.find({"patient_id": patient_id.strip()})
        .sort("timestamp", -1)
    )

    if not records:
        return get_default_analytics()

    latest = records[0]

    # Calculate overall aggregates
    scores = [r.get("final_performance_score", 0.0) for r in records if "final_performance_score" in r]
    accuracies = [r.get("cumulative_accuracy", 0.0) for r in records if "cumulative_accuracy" in r]
    comp_times = [r.get("average_completion_time", 0.0) for r in records if "average_completion_time" in r]

    overall_perf = round(sum(scores) / len(scores), 1) if scores else 0.0
    overall_acc = round(sum(accuracies) / len(accuracies), 1) if accuracies else 0.0
    avg_comp_time = round(sum(comp_times) / len(comp_times), 1) if comp_times else 0.0
    total_correct = sum(r.get("cumulative_correct_answers", 0) for r in records)
    total_wrong = sum(r.get("cumulative_wrong_answers", 0) for r in records)

    # Game-specific summaries
    memory_hunt_rec = next(
        (r for r in records if r.get("game_name", "").strip().lower().replace(" ", "") == "memoryhunt"),
        None,
    )
    pair_finder_rec = next(
        (r for r in records if r.get("game_name", "").strip().lower().replace(" ", "") == "pairfinder"),
        None,
    )

    memory_hunt_summary = {
        "performance": memory_hunt_rec.get("final_performance_score", 0.0) if memory_hunt_rec else 0.0,
        "level": memory_hunt_rec.get("final_level_reached", 1) if memory_hunt_rec else 1,
        "difficulty": memory_hunt_rec.get("current_difficulty", "Easy") if memory_hunt_rec else "Easy",
    }

    pair_finder_summary = {
        "performance": pair_finder_rec.get("final_performance_score", 0.0) if pair_finder_rec else 0.0,
        "level": pair_finder_rec.get("final_level_reached", 1) if pair_finder_rec else 1,
        "difficulty": pair_finder_rec.get("current_difficulty", "Easy") if pair_finder_rec else "Easy",
    }

    return {
        "overallPerformance": overall_perf,
        "accuracy": overall_acc,
        "correctResponses": total_correct,
        "wrongResponses": total_wrong,
        "averageCompletionTime": avg_comp_time,
        "currentDifficulty": latest.get("current_difficulty", "Easy"),
        "currentTimer": latest.get("last_timer_used", 60),
        "adaptiveAction": latest.get("adaptive_action") or "Maintain Difficulty + Maintain Timer",
        "rlState": latest.get("rl_state") or "Good Performance",
        "lastPlayedGame": latest.get("game_name", "No Data"),
        "finalLevelReached": latest.get("final_level_reached", 0),
        "lastTimerUsed": latest.get("last_timer_used", 60),
        "finalPerformanceScore": latest.get("final_performance_score", 0.0),
        "memoryHunt": memory_hunt_summary,
        "pairFinder": pair_finder_summary,
    }


def get_weekly_analytics(patient_id: str) -> dict:
    """
    Computes weekly analytics for a given patient from game_performance:
    - weekly_average_performance: average performance score over the last 7 days
    - weekly_accuracy: average accuracy over the last 7 days
    - weekly_completion_trend: daily/session performance trend data
    """
    if not patient_id or patient_id.strip() == "":
        return {
            "weekly_average_performance": 0.0,
            "weekly_accuracy": 0.0,
            "weekly_completion_trend": [],
        }

    from datetime import timedelta

    cutoff = datetime.utcnow() - timedelta(days=7)
    cutoff_iso = cutoff.isoformat()

    # Query records from the last 7 days (or fallback to latest records)
    records = list(
        game_performance_collection.find({
            "patient_id": patient_id.strip(),
            "timestamp": {"$gte": cutoff_iso},
        }).sort("timestamp", 1)
    )

    if not records:
        records = list(
            game_performance_collection.find({"patient_id": patient_id.strip()})
            .sort("timestamp", -1)
            .limit(7)
        )
        records.reverse()

    if not records:
        return {
            "weekly_average_performance": 0.0,
            "weekly_accuracy": 0.0,
            "weekly_completion_trend": [],
        }

    scores = [r.get("final_performance_score", 0.0) for r in records if "final_performance_score" in r]
    accuracies = [r.get("cumulative_accuracy", 0.0) for r in records if "cumulative_accuracy" in r]

    weekly_avg_perf = round(sum(scores) / len(scores), 1) if scores else 0.0
    weekly_acc = round(sum(accuracies) / len(accuracies), 1) if accuracies else 0.0

    trend = [
        {
            "game_name": r.get("game_name", "Cognitive Game"),
            "performance": r.get("final_performance_score", 0.0),
            "accuracy": r.get("cumulative_accuracy", 0.0),
            "timestamp": r.get("timestamp", ""),
        }
        for r in records
    ]

    return {
        "weekly_average_performance": weekly_avg_perf,
        "weekly_accuracy": weekly_acc,
        "weekly_completion_trend": trend,
    }


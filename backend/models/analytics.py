from typing import Optional
from pydantic import BaseModel, Field


class GamePerformanceRecord(BaseModel):
    patient_id: str = Field(..., description="Unique ID of the linked patient")
    game_id: Optional[str] = Field(default="", description="Game identifier")
    game_name: str = Field(..., description="Name of the cognitive game (e.g. Memory Hunt, Pair Finder)")
    final_performance_score: float = Field(default=0.0, description="Final cumulative performance score percentage (0-100)")
    cumulative_accuracy: float = Field(default=0.0, description="Cumulative accuracy percentage (0-100)")
    cumulative_correct_answers: int = Field(default=0, description="Total correct answers during session")
    cumulative_wrong_answers: int = Field(default=0, description="Total wrong answers during session")
    average_completion_time: float = Field(default=0.0, description="Average completion time in seconds")
    final_level_reached: int = Field(default=1, description="Final level reached during session")
    last_timer_used: int = Field(default=60, description="Last timer duration used in seconds")
    current_difficulty: str = Field(default="Easy", description="Final difficulty level (Easy/Medium/Hard)")
    adaptive_action: str = Field(default="", description="Last RL adaptive action selected")
    rl_state: str = Field(default="", description="Last RL state")
    timestamp: Optional[str] = Field(default=None, description="ISO timestamp of game session completion")


class GameSummary(BaseModel):
    performance: float = Field(default=0.0, description="Latest performance percentage")
    level: int = Field(default=1, description="Latest level reached")
    difficulty: str = Field(default="Easy", description="Latest difficulty")


class DashboardAnalyticsResponse(BaseModel):
    overallPerformance: float = 0.0
    accuracy: float = 0.0
    correctResponses: int = 0
    wrongResponses: int = 0
    averageCompletionTime: float = 0.0

    currentDifficulty: str = "Easy"
    currentTimer: int = 60
    adaptiveAction: str = "No Data"
    rlState: str = "No Data"

    lastPlayedGame: str = "No Data"
    finalLevelReached: int = 0
    lastTimerUsed: int = 60
    finalPerformanceScore: float = 0.0

    memoryHunt: GameSummary = Field(default_factory=GameSummary)
    pairFinder: GameSummary = Field(default_factory=GameSummary)

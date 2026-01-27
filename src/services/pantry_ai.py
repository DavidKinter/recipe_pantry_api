"""
Claude AI integration for pantry-based dish suggestions.

Provides functional API for generating purchase recommendations
based on user's available ingredients using structured outputs.

SOURCE: CLAUDE DOCS AGENT
"""

import json
import os
from typing import Dict, List

import anthropic
from anthropic import AsyncAnthropic

# Module-level client and constants
client = AsyncAnthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
MODEL = "claude-haiku-4-5-20251001"
MAX_TOKENS = 500

# JSON schema for structured output (Claude format suggested by Docs agent)
# Note: Claude does not support minItems/maxItems as Docs agent suggests
# Array lengths enforced via prompt
OUTPUT_SCHEMA = {
    "type": "object",
    "properties": {
        "buy_one": {
            "type": "object",
            "properties": {
                "dish": {"type": "string"},
                "missing": {
                    "type": "array",
                    "items": {"type": "string"},
                },
            },
            "required": ["dish", "missing"],
            "additionalProperties": False,
        },
        "buy_two": {
            "type": "object",
            "properties": {
                "dish": {"type": "string"},
                "missing": {
                    "type": "array",
                    "items": {"type": "string"},
                },
            },
            "required": ["dish", "missing"],
            "additionalProperties": False,
        },
        "buy_three": {
            "type": "object",
            "properties": {
                "dish": {"type": "string"},
                "missing": {
                    "type": "array",
                    "items": {"type": "string"},
                },
            },
            "required": ["dish", "missing"],
            "additionalProperties": False,
        },
    },
    "required": ["buy_one", "buy_two", "buy_three"],
    "additionalProperties": False,
}


def build_prompt(pantry_items: List[str]) -> str:
    """Build the prompt for dish suggestions."""
    return f"""User's pantry contains: {", ".join(pantry_items)}

Find dishes the user could make by buying a few more ingredients.

Return exactly:
- "buy_one": 1 dish needing exactly 1 more ingredient
- "buy_two": 1 dish needing exactly 2 more ingredients
- "buy_three": 1 dish needing exactly 3 more ingredients

Rules:
1. Only well-known, real dishes
2. Use common ingredient names
3. Each dish must be different from the others
4. Missing ingredients must not include pantry items"""


def fallback_response(error_message: str, pantry_count: int = 0) -> Dict:
    """Return when AI fails."""
    return {
        "pantry_count": pantry_count,
        "error": error_message,
        "fallback": "Try our standard recipe matcher instead",
        "suggestions": None,
    }


async def get_dish_suggestions(pantry_items: List[str]) -> Dict:
    """
    Analyze pantry and suggest dishes at three purchase tiers.
    Uses Claude structured outputs for guaranteed JSON schema.
    """
    if not pantry_items:
        return fallback_response("Pantry is empty", pantry_count=0)

    pantry_count = len(pantry_items)
    prompt = build_prompt(pantry_items)

    try:
        response = await client.beta.messages.create(
            model=MODEL,
            max_tokens=MAX_TOKENS,
            betas=["structured-outputs-2025-11-13"],
            messages=[{"role": "user", "content": prompt}],
            system="You are a cooking assistant.",
            output_format={
                "type": "json_schema",
                "schema": OUTPUT_SCHEMA,
            },
        )

        result = json.loads(response.content[0].text)

        return {
            "pantry_count": len(pantry_items),
            "suggestions": {
                "buy_one": result.get("buy_one"),
                "buy_two": result.get("buy_two"),
                "buy_three": result.get("buy_three"),
            },
        }

    except json.JSONDecodeError:
        return fallback_response(
            "Invalid AI response",
            pantry_count,
        )

    except anthropic.RateLimitError:
        return fallback_response(
            "Service busy, try again later",
            pantry_count,
        )

    except Exception as e:
        print(f"AI service error: {e}")
        return fallback_response(
            "AI service temporarily unavailable",
            pantry_count,
        )

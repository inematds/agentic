"""
tools/__init__.py
Pacote de ferramentas para o Agente do Zero.

Exporta os schemas e funções de todas as ferramentas disponíveis,
permitindo que agent.py as importe de forma limpa e centralizada.

Uso em agent.py:
    from tools import get_weather_tool_schema, get_weather
"""

from .weather_tool import get_weather_tool_schema, get_weather

__all__ = ["get_weather_tool_schema", "get_weather"]

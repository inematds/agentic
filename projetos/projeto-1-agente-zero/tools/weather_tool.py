"""
tools/weather_tool.py
Ferramenta de consulta de clima para o Agente do Zero.

Demonstra como criar uma ferramenta externa que pode ser plugada
no agente sem modificar o loop principal (agent.py).

Utiliza a API do OpenWeatherMap quando a chave está configurada.
Caso contrário, retorna dados simulados para fins de desenvolvimento.

Dependência opcional:
    pip install requests

Configuração:
    Adicione ao seu .env:
    OPENWEATHER_API_KEY=sua_chave_aqui
    (Obtenha grátis em: https://openweathermap.org/api)
"""

import os
import json

# Optional dependency — only required if using the real API
try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False


# Base URL for OpenWeatherMap current weather endpoint
OPENWEATHER_BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

# Simulated weather data used as fallback when no API key is configured
_SIMULATED_DATA = {
    "são paulo":    {"temp": 24, "descricao": "parcialmente nublado", "umidade": 72, "vento": 15},
    "rio de janeiro": {"temp": 30, "descricao": "ensolarado",          "umidade": 65, "vento": 20},
    "curitiba":     {"temp": 18, "descricao": "nublado com garoa",     "umidade": 85, "vento": 25},
    "salvador":     {"temp": 28, "descricao": "ensolarado",            "umidade": 70, "vento": 18},
    "brasília":     {"temp": 26, "descricao": "céu claro",             "umidade": 45, "vento": 12},
    "fortaleza":    {"temp": 32, "descricao": "ensolarado",            "umidade": 68, "vento": 22},
    "manaus":       {"temp": 33, "descricao": "chuva leve",            "umidade": 90, "vento": 8},
    "porto alegre": {"temp": 20, "descricao": "parcialmente nublado",  "umidade": 78, "vento": 30},
}


def get_weather_tool_schema() -> dict:
    """
    Retorna o schema JSON da ferramenta no formato esperado pela API Anthropic.

    Este schema é passado diretamente para o parâmetro `tools` da chamada
    `client.messages.create()`, informando ao modelo como e quando chamar
    esta ferramenta.

    Returns:
        dict: Schema completo da ferramenta no formato Anthropic tool_use.

    Example:
        >>> schema = get_weather_tool_schema()
        >>> schema["name"]
        'consultar_clima'
    """
    return {
        "name": "consultar_clima",
        "description": (
            "Consulta as condições climáticas atuais de uma cidade. "
            "Retorna temperatura, descrição do tempo, umidade e velocidade do vento. "
            "Use quando o usuário perguntar sobre o clima, temperatura ou previsão do tempo."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "cidade": {
                    "type": "string",
                    "description": (
                        "Nome da cidade para consultar o clima. "
                        "Exemplos: 'São Paulo', 'Rio de Janeiro', 'London', 'New York'."
                    )
                }
            },
            "required": ["cidade"]
        }
    }


def get_weather(cidade: str) -> str:
    """
    Busca as condições climáticas atuais de uma cidade.

    Tenta usar a API real do OpenWeatherMap se a variável de ambiente
    OPENWEATHER_API_KEY estiver configurada e o pacote `requests` estiver
    instalado. Caso contrário, retorna dados simulados para desenvolvimento.

    Args:
        cidade (str): Nome da cidade a ser consultada.

    Returns:
        str: Descrição formatada das condições climáticas, incluindo
             temperatura (°C), descrição, umidade (%) e vento (km/h).
             Em caso de erro, retorna uma mensagem descritiva do problema.

    Examples:
        >>> resultado = get_weather("São Paulo")
        >>> "São Paulo" in resultado
        True
        >>> "°C" in resultado
        True
    """
    api_key = os.getenv("OPENWEATHER_API_KEY")

    # --- Real API path ---
    if api_key and REQUESTS_AVAILABLE:
        return _fetch_from_api(cidade, api_key)

    # --- Fallback: simulated data ---
    return _fetch_simulated(cidade)


# ─── PRIVATE HELPERS ──────────────────────────────────────────────────────────

def _fetch_from_api(cidade: str, api_key: str) -> str:
    """
    Faz a requisição real à API do OpenWeatherMap.

    Args:
        cidade (str): Nome da cidade.
        api_key (str): Chave de API válida do OpenWeatherMap.

    Returns:
        str: Condições climáticas formatadas ou mensagem de erro.
    """
    try:
        params = {
            "q": cidade,
            "appid": api_key,
            "units": "metric",   # Celsius
            "lang": "pt_br",     # Descrições em português
        }
        response = requests.get(OPENWEATHER_BASE_URL, params=params, timeout=10)

        # Handle common HTTP errors
        if response.status_code == 404:
            return f"Cidade '{cidade}' não encontrada. Verifique o nome e tente novamente."
        if response.status_code == 401:
            return "Chave de API inválida. Verifique a variável OPENWEATHER_API_KEY no seu .env."
        if response.status_code != 200:
            return f"Erro ao consultar a API: HTTP {response.status_code}."

        data = response.json()

        # Extract relevant fields from the API response
        temp = data["main"]["temp"]
        temp_max = data["main"]["temp_max"]
        temp_min = data["main"]["temp_min"]
        descricao = data["weather"][0]["description"].capitalize()
        umidade = data["main"]["humidity"]
        vento_ms = data["wind"]["speed"]
        vento_kmh = round(vento_ms * 3.6, 1)  # Convert m/s to km/h
        nome_cidade = data["name"]
        pais = data["sys"]["country"]

        return (
            f"Clima em {nome_cidade}, {pais}:\n"
            f"  Temperatura: {temp:.1f}°C (max {temp_max:.1f}°C / min {temp_min:.1f}°C)\n"
            f"  Condicoes: {descricao}\n"
            f"  Umidade: {umidade}%\n"
            f"  Vento: {vento_kmh} km/h"
        )

    except requests.exceptions.Timeout:
        return "Tempo esgotado ao consultar a API do OpenWeatherMap. Tente novamente."
    except requests.exceptions.ConnectionError:
        return "Sem conexao com a internet. Verifique sua conexao e tente novamente."
    except (KeyError, json.JSONDecodeError) as e:
        return f"Erro ao processar resposta da API: {str(e)}"


def _fetch_simulated(cidade: str) -> str:
    """
    Retorna dados de clima simulados para desenvolvimento e testes.

    Usa um dicionário interno com dados de cidades brasileiras comuns.
    Para cidades não mapeadas, gera valores genéricos plausíveis.

    Args:
        cidade (str): Nome da cidade.

    Returns:
        str: Condições climáticas simuladas formatadas.
    """
    # Normalize city name for lookup (lowercase, strip whitespace)
    chave = cidade.strip().lower()

    # Check known cities first
    if chave in _SIMULATED_DATA:
        dados = _SIMULATED_DATA[chave]
        return (
            f"[SIMULADO] Clima em {cidade.title()}:\n"
            f"  Temperatura: {dados['temp']}°C\n"
            f"  Condicoes: {dados['descricao'].capitalize()}\n"
            f"  Umidade: {dados['umidade']}%\n"
            f"  Vento: {dados['vento']} km/h\n"
            f"  (Configure OPENWEATHER_API_KEY no .env para dados reais)"
        )

    # Generic fallback for unknown cities
    return (
        f"[SIMULADO] Clima em {cidade.title()}:\n"
        f"  Temperatura: 22°C\n"
        f"  Condicoes: Parcialmente nublado\n"
        f"  Umidade: 60%\n"
        f"  Vento: 14 km/h\n"
        f"  (Dados genericos — configure OPENWEATHER_API_KEY para resultados reais)"
    )

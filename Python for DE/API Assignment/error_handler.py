import logging
import requests
from datetime import datetime

logging.basicConfig(
    filename = "api_errors.log",
    level = logging.ERROR,
    format = '%(asctime)s | %(levelname)s | %(message)s',
    datefmt = '%Y-%m-%d %H:%M:%S'
)

logger = logging.getLogger(__name__)

BASE_URL = 'https://jsonplaceholder.typicode.com'

def fetch_data(endpoint):
    url = f"{BASE_URL}/{endpoint}"
    try:
        response = requests.get(url,timeout=10)
        response.raise_for_status()
        return response.json()
    
    # The API endpoint is invalid.
    except requests.exception.ConnectionError as e:
        logger.error(f"ConnectionError | endpoint = {endpoint} | {str(e)}")
        print(f"[ERROR] Network connection failed for '{endpoint}'. See api_errors.log.")
    
    # The network connection fails or times out.
    except requests.exception.Timeout as e:
        logger.error(f"TimeoutError | endpoint = {endpoint} | {str(e)}")
        print(f"[ERROR] Request timed out for '{endpoint}'. See api_errors.log.")
    
    # The API returns a non-success status code.
    except request.exception.HTTPError as e:
        status = e.response.status_code
        logger.error(f"HTTPError | endpoint={endpoint} | status={status} | {str(e)}")
        print(f"[ERROR] HTTP {status} error for '{endpoint}'. See api_errors.log.")

    except requests.exceptions.InvalidURL as e:
        logger.error(f"InvalidURLError | endpoint={endpoint} | {str(e)}")
        print(f"[ERROR] Invalid URL for '{endpoint}'. See api_errors.log.")

    except requests.exceptions.RequestException as e:
        logger.error(f"RequestException | endpoint={endpoint} | {str(e)}")
        print(f"[ERROR] Unexpected request error for '{endpoint}'. See api_errors.log.")

    return None

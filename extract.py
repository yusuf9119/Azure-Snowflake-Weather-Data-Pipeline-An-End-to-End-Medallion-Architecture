import requests
from storage import uploadtoblob
def fetch_data():
    url = ("https://api.open-meteo.com/v1/forecast")
    
    params = {**{
        "longitude":-3.18,
        "latitude":51.48,
        "timezone":"Europe/London",
        "forecast_days":7,},
    **{
         "hourly": "temperature_2m,precipitation,weather_code"
    }}

    
    
    
    response = requests.get(url, params = params)
    response.raise_for_status() #if it fails

    return response.json()


if __name__ == "__main__":
    data = fetch_data()
    uploadtoblob(data)
    


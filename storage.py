import json
from azure.storage.blob import BlobServiceClient
from dotenv import load_dotenv
import os



def uploadtoblob(data):
    load_dotenv()
    conn = os.getenv("key")
    blob = BlobServiceClient.from_connection_string(conn_str=conn)

    container = blob.get_container_client("cardiffdata")

    blob_name = "cardiff_weather.json"


    container.upload_blob(
        name = blob_name,
        data = json.dumps(data),
        overwrite= True
    )





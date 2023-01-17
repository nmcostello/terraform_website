import requests
import os

def main(url: str):
    # Request https
    httpsUrl = f"https://{url}"
    httpsRequest = requests.get(httpsUrl)
    # Request http
    httpUrl = f"http://{url}"
    httpRequest = requests.get(httpUrl)

    print("HTTP= ", httpRequest.status_code)
    print("HTTPS= ",httpRequest.status_code)

if __name__ == "__main__":

    print(os.environ.get('URL'), flush=True)
    url = os.environ.get('URL')
    main(url)

import requests
import os

def main(url: str):
    # Request https
    httpsUrl = f("https://{url}")
    httpsRequest = requests.get(url)
    # Request http
    httpUrl = f("http://{url}")
    httpRequest = requests.get(url)

    print("HTTP= ", httpRequest.status_code)
    print("HTTPS= ",httpRequest.status_code)
    
if __name__ == "__main__":

    url = os.environ.get('URL')
    main(url)

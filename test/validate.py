import requests
import os
from bs4 import BeautifulSoup

def main(url: str):
    # Request https
    httpsUrl = f"https://{url}"
    httpsRequest = requests.get(httpsUrl)

    htmlResponse = BeautifulSoup(httpsRequest.text, 'html.parser')
    bodyText = htmlResponse.find_all('h1')[0].get_text()

    if bodyText == "Hello World!":
        print("SUCCESS!")
    else:
        print(f"Did not get the expected response. Got: \n{bodyText}")
        exit(1)



if __name__ == "__main__":
    url = os.environ.get('URL')
    main(url)

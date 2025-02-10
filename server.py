from flask import Flask, request, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import requests
import time

app = Flask(__name__)

# ✅ TEST ROUTE: Check if Flask is running
@app.route("/")
def home():
    return "✅ Flask API is working!"

# 🔍 Function to Perform Google Reverse Image Search
def search_google_for_tradingcarddb(image_url):
    # 🔹 Force Google to return only results from tcdb.com/ViewCard.cfm
    search_url = f"https://www.google.com/searchbyimage?image_url={image_url}&q=site:tcdb.com/ViewCard.cfm/sid"
    print(f"🔍 Searching Google Images: {search_url}")

    options = Options()
    options.add_argument("--headless")  # Run without opening a browser
    options.add_argument("--disable-blink-features=AutomationControlled")

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.get(search_url)
    time.sleep(5)  # Allow Google results to load

    soup = BeautifulSoup(driver.page_source, "html.parser")
    driver.quit()

    print(f"🔍 Google Search Results:\n{soup.prettify()[:500]}")  # Print first 500 chars of HTML

    # 🔎 Find the first tcdb.com/ViewCard.cfm link in Google results
    for link in soup.find_all("a", href=True):
        if "tcdb.com/ViewCard.cfm/sid" in link["href"]:
            print(f"✅ Found TCDB Link: {link['href']}")
            return link["href"]

    print("❌ No TradingCardDB link found.")
    return None

# 🔥 Function to Scrape TradingCardDB
def scrape_tradingcarddb(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
    }

    print(f"🔍 Scraping TradingCardDB: {url}")
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        print(f"❌ Failed to load page. HTTP {response.status_code}")
        return {"error": "Failed to load page"}

    soup = BeautifulSoup(response.text, "html.parser")

    card_name = soup.find("h1").text.strip() if soup.find("h1") else "Unknown Card"
    set_name = soup.find("div", class_="set-name").text.strip() if soup.find("div", class_="set-name") else "Unknown Set"
    year = soup.find("span", class_="year").text.strip() if soup.find("span", class_="year") else "Unknown Year"
    card_number = soup.find("span", class_="card-number").text.strip() if soup.find("span", class_="card-number") else "Unknown Number"
    team_name = soup.find("div", class_="team-name").text.strip() if soup.find("div", class_="team-name") else "Unknown Team"

    return {
        "player_name": card_name,
        "team_name": team_name,
        "set_name": set_name,
        "year": year,
        "card_number": card_number
    }

# 🌍 API Endpoint to Process a Scanned Image
@app.route('/process_scan', methods=['POST'])
def process_scan():
    data = request.get_json()
    print(f"📡 Received Request: {request.data}")  # Debugging log

    if not data or "image_url" not in data:
        print("❌ Missing image_url")
        return jsonify({"error": "Missing image_url"}), 400

    image_url = data["image_url"]
    print(f"🔍 Processing Image: {image_url}")

    # 🔹 Call Google Image Search
    tcdb_url = search_google_for_tradingcarddb(image_url)
    if not tcdb_url:
        return jsonify({"error": "No match found"}), 404

    # 🔹 Scrape metadata from TCDB
    metadata = scrape_tradingcarddb(tcdb_url)

    return jsonify(metadata)

# ✅ Run Flask for Production (Railway, Cloud, etc.)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)

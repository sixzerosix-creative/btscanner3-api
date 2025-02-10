from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options
from bs4 import BeautifulSoup
import re  # 🔥 New: Regex for cleaning text

def scrape_tradingcarddb_selenium(url):
    options = Options()
    options.add_argument("--headless")  # Run in background
    options.add_argument("--disable-blink-features=AutomationControlled")  # Avoid detection
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36")

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.get(url)
    driver.implicitly_wait(5)  # Wait for JavaScript to load

    soup = BeautifulSoup(driver.page_source, "html.parser")
    driver.quit()

    # 🔥 Extract Card Name (Remove extra spaces & line breaks)
    raw_card_name = soup.find("h4").text.strip() if soup.find("h4") else "Unknown Card"
    cleaned_text = " ".join(raw_card_name.split())  # Remove excessive spaces

    # 🔥 Extract Card Number (If it exists)
    card_number_match = re.search(r"#(\d+)", cleaned_text)
    card_number = f"#{card_number_match.group(1)}" if card_number_match else "Unknown Number"

    # 🔥 Extract Player Name (Everything before the first " - " separator)
    player_name = cleaned_text.split(" - ")[1] if " - " in cleaned_text else cleaned_text

    # 🔥 Extract Team Name (Everything after the last " - ")
    team_name = cleaned_text.split(" - ")[-1] if " - " in cleaned_text else "Unknown Team"

    return {
        "player_name": player_name.strip(),
        "team_name": team_name.strip(),
        "card_number": card_number,
        "status": "Scraped using Selenium"
    }

# ✅ Test
url = "https://www.tradingcarddb.com/ViewCard.cfm/sid/2686/cid/659260"
data = scrape_tradingcarddb_selenium(url)
print(data)

import json
import logging
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.common.exceptions import TimeoutException, NoSuchElementException



# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("Lambda function started.")
        logger.info(f"Event: {event}")

        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920x1080")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--remote-debugging-port=9222") 
        chrome_options.binary_location = "/opt/chrome/chrome-linux64/chrome"

        
        # Explicitly set ChromeDriver path
        service = Service(executable_path="/opt/chromedriver/chromedriver-linux64/chromedriver")
        driver = webdriver.Chrome(service=service, options=chrome_options)

        logger.info("Navigating to https://annotationz.blogspot.com/...")
        driver.get("https://annotationz.blogspot.com/")
        logger.info("Navigation complete.")

        logger.info("Finding and clicking the 'Express' link...")
        try:
            express_link = driver.find_element(By.XPATH, "//a[contains(@href, '/search/label/Express')]")
            express_link.click()
            logger.info("'Express' link clicked.")
        except NoSuchElementException:
            logger.error("Express link not found.")
            return {"statusCode": 404, "body": json.dumps({"error": "Express link not found."})}

        logger.info("Retrieving page title...")
        page_title = driver.title
        logger.info(f"Page title: {page_title}")

        logger.info("Quitting WebDriver...")
        driver.quit()
        logger.info("WebDriver quit.")

        return {"statusCode": 200, "body": json.dumps({"page_title": page_title})}

    except TimeoutException:
        logger.error("Selenium operation timed out.")
        return {"statusCode": 504, "body": json.dumps({"error": "Selenium operation timed out."})}

    except Exception as e:
        logger.exception("An error occurred:")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
    
    finally:
        logger.info("Lambda function finished.")

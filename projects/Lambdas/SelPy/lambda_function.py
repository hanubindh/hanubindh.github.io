import json
import logging
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Set log level to INFO (or DEBUG for more details)

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

        logger.info("Downloading and installing ChromeDriver...")
        driver = webdriver.Chrome(executable_path=ChromeDriverManager().install(), options=chrome_options)
        logger.info("ChromeDriver installed successfully.")

        logger.info("Navigating to https://annotationz.blogspot.com/...")
        driver.get("https://annotationz.blogspot.com/")
        logger.info("Navigation complete.")

        logger.info("Finding and clicking the 'Express' link...")
        express_link = driver.find_element(By.XPATH, "//a[contains(@href, '/search/label/Express')]")
        express_link.click()
        logger.info("'Express' link clicked.")

        logger.info("Retrieving page title...")
        page_title = driver.title
        logger.info(f"Page title: {page_title}")

        logger.info("Quitting WebDriver...")
        driver.quit()
        logger.info("WebDriver quit.")

        logger.info("Lambda function completed successfully.")
        return {
            "statusCode": 200,
            "body": json.dumps({"page_title": page_title}),
        }

    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
    finally:
        logger.info("Lambda function finished.")
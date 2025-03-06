# Use AWS Lambda base image for Python 3.9
FROM public.ecr.aws/lambda/python:3.9

# Set environment variables
ENV CHROME_DIR="/opt/chrome"
ENV CHROME_BIN="$CHROME_DIR/chrome-linux64/chrome"
ENV CHROMEDRIVER_DIR="/opt/chromedriver"
ENV PATH="$CHROMEDRIVER_DIR:$PATH"

# Install dependencies for Selenium
RUN yum install -y unzip curl && yum clean all

# Copy Chrome and ChromeDriver from local machine to the container
COPY chrome-bin/ $CHROME_DIR/
COPY chromedriver-bin/ $CHROMEDRIVER_DIR/

# Set execution permissions
RUN chmod +x $CHROME_BIN && chmod +x $CHROMEDRIVER_DIR/chromedriver-linux64/chromedriver

# Install Python dependencies
RUN pip install selenium webdriver_manager

# Copy Lambda function code
# Note: Since we use AWS Labda base image, LAMBDA_TASK_ROOT 
#       comes pre-configured (usually /var/task)
COPY lambda_function.py ${LAMBDA_TASK_ROOT}/

# Command to run the Lambda function
CMD ["lambda_function.lambda_handler"]

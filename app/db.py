import os
import logging
import psycopg2
from google.cloud import secretmanager

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_db_password():
    secret_name = os.getenv("DB_SECRET_NAME")
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")

    if not secret_name or not project_id:
        logger.error("DB_SECRET_NAME or GOOGLE_CLOUD_PROJECT environment variables are missing.")
        return None

    logger.info(f"Fetching secret for DB password from Secret Manager. Secret name: {secret_name}")
    client = secretmanager.SecretManagerServiceClient()
    secret_path = f"projects/{project_id}/secrets/{secret_name}/versions/latest"

    try:
        response = client.access_secret_version(name=secret_path)
        logger.info("Successfully fetched DB password.")
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        logger.error(f"Failed to fetch DB password: {e}")
        return None

def init_db():
    logger.info("Initializing database connection...")
    password = get_db_password()
    if password is None:
        logger.error("Database password could not be retrieved. Exiting database initialization.")
        return None
    
    try:
        logger.info(f"Connecting to the database {os.getenv('DB_NAME')} on host {os.getenv('DB_HOST')}")
        conn = psycopg2.connect(
            dbname=os.getenv("DB_NAME"),
            user="cache",
            password=password,
            host=os.getenv("DB_HOST"),
            port="5432"
        )
        logger.info("Database connection established.")
        
        with conn.cursor() as cur:
            cur.execute("CREATE TABLE IF NOT EXISTS cache (id SERIAL PRIMARY KEY, message TEXT)")
            conn.commit()
        logger.info("Cache table is ready.")
        
        return conn
    except Exception as e:
        logger.error(f"Failed to connect to the database: {e}")
        return None

def insert_message(conn, message):
    try:
        logger.info(f"Inserting message into database: {message}")
        with conn.cursor() as cur:
            cur.execute("INSERT INTO cache (message) VALUES (%s) RETURNING id", (message,))
            inserted_id = cur.fetchone()[0]
            conn.commit()
        logger.info(f"Message inserted with ID: {inserted_id}")
        return inserted_id
    except Exception as e:
        logger.error(f"Error inserting message into database: {e}")
        raise

def check_db_connection(conn):
    if conn is None:
        logger.error("No database connection. Cannot check connection status.")
        return False

    try:
        logger.info("Checking database connection...")
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
        logger.info("Database connection is healthy.")
        return True
    except Exception as e:
        logger.error(f"Database connection check failed: {e}")
        return False

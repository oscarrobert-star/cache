import logging
from flask import Flask, request, jsonify
from db import init_db, insert_message, check_db_connection
from pubsub_utils import publish_to_pubsub, pull_messages_and_insert, pull_messages_from_subscription
import os

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
db_conn = init_db()

@app.route("/health", methods=["GET"])
def health():
    logger.info("Health check requested.")
    if check_db_connection(db_conn):
        logger.info("Database is reachable.")
        return jsonify({"status": "ok"}), 200
    else:
        logger.error("Database is unreachable.")
        return jsonify({"status": "db unreachable"}), 500

@app.route("/publish", methods=["POST"])
def publish():
    data = request.json
    message = data.get("message")
    
    if not message:
        logger.warning("Publish request missing 'message'.")
        return jsonify({"error": "Missing 'message'"}), 400

    logger.info(f"Publishing message: {message}")
    publish_to_pubsub(message)
    logger.info("Message successfully published to Pub/Sub.")
    return jsonify({"status": "message published"}), 200

@app.route("/ingest", methods=["POST"])
def ingest():
    logger.info("Ingest request received. Pulling messages from Pub/Sub.")
    try:
        # Pull messages from Pub/Sub
        subscription_name = os.getenv("PUBSUB_SUBSCRIPTION")
        project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
        
        # Pull messages
        messages = pull_messages_from_subscription(project_id, subscription_name)
        
        if not messages:
            logger.warning("No messages received.")
            return jsonify({"message": "No messages to ingest."}), 200
        
        inserted_ids = []
        
        for msg in messages:
            try:
                # Assuming msg.data contains the message payload
                decoded_message = msg.message.data.decode("utf-8")
                logger.info(f"Inserting message into the database: {decoded_message}")
                
                # Insert message into the database and get the inserted ID
                inserted_id = insert_message(db_conn, decoded_message)
                inserted_ids.append(inserted_id)
                logger.info(f"Inserted message with ID: {inserted_id}")
            except Exception as e:
                logger.error(f"Error processing message: {e}")

        # Return the inserted IDs as a response
        return jsonify({"inserted_ids": inserted_ids}), 200

    except Exception as e:
        logger.error(f"Error during ingestion: {e}")
        return jsonify({"error": "Failed to ingest messages"}), 500

@app.route("/fetch", methods=["GET"])
def fetch():
    logger.info("Fetching messages from Pub/Sub.")
    subscription_name = os.getenv("PUBSUB_SUBSCRIPTION")
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    
    if not subscription_name or not project_id:
        logger.error("PUBSUB_SUBSCRIPTION or GOOGLE_CLOUD_PROJECT environment variables are missing.")
        return jsonify({"error": "Missing environment variables for Pub/Sub"}), 400

    messages = pull_messages_from_subscription(project_id, subscription_name)

    # Prepare the messages for response, extracting necessary data
    messages_data = [
        {"id": msg.message.message_id, "data": msg.message.data.decode("utf-8") if msg.message.data else None}
        for msg in messages
    ]
    
    return jsonify({"messages": messages_data}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

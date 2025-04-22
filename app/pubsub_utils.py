import os
import base64
import logging
from google.cloud import pubsub_v1

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def publish_to_pubsub(message):
    topic_name = os.getenv("PUBSUB_TOPIC")
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")

    if not topic_name or not project_id:
        logger.error("PUBSUB_TOPIC or GOOGLE_CLOUD_PROJECT environment variables are missing.")
        return

    logger.info(f"Publishing message to Pub/Sub topic: {topic_name} in project: {project_id}")

    try:
        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(project_id, topic_name)

        logger.info(f"Publishing message: {message}")
        future = publisher.publish(topic_path, message.encode("utf-8"))
        future.result()  

        logger.info("Message successfully published to Pub/Sub.")
    except Exception as e:
        logger.error(f"An error occurred while publishing the message: {e}")


def insert_message(conn, message):
    """Inserts a message into the database and returns the inserted ID."""
    with conn.cursor() as cur:
        cur.execute("INSERT INTO cache (message) VALUES (%s) RETURNING id", (message,))
        inserted_id = cur.fetchone()[0]
        conn.commit()
        return inserted_id


def pull_messages_and_insert(conn, max_messages=5):
    subscription_name = os.getenv("PUBSUB_SUBSCRIPTION")
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")

    if not subscription_name or not project_id:
        logger.error("PUBSUB_SUBSCRIPTION or GOOGLE_CLOUD_PROJECT environment variables are missing.")
        return []

    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_name)

    logger.info(f"Pulling up to {max_messages} messages from subscription: {subscription_path}")
    response = subscriber.pull(subscription=subscription_path, max_messages=max_messages, timeout=10)

    ack_ids = []
    inserted_ids = []

    for msg in response.received_messages:
        try:
            # Decode the message data
            decoded_msg = base64.b64decode(msg.message.data)

            try:
                decoded_msg_utf8 = decoded_msg.decode("utf-8")
                logger.info(f"Decoded message: {decoded_msg_utf8}")
            except UnicodeDecodeError:
                logger.warning(f"Message data is not valid UTF-8. Raw bytes: {decoded_msg}")
                continue  # Skip the message if decoding as UTF-8 fails

            # Insert the message into the database
            inserted_id = insert_message(conn, decoded_msg_utf8)
            inserted_ids.append(inserted_id)
            ack_ids.append(msg.ack_id)
        except Exception as e:
            logger.error(f"Failed to process message: {e}")

    if ack_ids:
        subscriber.acknowledge(subscription=subscription_path, ack_ids=ack_ids)
        logger.info(f"Acknowledged {len(ack_ids)} message(s).")

    return inserted_ids

def pull_messages_from_subscription(project_id: str, subscription_id: str, max_messages: int = 5):
    """Pulls and acknowledges messages from a Pub/Sub subscription."""
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_id)

    try:
        response = subscriber.pull(
            request={"subscription": subscription_path, "max_messages": max_messages}
        )

        received_messages = response.received_messages
        ack_ids = []

        if not received_messages:
            logging.info(f"No messages received from {subscription_path}.")
            return []

        for received_message in received_messages:
            message = received_message.message
            ack_ids.append(received_message.ack_id)

            try:
                # Decode the message data (assuming it's UTF-8 encoded)
                data_str = message.data.decode("utf-8")
                logging.info(f"Received message (ID: {message.message_id}): {data_str}")
            except UnicodeDecodeError:
                logging.warning(f"Received message (ID: {message.message_id}) with non-UTF-8 data. Raw bytes: {message.data}")
            except Exception as e:
                logging.error(f"Error processing message (ID: {message.message_id}): {e}")

            if message.attributes:
                logging.info(f"  Attributes for message (ID: {message.message_id}): {message.attributes}")

        if ack_ids:
            subscriber.acknowledge(
                request={"subscription": subscription_path, "ack_ids": ack_ids}
            )
            logging.info(f"Acknowledged {len(ack_ids)} messages from {subscription_path}.")

        return received_messages

    except Exception as e:
        logging.error(f"Error pulling messages from {subscription_path}: {e}")
        return []
    finally:
        subscriber.close()
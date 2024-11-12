import time
import requests
from collections import Counter

LOG_FILE_URL = "https://aiimagecapture.s3.us-east-1.amazonaws.com/classification_log.txt"
UNIQUE_ID_FILE = "/usr/iotc/local/data/unique-id"
METRIC_FILES = [
    "/usr/iotc/local/data/total_classifications",
    "/usr/iotc/local/data/unique_classifications",
    "/usr/iotc/local/data/avg_confidence",
    "/usr/iotc/local/data/most_common_classification",
    "/usr/iotc/local/data/max_confidence",
    "/usr/iotc/local/data/min_confidence"
]

def fetch_classification_log():
    print("Fetching classification log...")
    try:
        response = requests.get(LOG_FILE_URL)
        if response.status_code == 200:
            log_data = response.text.strip().split("\n")
            print(f"Log file fetched successfully with {len(log_data)} entries.")
            return log_data
        else:
            print(f"Failed to fetch log file: {response.status_code}")
            return []
    except requests.RequestException as e:
        print(f"Error fetching log file: {e}")
        return []

def read_device_id():
    print("Reading device ID...")
    try:
        with open(UNIQUE_ID_FILE, 'r') as file:
            device_id = file.read().strip()
            print(f"Device ID read successfully: {device_id}")
            return device_id
    except IOError as e:
        print(f"Error reading unique ID file: {e}")
        return None

def calculate_metrics(log_entries, device_id):
    print("Calculating metrics...")
    classifications = []
    confidences = []

    for entry in log_entries:
        parts = entry.split(", ")

        # Process only entries that have the device ID and match it explicitly
        if len(parts) == 4:
            entry_device_id, timestamp, label, confidence = parts
            if entry_device_id == device_id:
                classifications.append(label)
                confidences.append(float(confidence.replace("%", "")))
        else:
            print(f"Ignored log entry without device ID or incorrect format: {entry}")

    if not classifications:
        print("No classifications found for this device ID.")
        return [0, 0, 0, "None", 0, 0]

    total_classifications = len(classifications)
    unique_classifications = len(set(classifications))
    avg_confidence = sum(confidences) / len(confidences) if confidences else 0
    most_common_classification = Counter(classifications).most_common(1)[0][0]
    max_confidence = max(confidences)
    min_confidence = min(confidences)

    print(f"Metrics: Total={total_classifications}, Unique={unique_classifications}, "
          f"Avg={avg_confidence:.2f}, Most Common={most_common_classification}, "
          f"Max={max_confidence}, Min={min_confidence}")

    return [
        total_classifications,
        unique_classifications,
        avg_confidence,
        most_common_classification,
        max_confidence,
        min_confidence
    ]

def write_metrics_to_files(metrics):
    print("Writing metrics to files...")
    for i, metric in enumerate(metrics):
        try:
            # Ensure average confidence is written with 2 decimal places
            if METRIC_FILES[i] == "/usr/iotc/local/data/avg_confidence":
                metric = f"{metric:.2f}"  # Format to 2 decimal places for average confidence

            with open(METRIC_FILES[i], 'w') as file:
                file.write(str(metric))
            print(f"Metric written to {METRIC_FILES[i]}: {metric}")
        except IOError as e:
            print(f"Error writing to file {METRIC_FILES[i]}: {e}")

if __name__ == "__main__":
    device_id = read_device_id()
    if not device_id:
        print("Device ID not found. Exiting.")
    else:
        print("Starting log fetch and processing cycle...")
        log_entries = fetch_classification_log()

        if log_entries:
            print(f"Log entries found: {len(log_entries)}")

        print("Updating metrics...")
        metrics = calculate_metrics(log_entries, device_id)
        write_metrics_to_files(metrics)

        print("Script completed. Exiting.")

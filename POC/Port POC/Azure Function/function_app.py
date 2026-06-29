import azure.functions as func
import json
import random
from datetime import datetime
from azure.eventhub import EventHubProducerClient, EventData

app = func.FunctionApp()

EVENT_HUB_NAME = "portops-events"

producer = EventHubProducerClient.from_connection_string(
    conn_str="Endpoint=sb://portops-eventhub-ns.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Pp3QLNV7SUHSoNfoJbRwxvruLXU2bmJrU+AEhEhCoiE=",
    eventhub_name=EVENT_HUB_NAME
)


def get_base_event():

    return {
        "event_type": None,

        # Gate
        "TransactionID": None,
        "GateID": None,
        "TruckID": None,
        "ContainerID": None,
        "EntryTime": None,
        "Direction": None,

        # Crane
        "CraneEventID": None,
        "CraneID": None,
        "VesselCallID": None,
        "EventTime": None,
        "MovesCompleted": None,
        "DowntimeMinutes": None,

        # Yard
        "SnapshotID": None,
        "SnapshotTime": None,
        "YardBlockID": None,
        "OccupiedTEU": None,
        "CapacityTEU": None,

        # Common
        "CreatedUtc": datetime.utcnow().isoformat()
    }


def generate_gate_transaction():

    event = get_base_event()

    event.update({
        "event_type": "gate_transaction",
        "TransactionID": f"GT{random.randint(100000,999999)}",
        "GateID": random.choice(["G01", "G02"]),
        "TruckID": f"T{random.randint(1,50):03d}",
        "ContainerID": f"C{random.randint(1,50000):06d}",
        "EntryTime": datetime.utcnow().isoformat(),
        "Direction": random.choice(["Inbound", "Outbound"])
    })

    return event


def generate_crane_event():

    event = get_base_event()

    event.update({
        "event_type": "crane_event",
        "CraneEventID": f"CE{random.randint(100000,999999)}",
        "CraneID": random.choice(["QC01", "QC02", "QC03", "QC04"]),
        "VesselCallID": f"VC{random.randint(1,1000):05d}",
        "EventTime": datetime.utcnow().isoformat(),
        "MovesCompleted": random.randint(1, 10),
        "DowntimeMinutes": random.choice([0, 0, 0, 0, 5, 10])
    })

    return event


def generate_yard_snapshot():

    capacity = random.randint(1200, 2500)

    occupied = random.randint(
        int(capacity * 0.4),
        int(capacity * 0.95)
    )

    event = get_base_event()

    event.update({
        "event_type": "yard_snapshot",
        "SnapshotID": f"YS{random.randint(100000,999999)}",
        "SnapshotTime": datetime.utcnow().isoformat(),
        "YardBlockID": random.choice(
            ["Y01", "Y02", "Y03", "Y04", "Y05", "Y06"]
        ),
        "OccupiedTEU": occupied,
        "CapacityTEU": capacity
    })

    return event


@app.timer_trigger(
    schedule="*/10 * * * * *",
    arg_name="timer",
    run_on_startup=True
)
def stream_port_events(timer: func.TimerRequest):

    events = [
        generate_gate_transaction(),
        generate_crane_event(),
        generate_yard_snapshot()
    ]

    batch = producer.create_batch()

    for event in events:
        batch.add(EventData(json.dumps(event)))

    producer.send_batch(batch)

    print(
        f"{datetime.utcnow()} : Sent {len(events)} events"
    )
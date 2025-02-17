import math
import logging
from sllurp import llrp
from sllurp.llrp import LLRPReaderConfig, LLRPReaderClient, LLRP_DEFAULT_PORT

logging.getLogger().setLevel(logging.INFO)

def tag_report_cb(reader, tag_reports):
    for tag in tag_reports:
        print(f"Tag ID: {tag.id}, RSSI: {tag.rssi}")

config = LLRPReaderConfig({
    'tag_content_selector': {
        'EnableROSpecID': False,
        'EnableSpecIndex': False,
        'EnableInventoryParameterSpecID': False,
        'EnableAntennaID': True,
        'EnableChannelIndex': False,
        'EnablePeakRSSI': True,  # Enable RSSI
        'EnableFirstSeenTimestamp': False,
        'EnableLastSeenTimestamp': True,
        'EnableTagSeenCount': True,
        'EnableAccessSpecID': False,
    }
})

reader_ip = '192.168.1.100' #should be the address for Impinj R420
reader = LLRPReaderClient(reader_ip, LLRP_DEFAULT_PORT, config)

reader.add_tag_report_callback(tag_report_cb)
reader.connect()

try:
    # Block the program until interrupted (Ctrl+C)
    reader.join(None)
except (KeyboardInterrupt, SystemExit):
    # Stop inventory and disconnect when the program is interrupted
    print("Disconnecting...")
    reader.disconnect()
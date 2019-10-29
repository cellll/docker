from pywebhdfs.webhdfs import PyWebHdfsClient
import os
import cv2
import threading, logging, time
import multiprocessing
from kafka import KafkaConsumer, KafkaProducer
import cv2
import sys

KAFKA_BROKER=sys.argv[1]
KAFKA_TOPIC=sys.argv[2]


def read_hdfs_file(dir_path):
    files = hdfs.list_dir(dir_path)['FileStatuses']['FileStatus']
    
    for f in files:
        file_path = os.path.join(dir_path, f['pathSuffix'])
        if f['type'] == 'DIRECTORY':
            read_hdfs_file(file_path)
        else:
            image_str = hdfs.read_file(file_path)
            producer.send(KAFKA_TOPIC, image_str)

hdfs = PyWebHdfsClient(host='192.168.1.101', port='50070', user_name='hdfs')
producer = KafkaProducer(bootstrap_servers=KAFKA_BROKER)

read_hdfs_file('/test')

from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, to_json, struct
from pyspark.sql.types import StructType, StringType, IntegerType, FloatType

# Initialize Spark session
spark = SparkSession.builder \
            .appName("SparkProcessor") \
            .master("local[4]") \
            .config("spark.jars", "jars\spark-sql-kafka-0-10_2.12-3.4.0.jar,jars\kafka-clients-3.4.0.jar") \
            .getOrCreate()

# Kafka broker and topics
kafka_brokers = "192.168.10.139:9093"
input_topics = "accident-event"
output_topic = "processed-accident-event"

# Read data from Kafka
raw_stream = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_brokers) \
    .option("subscribe", input_topics) \
    .option("startingOffsets", "earliest") \
    .load()

# Define schema for the JSON data
schema = StructType() \
    .add("ID", StringType()) \
    .add("Source", StringType()) \
    .add("Severity", IntegerType()) \
    .add("Start_Time", StringType()) \
    .add("End_Time", StringType()) \
    .add("Start_Lat", FloatType()) \
    .add("Start_Lng", FloatType())

# Deserialize JSON and process the stream
events = raw_stream.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*")

# Example processing: filter by severity
processed_events = events.filter(col("Severity") >= 3)

# Serialize the processed data back to JSON
output_stream = processed_events.select(
    to_json(struct(*processed_events.columns)).alias("value")
)

# Write processed data back to Kafka
query = output_stream.writeStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_brokers) \
    .option("topic", output_topic) \
    .option("checkpointLocation", "/checkpoints/processed-events") \
    .start()

query.awaitTermination()

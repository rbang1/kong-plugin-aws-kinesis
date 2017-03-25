# AWS Kinesis Kong Plugin

Plugin to write records to AWS Kinesis stream. 

## Schema

 * aws_key - Aws Access Key 
 * aws_secret - Aws Secret Key
 * aws_region - Aws Region
 * stream_name - Kinesis Stream Name
 * partition_key_path - Json Path expression to set partition key value, if missing uses md5 hash of the input parameters
 * timeout - Connection timeout
 * keepalive - Connection keepalive
 * aws_debug - Debug flag

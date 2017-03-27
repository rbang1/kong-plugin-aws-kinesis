# AWS Kinesis Kong Plugin

Plugin to write records to AWS Kinesis stream.

## Installation

 * Install via luarocks `luarocks install kong-plugin-aws-kinesis`
 * add `aws-kinesis` plugin to custom_plugins in kong configuration
 * Restart kong

## Configuration

 * aws_key - (required) Aws Access Key
 * aws_secret - (required) Aws Secret Key
 * aws_region - (required) Aws Region
 * stream_name - (required) Kinesis Stream Name
 * partition_key_path - JSONPath expression to set partition key value, if missing uses md5 hash of the input parameters
 * data_template - Json template for generating json data to be posted to Kinesis 
 * timeout - Connection timeout in ms, default 60000
 * keepalive - Connection keepalive in ms, default 60000
 * aws_debug - Debug flag, default false

 Similar to the AWS-Lambda Kong plugin, when configuring the api that uses this plugin, use a fake upstream url.
 The response will be returned by the plugin itself without proxying the request to any upstream service. This means that whatever upstream_url has been set on the API it will ultimately never be used.

 Only POST requests with content-type `application/json` or `application/x-www-form-urlencoded` are functional. Response from Kinesis is passed through. You can use response transformer plugin to further customize the response.

## Partition Key

 By default, this plugin uses md5 hash of the `data` payload as the partition key on Kinesis Put Record 
 request. The partition key determines the shard selection in Kinesis. Optionally you can specify a JSONPath expression (http://goessner.net/articles/JsonPath/) in `partition_key_path` configuration. The JSONPath expression works for selecting request parameters for both `application/x-www-form-urlencoded` and
 `application/json` type of requests. 

### Examples

 * if input is url encoded as `param1=value1&param2=value2`, specifying `partition_key_path` as `$.param2` will
 use `value2` as the value for partition key.
 * if input is json as `{"param1": "value1", "param2": {"sub": "value2"}}`, specifying `partition_key_path` as `$.param2.sub` will use `value2` as partition key.

## Data Template

 By default, all the request parameters are converted to json and passed through to Kinesis. Optionally you can 
 provide a data template to create a data json that can use values from request parameters and headers. For more details - check the comments for `M.transform` function under `src/jsontransform.lua`.

## Running Tests

 Run specs using `./bin/busted` from repo. Running the blackbox `awskinesis_spec.lua` requires a pre-existing Kinesis Stream. Specify AWS Key/Secret, Stream name, Region in kong_tests.conf or preferably create your own configuration file and provide its location in `TEST_CONF_PATH` environment variable.

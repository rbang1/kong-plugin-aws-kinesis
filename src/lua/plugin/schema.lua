return {
  fields = {
    timeout = {type = "number", default = 60000, required = true},
    keepalive = {type = "number", default = 60000, required = true},
    aws_key = {type = "string", required = true},
    aws_secret = {type = "string", required = true},
    aws_region = {type = "string", required = true},
    stream_name = {type = "string", required = true},
    partition_key_path = {type = "string", required = false},
    data_template = {type = "string", required = false},
    aws_debug = {type = "boolean", default = false}
  }
}

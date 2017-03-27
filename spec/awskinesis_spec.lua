local PLUGIN_NAME = "aws-kinesis"

local helpers = require "spec.helpers"
local pl_config = require "pl.config"
local cjson = require "cjson.safe"

describe("aws-kinesis", function()
  local client

  setup(function()
    local conf = pl_config.read(helpers.test_conf_path)

    local api1 = assert(helpers.dao.apis:insert { 
        name = "kinesis-test-1", 
        hosts = { "kinesistest1.com" }, 
        upstream_url = "http://mockbin.com",
    })

    local api2 = assert(helpers.dao.apis:insert { 
        name = "kinesis-test-2", 
        hosts = { "kinesistest2.com" }, 
        upstream_url = "http://mockbin.com",
    })

    assert(helpers.dao.plugins:insert {
      api_id = api1.id,
      name = PLUGIN_NAME,
      config = {
        aws_key = conf.aws_key,
        aws_secret = conf.aws_secret,
        aws_region = conf.aws_region,
        stream_name = conf.aws_kinesis_stream
      }
    })

    assert(helpers.dao.plugins:insert {
      api_id = api2.id,
      name = PLUGIN_NAME,
      config = {
        aws_key = conf.aws_key,
        aws_secret = conf.aws_secret,
        aws_region = conf.aws_region,
        stream_name = conf.aws_kinesis_stream,
        data_template = '{"ip": "clientip|", "payload": "param|$", "host": "header|$.host"}',
        partition_key_path = '$.uid'
      }
    })

    -- start kong, while setting the config item `custom_plugins` to make sure our
    -- plugin gets loaded
    assert(helpers.start_kong {custom_plugins = PLUGIN_NAME})
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function ()
    client:close()
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  describe("when used without any transformations", function()
    local host = "kinesistest1.com"

    it("inserts into kinesis stream with POST params", function()
      local res = assert(client:send {
        method = "POST",
        path = "/post",
        headers = {
          ["Host"] = host,
          ["Content-Type"] = "application/x-www-form-urlencoded"
        },
        body = {
          key1 = "form_post1",
          key2 = "form_post2",
          key3 = "form_post3"
        }
      })
      local body = assert.res_status(200, res)
      assert.is_string(res.headers["x-amzn-RequestId"])
      assert.is_not_nil(body)
      local bodyJson = cjson.decode(body)
      assert.is_not_nil(bodyJson.ShardId)
      assert.is_not_nil(bodyJson.SequenceNumber)
    end)

    it("inserts into kinesis stream with POST Json", function()
      local res = assert(client:send {
        method = "POST",
        path = "/post",
        headers = {
          ["Host"] = host,
          ["Content-Type"] = "application/json"
        },
        body = {
          key1 = "json_post1",
          key2 = "json_post2",
          key3 = "json_post3"
        }
      })
      local body = assert.res_status(200, res)
      assert.is_string(res.headers["x-amzn-RequestId"])
      assert.is_not_nil(body)
      local bodyJson = cjson.decode(body)
      assert.is_not_nil(bodyJson.ShardId)
      assert.is_not_nil(bodyJson.SequenceNumber)
    end)
  end)

  describe("when used with transformations", function()
    local host = "kinesistest2.com"

    describe("when partition key is not in request", function()
      it("inserts into kinesis stream with POST params", function()
        local res = assert(client:send {
          method = "POST",
          path = "/post",
          headers = {
            ["Host"] = host,
            ["Content-Type"] = "application/x-www-form-urlencoded"
          },
          body = {
            key1 = "form_post1",
            key2 = "form_post2",
            key3 = "form_post3"
          }
        })
        local body = assert.res_status(200, res)
        assert.is_string(res.headers["x-amzn-RequestId"])
        assert.is_not_nil(body)
        local bodyJson = cjson.decode(body)
        assert.is_not_nil(bodyJson.ShardId)
        assert.is_not_nil(bodyJson.SequenceNumber)
      end)

      it("inserts into kinesis stream with POST Json", function()
        local res = assert(client:send {
          method = "POST",
          path = "/post",
          headers = {
            ["Host"] = host,
            ["Content-Type"] = "application/json"
          },
          body = {
            key1 = "json_post1",
            key2 = "json_post2",
            key3 = "json_post3"
          }
        })
        local body = assert.res_status(200, res)
        assert.is_string(res.headers["x-amzn-RequestId"])
        assert.is_not_nil(body)
        local bodyJson = cjson.decode(body)
        assert.is_not_nil(bodyJson.ShardId)
        assert.is_not_nil(bodyJson.SequenceNumber)
      end)
    end)

    describe("when partition key is in request", function()
      it("inserts into kinesis stream with POST params", function()
        local res = assert(client:send {
          method = "POST",
          path = "/post",
          headers = {
            ["Host"] = host,
            ["Content-Type"] = "application/x-www-form-urlencoded"
          },
          body = {
            key1 = "form_post1",
            key2 = "form_post2",
            key3 = "form_post3",
            uid = "form_user_id"
          }
        })
        local body = assert.res_status(200, res)
        assert.is_string(res.headers["x-amzn-RequestId"])
        assert.is_not_nil(body)
        local bodyJson = cjson.decode(body)
        assert.is_not_nil(bodyJson.ShardId)
        assert.is_not_nil(bodyJson.SequenceNumber)
      end)

      it("inserts into kinesis stream with POST Json", function()
        local res = assert(client:send {
          method = "POST",
          path = "/post",
          headers = {
            ["Host"] = host,
            ["Content-Type"] = "application/json"
          },
          body = {
            key1 = "json_post1",
            key2 = "json_post2",
            key3 = "json_post3",
            uid = "json_user_id"
          }
        })
        local body = assert.res_status(200, res)
        assert.is_string(res.headers["x-amzn-RequestId"])
        assert.is_not_nil(body)
        local bodyJson = cjson.decode(body)
        assert.is_not_nil(bodyJson.ShardId)
        assert.is_not_nil(bodyJson.SequenceNumber)
      end)
    end)

  end)

end)
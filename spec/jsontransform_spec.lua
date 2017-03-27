local jsont = require('jsontransform')

describe('jsontransform', function()
  local params, headers, clientip

  before_each(function()
    params = {param1 = "value1", param2 = "value2"}
    headers = {header1 = "header1", header2 = "header2"}
    clientip = "11.1.1.1"
  end)

  describe('when template is empty', function()
    it('returns empty template', function()
      assert.is_nil(jsont.transform(nil, params, headers, clientip))
    end)
  end)

  describe('when template does not refer to params, headers or clientid', function()
    it('returns back the template when template is table', function()
      local template = {a = "apple", b = "bat", c = "cat"}
      assert.are.same(template, jsont.transform(template, params, headers, clientip))
    end)

    it('returns back the template when template is string', function()
      local template = "apple"
      assert.are.same(template, jsont.transform(template, params, headers, clientip))
    end)

    it('returns back the template when template is string', function()
      local template = 1.3
      assert.are.same(template, jsont.transform(template, params, headers, clientip))
    end)

    it('returns back the template when template is boolean', function()
      local template = true
      assert.are.same(template, jsont.transform(template, params, headers, clientip))
    end)
  end)

  describe('when template refers to missing param', function()
    it('replaces missing param with nil', function()
      local template = {a = "param|$.param3"}
      local transform = jsont.transform(template, params, headers, clientip)
      assert.are.same({a = nil}, transform)
    end)
  end)

  describe('when no parameters exist', function()
    it('replaces all param references with nil', function()
      local template = {a = "param|$.param1", b = "param|$.param2", c = "header|$.header1"}
      local transform = jsont.transform(template, nil, headers, clientip)
      assert.are.same({a = nil, b = nil, c = "header1"}, transform)
    end)
  end)

  describe('when template refers to missing header', function()
    it('replaces missing header with nil', function()
      local template = {a = "header|$.header3"}
      local transform = jsont.transform(template, params, headers, clientip)
      assert.are.same({a = nil}, transform)
    end)
  end)

  describe('when no headers exist', function()
    it('replaces all header references with nil', function()
      local template = {a = "header|$.header1", b = "header|$.header2", c = "param|$.param1"}
      local transform = jsont.transform(template, params, nil, clientip)
      assert.are.same({a = nil, b = nil, c = "value1"}, transform)
    end)
  end)

  describe('when client ip is missing', function()
    it('replaces with nil', function()
      local template = {a = "clientip|", b = "param|$.param2", c = "header|$.header1"}
      local transform = jsont.transform(template, params, headers, nil)
      assert.are.same({a = nil, b = "value2", c = "header1"}, transform)
    end)
  end)

  describe('when template deep references params and headers', function()
    it('transforms json', function()
      local template = { 
        book = {author = "param|$.libro.autor", price = "param|$.libro.precio"},
        host = {server = "header|$.headers.host"},
        user = {ip = "clientip|"},
        version = {str = "value|1.2", number = 1.2}
      }
      params = {libro = {autor = 'Garcia Lorca', precio = 20.0}}
      headers = {headers = {host = 'amazon.com'}}
      local transform = jsont.transform(template, params, headers, clientip)
      local expected = {
        book = {author = params['libro']['autor'], price = params['libro']['precio']},
        host = {server = headers['headers']['host']},
        user = {ip = clientip},
        version = {str = "1.2", number = 1.2}
      }
      assert.are.same(expected, transform)
    end)
  end)
end)
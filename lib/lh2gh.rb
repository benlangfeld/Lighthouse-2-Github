require 'lighthouse-api'
require 'octopi'

module Lh2gh
  # Your code goes here...
end


# Horrible monkey patch to Octopi - should be able to get rid of this soon: https://github.com/fcoury/octopi/issues/55
module Octopi
  class Api
    def submit(path, params = {}, klass=nil, format = :yaml, &block)
      # Ergh. Ugly way to do this. Find a better one!
      cache = params.delete(:cache)
      cache = true if cache.nil?
      cache = false
      params.each_pair do |k,v|
        if path =~ /:#{k.to_s}/
          params.delete(k)
          path = path.gsub(":#{k.to_s}", v)
        end
      end
      begin
        key = "#{Api.api.class.to_s}:#{path}"
        resp = if cache
          APICache.get(key, :cache => 61) do
            yield(path, params, format, auth_parameters)
          end
        else
          yield(path, params, format, auth_parameters)
        end
      rescue Net::HTTPBadResponse
        raise RetryableAPIError
      end

      raise RetryableAPIError, resp.code.to_i if RETRYABLE_STATUS.include? resp.code.to_i
      # puts resp.code.inspect
      raise NotFound, klass || self.class if resp.code.to_i == 404
      raise APIError,
        "GitHub returned status #{resp.code}" unless ((resp.code.to_i == 200) || (resp.code.to_i == 201))
      # FIXME: This fails for showing raw Git data because that call returns
      # text/html as the content type. This issue has been reported.

      # It happens, in tests.
      return resp if resp.headers.empty?
      content_type = Array === resp.headers['content-type'] ? resp.headers['content-type'] : [resp.headers['content-type']]
      ctype = content_type.first.split(";").first
      raise FormatError, [ctype, format] unless CONTENT_TYPE[format.to_s].include?(ctype)
      if format == 'yaml' && resp['error']
        raise APIError, resp['error']
      end
      resp
    end
  end
end

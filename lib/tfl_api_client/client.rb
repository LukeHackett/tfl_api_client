#
# Copyright (c) 2015 - 2017 Luke Hackett
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'json'
require 'logger'
require 'openssl'
require 'net/http'
require 'tfl_api_client/exceptions'

module TflApi
  # This is the client class that allows direct access to the subclasses and to
  # the TFL API. The class contains methods that perform GET and POST requests
  # to the API.
  #
  class Client

    # Parameters that are permitted as options while initializing the client
    VALID_PARAMS = %w( app_id app_key host logger log_level log_location ).freeze

    # HTTP verbs supported by the Client
    VERB_MAP = {
      get: Net::HTTP::Get
    }

    # Client accessors
    attr_reader :app_id, :app_key, :host, :logger, :log_level, :log_location

    # Initialize a Client object with TFL API credentials
    #
    # @param args [Hash] Arguments to connect to TFL API
    #
    # @option args [String] :app_id  the application id generated by registering an app with TFL
    # @option args [String] :app_key the application key generated by registering an app with TFL
    # @option args [String] :host    the API's host url - defaults to api.tfl.gov.uk
    #
    # @return [TflApi::Client] a client object to the TFL API
    #
    # @raise [ArgumentError] when required options are not provided.
    #
    def initialize(args)
      args.each do |key, value|
        if value && VALID_PARAMS.include?(key.to_s)
          instance_variable_set("@#{key.to_sym}", value)
        end
      end if args.is_a? Hash

      # Ensure the Application ID and Key is given
      raise ArgumentError, "Application ID (app_id) is required to interact with TFL's APIs" unless app_id
      raise ArgumentError, "Application Key (app_key) is required to interact with TFL's APIs" unless app_key

      # Set client defaults
      @host ||= 'https://api.tfl.gov.uk'
      @host = URI.parse(@host)

      # Create a global Net:HTTP instance
      @http = Net::HTTP.new(@host.host, @host.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Logging
      if @logger
        raise ArgumentError, 'logger parameter must be a Logger object' unless @logger.is_a?(Logger)
        raise ArgumentError, 'log_level cannot be set if using custom logger' if @log_level
        raise ArgumentError, 'log_location cannot be set if using custom logger' if @log_location
      else
        @log_level = Logger::INFO unless @log_level
        @log_location = STDOUT unless @log_location
        @logger = Logger.new(@log_location)
        @logger.level = @log_level
        @logger.datetime_format = '%F T%T%z'
        @logger.formatter = proc do |severity, datetime, _progname, msg|
          "[%s] %-6s %s \r\n" %  [datetime, severity, msg]
        end
      end
    end

    # Creates an instance to the AccidentStats class by passing a reference to self
    #
    # @return [TflApi::Client::AccidentStats] An object to AccidentStats subclass
    #
    def accident_stats
      TflApi::Client::AccidentStats.new(self)
    end

    # Creates an instance to the AirQuality class by passing a reference to self
    #
    # @return [TflApi::Client::AirQuality] An object to AirQuality subclass
    #
    def air_quality
      TflApi::Client::AirQuality.new(self)
    end

    # Creates an instance to the BikePoint class by passing a reference to self
    #
    # @return [TflApi::Client::BikePoint] An object to BikePoint subclass
    #
    def bike_point
      TflApi::Client::BikePoint.new(self)
    end

    # Creates an instance to the Cycle class by passing a reference to self
    #
    # @return [TflApi::Client::Cycle] An object to Cycle subclass
    #
    def cycle
      TflApi::Client::Cycle.new(self)
    end

    # Performs a HTTP GET request to the api, based upon the given URI resource
    # and any additional HTTP query parameters. This method will automatically
    # inject the mandatory application id and application key HTTP query
    # parameters.
    #
    # @return [hash] HTTP response as a hash
    #
    def get(path, query={})
      request_json :get, path, query
    end

    # Overrides the inspect method to prevent the TFL Application ID and Key
    # credentials being shown when the `inspect` method is called. The method
    # will only print the important variables.
    #
    # @return [String] String representation of the current object
    #
    def inspect
      "#<#{self.class.name}:0x#{(self.__id__ * 2).to_s(16)} " +
          "@host=#{host.to_s}, " +
          "@log_level=#{log_level}, " +
          "@log_location=#{log_location.inspect}>"
    end

    private

    # This method requests the given path via the given resource with the additional url
    # params. All successful responses will yield a hash of the response body, whilst
    # all other response types will raise a child of TflApi::Exceptions::ApiException.
    # For example a 404 response would raise a TflApi::Exceptions::NotFound exception.
    #
    # @param method [Symbol] The type of HTTP request to make, e.g. :get
    # @param path [String] the path of the resource (not including the base url) to request
    # @param params [Hash]
    #
    # @return [HTTPResponse] HTTP response object
    #
    # @raise [TflApi::Exceptions::ApiException] when an error has occurred with TFL's API
    #
    def request_json(method, path, params)
      response = request(method, path, params)

      if response.kind_of? Net::HTTPSuccess
        parse_response_json(response)
      else
        raise_exception(response)
      end
    end

    # Creates and performs HTTP request by the request medium to the given path
    # with any additional uri parameters. The method will return the HTTP
    # response object upon completion.
    #
    # @param method [Symbol] The type of HTTP request to make, e.g. :get
    # @param path [String] the path of the resource (not including the base url) to request
    # @param params [Hash] Additional url params to be added to the request
    #
    # @return [HTTPResponse] HTTP response object
    #
    def request(method, path, params)
      full_path = format_request_uri(path, params)
      request = VERB_MAP[method.to_sym].new(full_path)
      # TODO - Enable when supporting other HTTP Verbs
      # request.set_form_data(params) unless method == :get

      @logger.debug "#{method.to_s.upcase} #{path}"
      @http.request(request)
    end

    # Returns a full, well-formatted HTTP request URI that can be used to directly
    # interact with the TFL API.
    #
    # @param path [String] the path of the resource (not including the base url) to request
    # @param params [Hash] Additional url params to be added to the request
    #
    # @return [String] Full HTTP request URI
    #
    def format_request_uri(path, params)
      params.merge!({app_id: app_id, app_key: app_key})
      params_string = URI.encode_www_form(params)
      URI::HTTPS.build(host: host.host, path: path, query: params_string)
    end

    # Parses the given response body as JSON, and returns a hash representation of the
    # the response. Failure to successfully parse the response will result in an
    # TflApi::Exceptions::ApiException being raised.
    #
    # @param response [HTTPResponse] the HTTP response object
    #
    # @return [HTTPResponse] HTTP response object
    #
    # @raise [TflApi::Exceptions::ApiException] when trying to parse a malformed JSON response
    #
    def parse_response_json(response)
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        raise TflApi::Exceptions::ApiException, logger, "Invalid JSON returned from #{host.host}"
      end
    end

    # Raises a child of TflApi::Exceptions::ApiException based upon the response code being
    # classified as non-successful, i.e. a non 2xx response code. All non-successful
    # responses will raise an TflApi::Exceptions::ApiException by default. Popular
    # non-successful response codes are mapped to internal exceptions, for example a 404
    # response code would raise TflApi::Exceptions::NotFound.
    #
    # @param response [HTTPResponse] the HTTP response object
    #
    # @raise [TflApi::Exceptions::ApiException] when an error has occurred with TFL's API
    #
    def raise_exception(response)
      case response.code.to_i
        when 401
          raise TflApi::Exceptions::Unauthorized, logger
        when 403
          raise TflApi::Exceptions::Forbidden, logger
        when 404
          raise TflApi::Exceptions::NotFound, logger
        when 500
          raise TflApi::Exceptions::InternalServerError, logger
        when 503
          raise TflApi::Exceptions::ServiceUnavailable, logger
        else
          raise TflApi::Exceptions::ApiException, logger, "non-successful response (#{response.code}) was returned"
      end
    end
  end
end

require_relative 'match_builder'
require_relative 'url_match_builder'

module WireMockMapper
  class RequestBuilder
    def initialize(configuration = nil)
      @options = {}
      @options[:headers] = configuration.request_headers if configuration
    end

    HTTP_VERBS = %w(ANY DELETE GET HEAD OPTIONS POST PUT TRACE).freeze
    private_constant :HTTP_VERBS

    HTTP_VERBS.each do |verb|
      define_method("receives_#{verb.downcase}") do
        @options[:method] = verb
        self
      end
    end

    # Expect basic auth
    # @param username [String] username to expect
    # @param password [String] password to expect
    # @return [RequestBuilder] request builder for chaining
    def with_basic_auth(username, password)
      @options[:basicAuth] = { username: username, password: password }
      self
    end

    # Expect body
    # @return [MatchBuilder] match builder to declare the match on the body
    def with_body
      @options[:bodyPatterns] ||= []
      match_builder = MatchBuilder.new(self)
      @options[:bodyPatterns] << match_builder
      match_builder
    end

    # Expect cookie
    # @param key [String] the cookie key
    # @return [MatchBuilder] match builder to declare the match on the cookie
    def with_cookie(key)
      @options[:cookies] ||= {}
      @options[:cookies][key] = MatchBuilder.new(self)
    end

    # Expect header
    # @param key [String] the header key
    # @return [MatchBuilder] match builder to declare the match on the header
    def with_header(key)
      @options[:headers] ||= {}
      @options[:headers][key] = MatchBuilder.new(self)
    end

    # Expect query param
    # @param key [String] the query param key
    # @return [MatchBuilder] match builder to declare the match on the query param
    def with_query_param(key)
      @options[:queryParameters] ||= {}
      @options[:queryParameters][key] = MatchBuilder.new(self)
    end

    # Expect url path with query params
    # @return [UrlMatchBuilder] url match builder to declare the match on the url
    def with_url
      @url_match = UrlMatchBuilder.new(self)
    end

    # Expect url path only
    # @return [UrlMatchBuilder] url match builder to declare the match on the url
    def with_url_path
      @url_match = UrlMatchBuilder.new(self, true)
    end

    def to_hash(*)
      options_with_url_match = @options.merge(@url_match.to_hash) if @url_match
      options_with_url_match || @options
    end

    def to_json(*)
      to_hash.to_json
    end
  end
end

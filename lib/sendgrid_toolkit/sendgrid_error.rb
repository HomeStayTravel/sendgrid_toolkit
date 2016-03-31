module SendgridToolkit
  class AuthenticationFailed < StandardError; end
  class NoAPIKeySpecified < StandardError; end
  class NoAPIUserSpecified < StandardError; end
  class UnsubscribeEmailAlreadyExists < StandardError; end
  class UnsubscribeEmailDoesNotExist < StandardError; end
  class SendEmailError < StandardError; end
  class EmailDoesNotExist < StandardError; end
  class SendgridServerError < StandardError; end
  class APIError < StandardError; end
  class GroupsError < StandardError; end
  class NoGroupIdSpecified < StandardError; end

  class RateLimitError < StandardError

    attr_reader :limit
    attr_reader :reset

    def initialize(limit, reset)
      @limit = limit
      @reset = reset
    end

  end

end

require File.expand_path("#{File.dirname(__FILE__)}/../../../helper")

describe SendgridToolkit::V3::AbstractSendgridClient do
  before do
    backup_env
  end
  after do
    restore_env
  end

  describe '#api_post' do

    it "throws error when authentication fails" do
      FakeWeb.register_uri(:post, %r|https://fakeuser:fakepass@#{REGEX_ESCAPED_BASE_URI_V3}/profile/get|, :body => '{"error":{"code":401,"message":"Permission denied, wrong credentials"}}')
      @obj = SendgridToolkit::V3::AbstractSendgridClient.new("fakeuser", "fakepass")
      lambda {
        @obj.send(:api_post, "profile/get", {})
      }.should raise_error SendgridToolkit::AuthenticationFailed
    end

    it "throws error when sendgrid response is a server error" do
      FakeWeb.register_uri(:post, %r|https://fakeuser:fakepass@#{REGEX_ESCAPED_BASE_URI_V3}/profile/get|, :body => '{}', :status => ['500', 'Internal Server Error'])
      @obj = SendgridToolkit::V3::AbstractSendgridClient.new("fakeuser", "fakepass")
      lambda {
        @obj.send(:api_post, "profile/get", {})
      }.should raise_error SendgridToolkit::SendgridServerError
    end

    it "throws error when sendgrid response is an API error" do
      FakeWeb.register_uri(:post, %r|https://fakeuser:fakepass@#{REGEX_ESCAPED_BASE_URI_V3}/stats/get|, :body => '{"error": "error in end_date: end date is in the future"}', :status => ['400', 'Bad Request'])
      @obj = SendgridToolkit::V3::AbstractSendgridClient.new("fakeuser", "fakepass")
      lambda {
        @obj.send(:api_post, "stats/get", {})
      }.should raise_error SendgridToolkit::APIError, 'error in end_date: end date is in the future'
    end

    it "throws error when sendgrid response is a rate limit error" do
      FakeWeb.register_uri(:post, %r|https://fakeuser:fakepass@#{REGEX_ESCAPED_BASE_URI_V3}/stats/get|,
        'X-RateLimit-Limit' => 500,
        'X-RateLimit-Remaining' => 0,
        'X-RateLimit-Reset' => 1392815263,
        :body => '{"errors": [{"field": null, "message": "too many requests"}]}',
        :status => ['429', 'Too many requests']
      )
      @obj = SendgridToolkit::V3::AbstractSendgridClient.new("fakeuser", "fakepass")
      lambda {
        @obj.send(:api_post, "stats/get", {})
      }.should raise_error { |error|
        error.class.should eq(SendgridToolkit::RateLimitError)
        error.limit.should eq(500)
        error.reset.should eq(1392815263)
      }
    end

  end

  describe "#initialize" do
    after(:each) do
      SendgridToolkit.api_user = nil
      SendgridToolkit.api_key = nil
    end
    it 'stores api credentials when passed in' do
      ENV['SMTP_USERNAME'] = 'env_username'
      ENV['SMTP_PASSWORD'] = 'env_apikey'

      @obj = SendgridToolkit::V3::AbstractSendgridClient.new('username', 'apikey')
      @obj.instance_variable_get('@api_user').should == 'username'
      @obj.instance_variable_get('@api_key').should == 'apikey'
    end
    it 'uses module level user and key if they are set' do
      SendgridToolkit.api_user = 'username'
      SendgridToolkit.api_key = 'apikey'

      SendgridToolkit.api_key.should == 'apikey'
      SendgridToolkit.api_user.should == 'username'

      @obj = SendgridToolkit::V3::AbstractSendgridClient.new
      @obj.instance_variable_get('@api_user').should == 'username'
      @obj.instance_variable_get('@api_key').should == 'apikey'
    end
    it 'resorts to environment variables when no credentials specified' do
      ENV['SMTP_USERNAME'] = 'env_username'
      ENV['SMTP_PASSWORD'] = 'env_apikey'

      @obj = SendgridToolkit::V3::AbstractSendgridClient.new()
      @obj.instance_variable_get('@api_user').should == 'env_username'
      @obj.instance_variable_get('@api_key').should == 'env_apikey'
    end
    it 'throws error when no credentials are found' do
      ENV['SMTP_USERNAME'] = nil
      ENV['SMTP_PASSWORD'] = nil

      lambda {
        @obj = SendgridToolkit::V3::AbstractSendgridClient.new()
      }.should raise_error SendgridToolkit::NoAPIUserSpecified

      lambda {
        @obj = SendgridToolkit::V3::AbstractSendgridClient.new(nil, 'password')
      }.should raise_error SendgridToolkit::NoAPIUserSpecified

      lambda {
        @obj = SendgridToolkit::V3::AbstractSendgridClient.new('user', nil)
      }.should raise_error SendgridToolkit::NoAPIKeySpecified
    end
  end
end

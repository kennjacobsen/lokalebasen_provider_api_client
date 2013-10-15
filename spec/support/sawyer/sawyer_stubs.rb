module SawyerStubs
  def agent_mock(faraday_stubs)
    Sawyer::Agent.new "http://lokalebasen.dev/api/provider" do |conn|
      conn.builder.handlers.delete(Faraday::Adapter::NetHttp)
      conn.adapter :test, faraday_stubs
    end
  end

  def stub_get(faraday_stubs, url, status, response_hash)
    stub_request(:get, faraday_stubs, url, status, response_hash)
  end

  def stub_post(faraday_stubs, url, status, response_hash)
    stub_request(:post, faraday_stubs, url, status, response_hash)
  end

  def stub_put(faraday_stubs, url, status, response_hash)
    stub_request(:put, faraday_stubs, url, status, response_hash)
  end

  def stub_delete(faraday_stubs, url, status, response_hash)
    stub_request(:delete, faraday_stubs, url, status, response_hash)
  end

  def stub_request(method, faraday_stubs, url, status, response_hash)
    faraday_stubs.public_send(method, url) do |env|
      [
        status,
        {'Content-Type' => 'application/json'},
        Sawyer::Agent.encode(response_hash)
      ]
    end
  end
end

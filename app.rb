require "sinatra/base"
require "json"

# Flush logs immediately so docker compose logs shows each request.
$stdout.sync = true

class TicketApp < Sinatra::Base
  set :instance_name, ENV.fetch("INSTANCE_NAME", "tickets-1")

  # "tickets" is the hostname our client uses on the Compose network.
  set :host_authorization, { permitted_hosts: ["tickets", "localhost"] }

  before do
    content_type :json
    headers "X-Backend" => settings.instance_name
  end

  get "/tickets" do
    JSON.generate(
      event: "Ruby Night",
      tickets_available: 10,
      instance: settings.instance_name,
      experiment: request.env["HTTP_X_EXPERIMENT"]
    )
  end

  not_found do
    JSON.generate(error: "not_found")
  end

  after do
    # The marker connects this log entry to the client's response.
    puts JSON.generate(
      instance: settings.instance_name,
      method: request.request_method,
      path: request.path_info,
      host: request.host,
      experiment: request.env["HTTP_X_EXPERIMENT"],
      status: response.status
    )
  end
end

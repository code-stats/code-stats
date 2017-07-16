defmodule CodeStats.CORS do
  alias CodeStats.Utils

  use Corsica.Router,
    origins: {__MODULE__, :is_allowed_origin}

  # User profile API is available to anyone, API token header is not allowed.
  resource "/api/users/*",
    origins: "*",
    allow_methods: ["HEAD", "GET"]

  def is_allowed_origin(origin) do
    origin in Utils.get_conf(:cors_allowed_origins)
  end
end

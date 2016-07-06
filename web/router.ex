defmodule CodeStats.Router do
  use CodeStats.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CodeStats.SetSessionUser
  end

  pipeline :browser_auth do
    plug CodeStats.AuthRequired
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug CodeStats.APIAuthRequired
  end

  scope "/", CodeStats do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/api-docs", PageController, :api_docs
    get "/tos", PageController, :terms
    get "/plugins", PageController, :plugins
    get "/changes", PageController, :changes
    get "/irc", PageController, :irc

    get "/login", AuthController, :render_login
    post "/login", AuthController, :login
    get "/logout", AuthController, :logout
    get "/signup", AuthController, :render_signup
    post "/signup", AuthController, :signup

    get "/users/:username", ProfileController, :profile

    scope "/my" do
      pipe_through :browser_auth

      get "/profile", ProfileController, :my_profile

      get "/preferences", PreferencesController, :edit
      put "/preferences", PreferencesController, :do_edit

      post "/password", PreferencesController, :change_password
      post "/sound_of_inevitability", PreferencesController, :delete

      get "/machines", MachineController, :list
      post "/machines", MachineController, :add
      get "/machines/:id", MachineController, :view_single
      put "/machines/:id", MachineController, :edit
      delete "/machines/:id", MachineController, :delete
      post "/machines/:id/key", MachineController, :regen_machine_key
    end
  end

  scope "/api", CodeStats do
    pipe_through :api

    scope "/my" do
      pipe_through :api_auth

      post "/pulses", PulseController, :add
    end
  end
end

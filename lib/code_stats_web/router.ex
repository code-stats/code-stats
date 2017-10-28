defmodule CodeStatsWeb.Router do
  use CodeStatsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CodeStatsWeb.RememberMe
    plug CodeStatsWeb.SetSessionUser
  end

  pipeline :browser_auth do
    plug CodeStatsWeb.AuthRequired
  end

  pipeline :browser_unauth do
    plug CodeStatsWeb.AuthNotAllowed
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug CodeStatsWeb.APIAuthRequired
  end

  scope "/", CodeStatsWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/api-docs", PageController, :api_docs
    get "/tos", PageController, :terms
    get "/plugins", PageController, :plugins
    get "/changes", PageController, :changes

    get "/aliases", AliasController, :list

    get "/battle", BattleController, :battle

    scope "/" do
      pipe_through :browser_unauth

      get "/login", AuthController, :render_login
      post "/login", AuthController, :login
      get "/signup", AuthController, :render_signup
      post "/signup", AuthController, :signup
      get "/forgot-password", AuthController, :render_forgot
      post "/forgot-password", AuthController, :forgot
      get "/reset-password/:token", AuthController, :render_reset
      put "/reset-password/:token", AuthController, :reset
    end

    get "/logout", AuthController, :logout

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

  scope "/api", CodeStatsWeb do
    pipe_through :api

    get "/users/:username", ProfileController, :profile_api

    scope "/my" do
      pipe_through :api_auth

      post "/pulses", PulseController, :add
    end
  end
end

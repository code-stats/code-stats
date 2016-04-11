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

  scope "/", CodeStats do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/login", AuthController, :render_login
    post "/login", AuthController, :login
    get "/logout", AuthController, :logout
    get "/signup", AuthController, :render_signup
    post "/signup", AuthController, :signup

    get "/users/:username", ProfileController, :profile

    scope "/my" do
      pipe_through :browser_auth

      get "/profile", ProfileController, :my_profile

      get "/preferences", ProfileController, :edit
      put "/preferences", ProfileController, :do_edit

      post "/keys_must_be_regenerated", ProfileController, :regen_keys
      post "/password", ProfileController, :change_password
      post "/sound_of_inevitability", ProfileController, :delete
    end
  end

  scope "/api", CodeStats do
    pipe_through :api

    resources "/xps", XPController, except: [:new, :edit]
  end
end

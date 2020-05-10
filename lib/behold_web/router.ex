defmodule BeholdWeb.Router do
  use BeholdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BeholdWeb do
    pipe_through :api
    post "/check", ChecksController, :create
    get "/check/:id", ChecksController, :get
    get "/checks", ChecksController, :get_all
    put "/check", ChecksController, :update
    delete "/check", ChecksController, :delete

    get "/check/:id/values", ValuesController, :get

    post "/alert", AlertsController, :create
    put "/alert", AlertsController, :update
    delete "/alert", AlertsController, :delete
    get "/alerts", AlertsController, :get_all
  end
end

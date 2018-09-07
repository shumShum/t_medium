defmodule NodeTwoWeb.Router do
  use NodeTwoWeb, :router

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

  scope "/", NodeTwoWeb do
    pipe_through :browser

    get "/", MessageController, :index
    resources("/messages", MessageController, only: [:index, :create])
  end
end

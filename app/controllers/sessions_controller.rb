class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: :create

  def create
    resp = Faraday.post("https://github.com/login/oauth/access_token") do |req|
      req.headers = {Accept: "application/json"}
      req.body = {"client_id": ENV["GITHUB_CLIENT"],
        "client_secret": ENV['GITHUB_SECRET'],
        "code": params[:code]}
    end
    session[:token] = JSON.parse(resp.body)["access_token"]

    resp2 = Faraday.get("https://api.github.com/user") do |req|
      req.headers = {Authorization: "token #{session[:token]}",
        Accept: "application/json"}
    end
    session[:username] = JSON.parse(resp2.body)["login"]
    redirect_to root_path
  end
end

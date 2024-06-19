class ApiController < ApplicationController
  def health_check
    render json: {hello: "world"}, status: :ok
  end

end

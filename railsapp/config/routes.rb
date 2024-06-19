Rails.application.routes.draw do
  root controller: :api, action: :health_check
end
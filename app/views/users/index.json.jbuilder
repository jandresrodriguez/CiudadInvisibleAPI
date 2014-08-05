json.array!(@users) do |user|
  json.extract! user, :id, :username, :email, :first_name, :last_name, :facebook_id, :twitter_id, :city, :country, :password
  json.url user_url(user, format: :json)
end

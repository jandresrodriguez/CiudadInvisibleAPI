json.array!(@notifications) do |notification|
  json.extract! notification, :id, :user_id, :post_id, :type
  json.url notification_url(notification, format: :json)
end

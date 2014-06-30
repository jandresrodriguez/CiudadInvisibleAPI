json.array!(@posts) do |post|
  json.extract! post, :id, :title, :author, :description, :image, :date, :location, :category
  json.url post_url(post, format: :json)
end

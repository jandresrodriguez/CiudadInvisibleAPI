class Notifier < ActionMailer::Base
  default from: "no-reply@ciudadinvisible.org"

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Thanks for signing up for our amazing app' )
  end

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def password_recovery(user)
    @user = user
    if user.token
      mail( :to => @user.email, :subject => 'Password Recovery' )  
    end
  end

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_notification(notification)
    user = User.find_by_id(notification.receiver.id)
    uri = URI.parse("https://api.parse.com/1/push")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request["X-Parse-Application-Id"] = "JV9KTqeAA1skH0ZiUE8PSzl7PwmnKptuumpj9pqZ"
    request["X-Parse-REST-API-Key"] = "8zWBkSn9F40y22oN8273qHMeSSeSgLqTXRIqfzFb"
    request["Content-Type"] = "application/json"
    require 'byebug'; byebug
    body = { where: { 
              deviceType: "ios", 
              deviceToken: user.try(:device_token) 
            }, 
            data: { 
              alert: notification.try(:title), 
              sound: "default", 
              payload: notification.try(:message) 
            }
           }.to_json
    http.use_ssl = true
    response = http.request(request,body)
    if user.email
      mail( :to => user.email, :subject => notification.title )  
    end
  end
end

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
  def send_notification(user)
    @user = user
    if user.token
      mail( :to => @user.email, :subject => 'Password Recovery' )  
    end
  end
end

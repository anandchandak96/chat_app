class UserMailer < ApplicationMailer
  def password_reset_instructions(user)
    @user = user
    @reset_password_url = reset_password_url(token: @user.reset_password_token)
    mail(to: @user.email, subject: "Reset Your Password")
  end
end

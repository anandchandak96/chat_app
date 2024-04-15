module V1
  class Sessions < Grape::API
    version 'v1', using: :path
    format :json

    desc 'Sign in'
    params do
      requires :email, type: String, desc: 'User email'
      requires :password, type: String, desc: 'User password'
    end
    post '/signin' do
      user = User.find_for_authentication(email: params[:email])
      if user && user.valid_password?(params[:password])
        payload = { user_id: user.id }
        secret_key = ENV['JWT_SECRET_KEY']
        algorithm = 'HS256'
        token = JWT.encode(payload, secret_key, algorithm)
        # token = JwtService.encode(user_id: user.id)
        { user: user,token: token }
      else
        error!('Invalid email or password', 401)
      end
    end

    desc 'Forgot password'
      params do
        requires :email, type: String, desc: 'User email'
      end
      post '/forgot_password' do
        user = User.find_by(email: params[:email])
        if user
          user.generate_reset_password_token
          UserMailer.password_reset_instructions(user).deliver_now
          # Send email with reset password instructions
          { message: 'Reset password instructions sent to your email.' }
        else
          error!('Email not found', 404)
        end
      end
  end
end
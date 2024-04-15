module V1
  class Registrations < Grape::API
    version 'v1', using: :path
    format :json

    before do
      set_language(params[:lang])
    end
    
    helpers do
      def set_language(lang)
        I18n.locale = lang.presence || I18n.default_locale
      end
    end
    post '/signup' do
      user = User.new(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email],
        password: params[:password],
        profile_image: params[:profile_image]
      )
      if user.save
        payload = { user_id: user.id }
        secret_key = ENV['JWT_SECRET_KEY']
        algorithm = 'HS256'
        token = JWT.encode(payload, secret_key, algorithm)
        {  message: I18n.t('created') , token: token}
      else
        error!(user.errors.full_messages, 422)
      end
    end
  end
end
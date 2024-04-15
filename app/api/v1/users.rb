
module V1
  class Users < Grape::API
    
    version 'v1', using: :path
    format :json

    
    before do
      authenticate_user!
      set_language(params[:lang]) if params[:lang].present?
    end
    
    helpers do
      def authenticate_user!
        token = request.headers['authorization']&.split(' ')&.last
        decoded_token = JWT.decode(token, ENV['JWT_SECRET_KEY'] , true, algorithm: 'HS256')
        @current_user = User.find(decoded_token.first['user_id'])
        error!('Unauthorized', 401) unless @current_user
      rescue JWT::DecodeError
        error!('Unauthorized', 401)
      end

      def set_language(lang)
        I18n.locale = lang.presence || I18n.default_locale
      end

      def current_user
        @current_user
      end
    end

    

    resource :protected_resource do
      get do
        { message: 'This is a protected resource', user: current_user }
      end
    end
    resource :users do
      desc 'Return a list of users'
      get do
        User.all
      end

      desc 'Return a specific user'
      params do
        requires :id, type: Integer, desc: 'User ID'
      end
      route_param :id do
        get do
          User.find(params[:id])
        end
      end

      desc 'Create a new user'
      params do
        requires :first_name, type: String, desc: 'User first name'
        requires :last_name, type: String, desc: 'User last name'
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end
      post do
        User.create(first_name: params[:first_name],last_name: params[:last_name], email: params[:email], password: params[:password])
      end

      desc 'Update an existing user'
      params do
        requires :id, type: Integer, desc: 'User ID'
        optional :first_name, type: String, desc: 'User first name'
        optional :last_name, type: String, desc: 'User last name'
        optional :email, type: String, desc: 'User email'
        optional :password, type: String, desc: 'User password'
      end
      put ':id' do
        user = User.find(params[:id])
        user.update(params)
        # user.update(first_name: params[:first_name],last_name: params[:last_name], email: params[:email],password: params[:password])
        user
      end

      desc 'Delete a user'
      params do
        requires :id, type: Integer, desc: 'User ID'
      end
      delete ':id' do
        user = User.find(params[:id])
        user.destroy
        { message: 'User deleted successfully'}
      end
    end
  end
end
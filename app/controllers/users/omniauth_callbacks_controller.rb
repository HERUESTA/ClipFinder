class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # CSRFトークンの検証をスキップ（必要に応じて）
  skip_before_action :verify_authenticity_token, only: [ :twitch ]

  def twitch
    # OmniAuthから認証情報を取得
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Twitch") if is_navigational_format?
    else
      session["devise.twitch_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end

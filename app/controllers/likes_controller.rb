class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    playlist = Playlist.preload(:likes).find(params[:playlist_id])
    like = current_user.likes.new(playlist_id: playlist.id)

    respond_to do |format|
      if like.save
        playlist.reload
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("playlist_#{playlist.id}_like", partial: "shared/like", locals: { playlist: playlist })
        end
      else
        format.html { redirect_to request.referer, alert: "ログインしてください" }
      end
    end
  end

  def destroy
    like = current_user.likes.find_by(playlist_id: params[:playlist_id])
    playlist = Playlist.find(params[:playlist_id])
    respond_to do |format|
      if like.destroy
        playlist.reload
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("playlist_#{playlist.id}_like", partial: "shared/like", locals: { playlist: playlist })
        end
      else
        format.html { redirect_to request.referer, alert: "ログインしてください" }
      end
    end
  end

  private

  # 未ログイン状態でいいねをした場合ログイン画面に飛ばしたくないため、
  # deviseのメソッドをオーバーライドして独自定義する
  # root_pathか現在いるpathに飛ばすようにする
  def authenticate_user!
    unless current_user
      redirect_to request.referer || root_path, alert: "いいねするにはログインしてください"
    end
  end
end

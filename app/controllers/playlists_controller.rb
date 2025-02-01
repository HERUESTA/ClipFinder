# app/controllers/playlists_controller.rb
class PlaylistsController < ApplicationController
  # ユーザーが認証されていることを確認
  before_action :authenticate_user!, only: [ :edit, :index, :update, :destroy ]
  # 特定のアクション前にプレイリストを設定
  before_action :set_playlist, only: [ :update, :destroy ]

  before_action :ensure_correct_user, only: [ :edit ]

  def index
    @page = params[:page]
    @active_tab = (params[:active_tab] == "liked_playlists") ? "liked_playlists" : "my_library"
    # いいねしたプレイリスト
    @liked_playlists = Playlist.get_liked_playlists(current_user, @page)
    # マイライブラリ
    @my_playlists = Playlist.get_my_playlists(current_user, @page)
  end

  def edit
    @playlist = Playlist.find(params[:id])
    @clips = @playlist.clips.preload(:streamer)
  end

  def show
    # プレイリスト内の全クリップを取得
    @playlist = Playlist.find(params[:id])
    confirm_privacy(@playlist)
    @clips = @playlist.clips.preload(:streamer)
    # 自分の全てのプレイリストを取得する
    @playlists = user_signed_in? ? Playlist.where(user_uid: current_user.uid) : []
    # 再生するクリップを特定（パラメータがなければ最初のクリップを使用）
    @clip = params[:clip_id].present? ? @clips.find_by(id: params[:clip_id]) : @clips.first
  end

  # プレイリストを更新
  def update
    Rails.logger.debug "プレイリストの中身: #{@playlist.inspect}"
    @playlist.update(playlist_params)
      respond_to do |format|
        format.html { redirect_to request.referer, notice: t("playlists.updated", title: @playlist.title) }
      end
  end

  # プレイリストを削除
  def destroy
    @playlist.destroy!
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = t("playlists.destroy", title: @playlist.title) }
      format.html { redirect_to playlists_path, notice: t("playlists.destroy", title: @playlist.title), status: :see_other }
    end
  end

  private

  # プレイリストを設定するメソッド
  def set_playlist
    # 現在のユーザーが所有するプレイリストのみを検索
    @playlist = current_user.playlists.find(params[:id])
    @playlists = current_user.playlists.order(:id)
  end

  # ストロングパラメータの定義
  def playlist_params
    params.require(:playlist).permit(:title, :visibility, :id)
  end

  # プレイリストの作成者かどうかを確認するメソッド
  def ensure_correct_user
    @playlist = Playlist.find(params[:id])
    unless @playlist.user_uid == current_user.uid
      redirect_to root_path, alert: "このプレイリストを編集する権限がありません"
    end
  end

  # プレイリストの公開状態を確認するメソッド
  def confirm_privacy(playlist)
    if playlist.nil? || playlist.visibility == "private" && current_user.uid != playlist.user_uid
      redirect_to root_path, alert: "このプレイリストにはアクセスができません"
    end
  end
end

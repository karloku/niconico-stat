class VideosController < ApplicationController
  before_action :set_tag

  def index
    @videos = Video.where(tag_ids: @tag.id).asc(:u).page(page)
  end

  private
    def set_tag
      @tag = Tag.find(params[:tag_id])
    end
end

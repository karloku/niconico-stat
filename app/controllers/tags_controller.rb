class TagsController < ApplicationController
  def index
    @tags = Tag.page(page).per(1000)
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def search
    @query = params.require(:query)
    @tags = Tag.search(@query).page(page).records
    render 'tags/index'
  end
end

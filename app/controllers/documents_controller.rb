class DocumentsController < ApplicationController

  def index
    redirect_to Document.new(params.permit(:owner)).owner
  end

  def show
    redirect_to Document.find(params[:id])
  end

end

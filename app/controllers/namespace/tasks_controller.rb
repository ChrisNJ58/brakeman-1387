module Namespace
  class TasksController < ApplicationController

    def index
      redirect_to Task.new(params.permit(:owner)).owner
    end

    def show
      redirect_to Task.find(params[:id])
    end

  end
end

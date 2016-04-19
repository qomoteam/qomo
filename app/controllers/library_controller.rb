class LibraryController < ApplicationController
  def index
    @records = Filerecord.library
  end
end

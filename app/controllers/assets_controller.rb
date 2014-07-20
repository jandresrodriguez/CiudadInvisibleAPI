class AssetsController < ApplicationController

	def new
        @asset = Asset.new()
        5.times { @asset.files.build }
	end

	def edit
        @asset = Asset.find(params[:id])
        5.times { @asset.files.build }
	end
end

class ElScrapersController < ApplicationController

  def index
    if params[:el_scraper]

      FileUtils.remove_dir "#{Rails.root}/public/files", true
      FileUtils.mkdir "#{Rails.root}/public/files"

      @urls = params[:el_scraper][:urls].split(' ')

      sc = ElScraper.new(@urls)
      @file = sc.scrape
    end
  end
end

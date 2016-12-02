require 'nokogiri'
require 'open-uri'
require 'sanitize'

class ElScraper < ActiveRecord::Base

  def initialize(urls)
    @urls = urls
  end

  def scrape
    @urls.each do |url|
      page = Nokogiri::HTML(open(url))

      if url.include? 'poradnikzdrowie.pl'
        title = page.css('.article_title')
        article_lead = page.css('.lead_article')
        article = page.css('.text_article')

        title_arr = Sanitize.fragment(title).strip.split("\n")
        article_lead_arr = Sanitize.fragment(article_lead).strip.split("\n")
        article_arr = Sanitize.fragment(article).strip.split("\n")

        file_name = file_name_from_url url
        save_to_file(file_name, title(title_arr), article_lead(article_lead_arr), article(article_arr))

      elsif url.include? 'polki.pl'
        title = page.css('.columns.title-box.small-12>h1')
        article_lead = page.css('.lead')
        article_links = page.css('.newListArt')
        article_links.remove
        video_player = page.css('.video-player')
        video_player.remove
        instagram = page.css('.instagram-media')
        instagram.remove
        article = page.css('.article')

        article = Sanitize.fragment(Sanitize.clean(article, :remove_contents => ['script', 'style', 'js']))

        clen_article = []
        article.each_line do |line|
          if line.start_with? 'Tagi:'
          elsif line.start_with? 'fot.'
          elsif line.start_with? 'Uwaga!'
          else
            clen_article << line
          end
        end

        title_arr = Sanitize.fragment(title).strip.split("\n")
        article_lead_arr = Sanitize.fragment(article_lead).strip.split("\n")
        article_arr = Sanitize.fragment(clen_article.join('')).strip.split("\n")

        file_name = file_name_from_url url
        save_to_file(file_name, title(title_arr), article_lead(article_lead_arr), article(article_arr))

      elsif url.include? 'bankier.pl'
        title = page.css('.entry-title')
        article = page.css('#articleContent')
        author_box = page.css('.author')
        author_name = page.css('.fn.name')
        img_description = page.css('.imgDescription')
        author_box.remove
        img_description.remove

        title_arr = Sanitize.fragment(title).strip.split("\n")
        article_arr = Sanitize.fragment(Sanitize.clean(article, :remove_contents => ['script', 'style', 'js'])).strip.split("\n")


        article_arr = article_arr.reject do |line|
          line.squeeze.size < 3
        end

        file_name = file_name_from_url url
        save_to_file(file_name, title(title_arr), article(article_arr.reverse.drop(1).drop(1).reverse))

      elsif url.include? 'abczdrowie.pl'
        title = page.css('h1.article-header')
        article = page.css('.grid-item-wide.article.secondary-font>p')
        img_desc = page.css('.gallery-img>figcaption')
        img_desc.remove
        ads = page.css('.sidebar-box.sidebar-content-box.flex-content')
        ads.remove

        title_arr = Sanitize.fragment(title).strip.split("\n")
        article_arr = Sanitize.fragment(Sanitize.clean(article, :remove_contents => ['script', 'style', 'js'])).strip.split("\n")

        file_name = file_name_from_url url
        save_to_file(file_name, title(title_arr), article(article_arr))

      else
        file_name = file_name_from_url url
        save_to_file(file_name, 'Scraper nie zna tej strony!', 'Zaproponuj właścicielowi dodanie tej strony do skryptu.')
      end
    end
  end

  # def read_from_file(input_file_name)
  #   puts "Wczytuje linki z pliku: #{input_file_name}"
  #   @input_file = File.new("#{input_file_name}", 'r')
  #   @input_file.each_line do |line|
  #     line.delete!("\n")
  #     line.gsub!(/\s/, ',')
  #     @urls << line
  #   end
  #
  #   puts "Wczytalem #{@urls.size} linkow."
  #   puts ''
  # end

  private

  def file_name_from_url(url)
    url.gsub!('http://', '')
    url.gsub!('https://', '')
    url.gsub!('.html', '')
    url.gsub!('-', '_')
    url.gsub!(',', '_')
    url.gsub!('.', '_')
    url.gsub!('/', '_')
    return "#{url}.txt"
  end

  def save_to_file(file_name, title = '', article_lead = '', article = '')
    out_file = File.new("public/files/#{file_name}", "w")
    out_file.puts(title)
    out_file.puts('')
    out_file.puts(article_lead)
    out_file.puts('')
    out_file.puts(article)
    out_file.close
  end

  def title(title_arr)
    title_arr.join('').squeeze
  end

  def article_lead(article_lead_arr)
    article_lead_arr.join('').squeeze
  end

  def article(article_arr)
    article_arr.join('').squeeze
  end
end

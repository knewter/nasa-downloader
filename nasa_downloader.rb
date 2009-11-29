require 'rubygems'
require 'hpricot'
require 'open-uri'

class NasaDownloader
  attr_accessor :doc, :pages, :photo_pages, :photo_downloads

  def initialize
    @pages = []
    @photo_pages = []
    @photo_downloads = []
    @doc = open(base_gallery_url){|f| Hpricot(f) }
    get_pages
    get_photo_pages
    get_photo_downloads
    download_images
  end

  # Collect links to each page in the gallery
  # - These links are somewhere like //html/body/table[2]/tr[5]/a where a["href"] =~ /ndxpage/...or just all links, where a["href"] =~ ...
  def get_pages
    @pages << base_gallery_url
    (@doc/"a").select{|a| a["href"] =~ /ndxpage/}.each do |e|
      @pages << base_gallery_url_prefix + e["href"]
    end
    puts "got pages!"
    puts @pages.inspect
    puts "---"
  end

  def get_photo_pages
    # Iterate over each page, and push in all of the photo page links from each page
    @pages.each do |page|
      _doc = open(page){|f| Hpricot(f) }
      (_doc/"a").select{|a| a["href"] =~ /html\// }.each do |e|
        @photo_pages << base_gallery_url_prefix + e["href"]
      end
    end
    puts "got photo pages!"
    puts @photo_pages.inspect
    puts "---"
  end

  def get_photo_downloads
    @photo_pages.each do |page|
      _doc = open(page){|f| Hpricot(f) }
      (_doc/"a").select{|a| a["href"] =~ /hires\// }.each do |e|
        @photo_downloads << base_gallery_url_prefix + e["href"].gsub(/\.\.\//, '')
      end
    end
    puts "got photo downloads!"
    puts @photo_downloads.inspect
    puts "---"
  end

  def download_images
    puts "downloading to #{download_path}"
    unless File.exists?(download_path)
      FileUtils.mkdir(download_path)
    end
    @photo_downloads.each do |download_url|
      `cd #{download_path}; wget #{download_url}`
    end
  end

  def download_path
    _arr = base_gallery_url_array
    _arr.pop
    return _arr.pop
  end

  # Get a base html dir (for page 1 of the gallery)
  def base_gallery_url
    "http://spaceflight.nasa.gov/gallery/images/shuttle/sts-121/ndxpage1.html"
  end

  def base_gallery_url_prefix
    if @base_gallery_url_prefix
      @base_gallery_url_prefix
    else
      _prefix_arr = base_gallery_url_array
      _prefix_arr.pop
      @base_gallery_url_prefix = _prefix_arr.join("/") + "/"
    end
  end

  def base_gallery_url_array
    base_gallery_url.split("/")
  end

  #
  # Collect links to each image on each page
  # - These links have a["href"] =~ /html\//
  #(doc/"a").select{|a| a["href"] =~ /html\// }
  #
  # Collect links to the high res images on the subsequent pages
  # - these links say "high res"
  #
  # Download them all to the localdir
end

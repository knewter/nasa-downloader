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
    #get_photo_pages
    #get_photo_downloads
    #download_images
  end

  # Collect links to each page in the gallery
  # - These links are somewhere like //html/body/table[2]/tr[5]/a where a["href"] =~ /ndxpage/...or just all links, where a["href"] =~ ...
  def get_pages
    @pages << base_gallery_url
    @pages += (@doc/"a").select{|a| a["href"] =~ /ndxpage/}
    puts @pages.inspect
  end

  # Get a base html dir (for page 1 of the gallery)
  def base_gallery_url
    "http://spaceflight.nasa.gov/gallery/images/shuttle/sts-121/ndxpage1.html"
  end

  #
  # Collect links to each image on each page
  # - These links have a["href"] =~ /html\//
  (doc/"a").select{|a| a["href"] =~ /html\// }
  #
  # Collect links to the high res images on the subsequent pages
  # - these links say "high res"
  #
  # Download them all to the localdir
end

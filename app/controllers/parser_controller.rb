class ParserController < ApplicationController
  def index
  end

  def show
    @data = parse_tiktok_data(params[:search_query], params[:quantity].to_i)
  end

  def parse_data
    search_query = params[:search_query]
    quantity = params[:quantity].to_i

    @data = parse_tiktok_data(search_query, quantity)

    redirect_to action: :show, search_query: search_query, quantity: quantity
  end

  private

  def parse_tiktok_data(search_query, quantity_of_results)
    scraper = ::ParserService.new
    scraper.parse_tiktok_data(search_query, quantity_of_results)
  end
end

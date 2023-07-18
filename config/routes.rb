Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'parser#index'
  post 'parse_data', to: 'parser#parse_data', as: :parse_data_tik_tok_parser_index
  get 'show_data', to: 'parser#show', as: :show_data_tik_tok_parser
end

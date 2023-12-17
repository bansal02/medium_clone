Rails.application.routes.draw do
  get 'current_user', to: 'current_user#index'
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")

  #article routes
  root "articles#home"                                   # see all articles

  get "/details", to: "articles#details"                 # get details of an article. Throttling applied based on subscription

  get "/history", to: "articles#history"                 # revision history of a particular article

  post "/create", to: "articles#create"                  # creating a new article

  patch "/update", to: "articles#update"                 # updating an article

  delete "/delete", to: "articles#delete"                # deleting an article

  get "/filter", to: "articles#filter"                   # filter - author name, title, topic, number of likes, number of comments, date etc

  get "/search", to: "articles#search"                   # partial and case insensitive search 

  get "/sort", to: "articles#sort"                       # sort articles based on number of likes and comments. Ascending or descending

  post "/like", to:"articles#like"                       # like or unlike an article

  get "/see_comments", to:"articles#comment_view"        # see the comments on a particular post

  post "/comment", to:"articles#comment"                 # comment on a particular post

  get "/top_posts", to:"articles#top_posts"              # see the top posts based on views

  get "/topics", to:"articles#view_topics"               # see all topics and the assosiated articles

  get "/recommended", to:"articles#recommended_articles" # see recommended posts on the basis of interests

  get "/similar_authors", to:"articles#similar_authors"  # get similar authors based on speciality

  get "/save", to:"articles#save"                        # save a particular post



  #author routes

  get "/authors", to:"authors#home"                      # see all the authors

  get "/author", to: "authors#details"                   # see details of a particular author

  get "/profile", to: "authors#profile"                  # see your profile

  patch "/profile_edit", to: "authors#profile_edit"      # edit your profile

  get "/my_posts", to: "authors#my_posts"                # see your posts

  post "/follow", to: "authors#follow"                   # follow an author

  get "/view_saved", to:"authors#view_saved"             # view saved posts

  get "/view_shared", to:"authors#view_shared"           # view shared lists


  #draft routes

  get "/my_drafts", to:"drafts#my_drafts"                # see your drafts

  get "/draft_history", to:"drafts#history"              # revision history of a particular draft

  post "/create_draft", to:"drafts#create_draft"         # creating a draft

  get "/draft_details", to:"drafts#draft_details"        # seeing details of a draft

  patch "/draft_update", to:"drafts#draft_update"        # update a draft

  post "/draft_post", to:"drafts#draft_post"             # post a draft

  delete "/draft_delete", to:"drafts#draft_delete"       # delete a draft


  #list routes

  get "/my_lists", to:"lists#my_lists"                   # see lists created by current user

  post "/create_list", to:"lists#create_list"            # create a new list

  post "/insert_article", to:"lists#insert_article"      # insert an article into a list

  post "/remove_article", to:"lists#remove_article"      # remove an article from a list

  post "/share_list", to:"lists#share_list"              # share a list with an user

  post "/unshare_list", to:"lists#unshare_list"          # unshare a list with an user

  delete "/delete_list", to:"lists#delete_list"          # delete a list

  #payment route

  post "/pay", to:"payments#pay"                         # pay for subscription

  # post '/pay/create_payment', to: 'payments#create_payment'
  # post '/pay/payment_callback', to: 'payments#handle_payment_callback'


end

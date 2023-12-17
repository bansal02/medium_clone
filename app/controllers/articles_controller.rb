class ArticlesController < ApplicationController
    def home
      bpp=params.fetch(:books_per_page, 3).to_i
      offset=params.fetch(:page, 0).to_i

      if(offset<1)
          offset=1
      end

      max_len=Article.all.count

      if(bpp>max_len)
          bpp=max_len
      end

      if(max_len==0)
          bpp=0
          offset=0
      else
          o_max=(max_len/bpp).to_i
          
          if(max_len.modulo(bpp)!=0)
              o_max=((max_len/bpp)+1).to_i
          end

          if(offset>o_max)
              offset=o_max
          end
      end

      articles = Article.includes(image_attachment: :blob).offset((offset-1)*bpp).limit(bpp)
      # render json: @articles.offset((@offset-1)*@bpp).limit(@bpp)
      response = articles.map do |article|
          {
            id: article.id,
            title: article.title,
            author: article.author.username,
            text: article.text,
            topic: article.topic.name,
            likes: article.likes,
            views: article.views,
            comments: article.comments,
            image_url: article.image.attached? ? url_for(article.image) : nil,
            reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
            created_at: article.created_at,
            updated_at: article.updated_at
          }
      end
      render json: response
    end



    

    def details
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end
      # topic=Topic.find_or_create_by(name: permitted_params[:topic])
      user_status=Status.find_by(username: current_user.username)
      unless user_status
        user_status=Status.new(username: current_user.username)
      end

      if (Date.today - user_status.subscription_date).to_i > 28
        user_status.subscription_date=Date.today
        user_status.views=0
      end

      current_class=user_status.views
      
      if Date.today>user_status.last_request_date
        user_status.requests=0
        user_status.last_request_date=Date.today
      end
      
      requests_done=user_status.requests

      if requests_done >= current_class
        render json: {message: "Your daily quota is over, upgrade plan or wait till tomorrow"}, status: :ok
        return
      else
        user_status.requests+=1
      end

      user_status.save

      id = params.fetch(:id, "")
    
      if id!=""
        id=id.to_i
        article = Article.find(id)

        unless article
          render json: { error: 'Article not found' }, status: :not_found
          return
        end
        article.views= article.views+1
        article.save
        response =
              {
                id: article.id,
                title: article.title,
                author: article.author.username,
                text: article.text,
                topic: article.topic.name,
                likes: article.likes,
                views: article.views,
                comments: article.comments,
                image_url: article.image.attached? ? url_for(article.image) : nil,
                reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
                created_at: article.created_at,
                updated_at: article.updated_at
              }
        render json: response
      else
        response={}
        render json: response
      end
    end





    def history
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end
      id=params.fetch(:id, "")
      if id==""
        render json: { message: 'Pass id to view article' }, status: :not_found
        return
      end
      
      id=id.to_i
      article=Article.find(id)

      unless article
        render json: { error: 'Article not found' }, status: :not_found
        return
      end

      if article.author.username != current_user.username
        render json: { error: 'Not authorized to view this article' }, status: :unauthorized
        return
      end

      render json: { history: article.states }, status: :ok
    end





    def filter
      author_name = params.fetch(:author, "")
      title = params.fetch(:title, "")
      topic_name = params.fetch(:topic, "")
      num_likes=params.fetch(:likes, "")
      num_comments=params.fetch(:comments, "")
      date_after=params.fetch(:date_after, "")
      date_before=params.fetch(:date_before, "")
    
      articles = Article.all
    
      if author_name!=""
        # Find the author by name (case-insensitive search)
        author = Author.find_by("lower(username) = ?", author_name.downcase)
    
        # If the author exists, filter articles by the author's ID
        articles = articles.where(author: author) if author
      end
    
      if title!=""
        articles = articles.where(title: title)
      end

      if topic_name!=""
        topic = Topic.find_by("lower(name) = ?", topic_name.downcase)
        articles=articles.where(topic: topic) if topic
      end

      if num_likes!=""
        num_likes=num_likes.to_i
        articles = articles.select { |article| article.likes.size >= num_likes }
      end

      if num_comments!=""
        num_comments=num_comments.to_i
        articles = articles.select { |article| article.comments.size >= num_comments }
      end

      # date and is in the format "YYYY-MM-DD
      if date_after!=""
        date = Date.parse(params[:date_after])
        articles = Article.where("created_at >= :date AND updated_at >= :date", date: date)
      end

      if date_before!=""
        date = Date.parse(params[:date_before])
        articles = Article.where("created_at <= :date AND updated_at <= :date", date: date)
      end
    
      # Build a JSON response with image URLs
      response = articles.map do |article|
        {
          id: article.id,
          title: article.title,
          author: article.author.username,
          text: article.text,
          topic: article.topic.name,
          likes: article.likes,
          views: article.views,
          comments: article.comments,
          image_url: article.image.attached? ? url_for(article.image) : nil,
          reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
          created_at: article.created_at,
          updated_at: article.updated_at
        }
      end
    
      render json: response
    end




    def search
      text_search_term = article_search_params[:text]
      author_search_term = article_search_params[:author]
      topic_search_term = article_search_params[:topic]
      title_search_term = article_search_params[:title]
  
      # Perform the partial search using 'ILIKE' for case-insensitive search (assuming you're using PostgreSQL)
      articles=Article.all
      
      if text_search_term.present?
        articles = articles.where("lower(text) LIKE ?", "%#{text_search_term}%")
      end

      if title_search_term.present?
        articles = articles.where("lower(title) LIKE ?", "%#{title_search_term}%")
      end

      if author_search_term.present?
        articles = articles.joins(:author).where("authors.username LIKE ?", "%#{author_search_term}%")
      end

      if topic_search_term.present?
        articles = articles.joins(:topic).where("topics.name LIKE ?", "%#{topic_search_term}%")
      end
  
      # Build a JSON response with image URLs
      response = articles.map do |article|
        {
          id: article.id,
          title: article.title,
          author: article.author.username,
          text: article.text,
          topic: article.topic.name,
          likes: article.likes,
          views: article.views,
          comments: article.comments,
          image_url: article.image.attached? ? url_for(article.image) : nil,
          reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
          created_at: article.created_at,
          updated_at: article.updated_at
        }
      end
  
      render json: response
    end





    def sort
      articles = Article.all

      # Sort articles based on the size of the likes array and then the size of the comments array
      sorted_articles = articles.sort_by do |article|
        [-article.likes.length, -article.comments.length]
      end
  
      # Build a JSON response with image URLs
      response = sorted_articles.map do |article|
        {
          id: article.id,
          title: article.title,
          author: article.author.username,
          text: article.text,
          topic: article.topic.name,
          likes: article.likes,
          views: article.views,
          comments: article.comments,
          image_url: article.image.attached? ? url_for(article.image) : nil,
          reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
          created_at: article.created_at,
          updated_at: article.updated_at
        }
      end
  
      render json: response
    end





    def create
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end
        # Permit only the specific fields from the request parameters
      permitted_params = article_params

      # Find or create the author based on the author name
      author = Author.find_by(username: current_user.username)
      topic=Topic.find_or_create_by(name: permitted_params[:topic])

      # Create the article and associate it with the author
      article = Article.new(
          title: permitted_params[:title],
          text: permitted_params[:text],
          topic: topic,
          author: author
      )

      # Attach the 'image' file to the article if present
      article.image.attach(permitted_params[:image]) if permitted_params[:image].present?

      if article.save
          # Update the article_ids of the associated author with the new article's ID
          author.update(article_ids: author.article_ids << article.id)
          topic.update(article_ids: topic.article_ids << article.id)
          # Build a JSON response with the image URL for the created article
          response =
            {
              id: article.id,
              title: article.title,
              author: article.author.username,
              text: article.text,
              topic: article.topic.name,
              likes: article.likes,
              views: article.views,
              comments: article.comments,
              image_url: article.image.attached? ? url_for(article.image) : nil,
              reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
              created_at: article.created_at,
              updated_at: article.updated_at
            }

          render json: response, status: :created
      else
          render json: { error: article.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end





    def store_current_state(article)
      current_state = {
        'title' => article.title,
        'text' => article.text,
        'topic' => article.topic.name
      }
    
      # Add the current state to the 'states' array
      article.states << current_state
    end 

    def update
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end

      update_params=edit_params
      article = Article.find_by(id: update_params[:id])

      unless article
        render json: { error: 'Article not found' }, status: :not_found
        return
      end

      if article.author.username!=current_user.username
        render json: { error: 'Not authorized to edit this post' }, status: :unauthorized
        return
      end

      store_current_state(article)

      if article.update(update_params)
          # Build a JSON response with the updated article details

          response =
            {
              id: article.id,
              title: article.title,
              author: article.author.username,
              text: article.text,
              topic: article.topic.name,
              likes: article.likes,
              views: article.views,
              comments: article.comments,
              image_url: article.image.attached? ? url_for(article.image) : nil,
              reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
              created_at: article.created_at,
              updated_at: article.updated_at
            }

          render json: response
      else
          render json: { error: 'Failed to update the article' }, status: :unprocessable_entity
      end
    end 
    
    



    def delete
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end

      article = Article.find_by(id: params[:id])

      unless article
        render json: { error: 'Can not find post' }, status: :unprocessable_entity
        return
      end

      if article.author.username != current_user.username
        render json: { error: 'Not authorized to delete this post' }, status: :unauthorized
        return
      end
    
      if article
        # Get the associated author of the article
        author = article.author
        
        topic=article.topic

        # Destroy the associated image along with the article
        article.image.purge if article.image.attached?
    
        # Destroy the article
        article.destroy
    
        # Remove the article's ID from the author's article_ids array
        author.update(article_ids: author.article_ids - [params[:id].to_i])

        topic.update(article_ids: topic.article_ids-[params[:id].to_i])

    
        render json: { message: 'Article deleted successfully!' }, status: :ok
      else
        render json: { error: 'Article not found' }, status: :not_found
      end
    end





    def like
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end

      id = params.fetch(:id, "")
      article=Article.find(id)
      unless article
        render json: { error: 'Article not found' }, status: :not_found
        return
      end

      username=current_user.username
      if article.likes.include?(username)
        article.likes.delete(username)
      else
        article.likes << username
      end

      article.save
      response =
      {
        id: article.id,
        title: article.title,
        topic: article.topic.name,
        author: article.author.username,
        text: article.text,
        likes: article.likes,
        views: article.views,
        comments: article.comments,
        image_url: article.image.attached? ? url_for(article.image) : nil,
        reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
        created_at: article.created_at,
        updated_at: article.updated_at
      }

      render json: response
    end





    def comment
      unless current_user
        render json: {message: "Sign up or log in"}, status: :unauthorized
        return
      end

      id = params.fetch(:id, "")
      ctxt=params.fetch(:comment, "")
      article=Article.find(id)
      unless article
        render json: { error: 'Article not found' }, status: :not_found
        return
      end

      if ctxt!=""
        temp={
          "user"=> current_user.username,
          "comment"=> ctxt
        }
        article.comments << temp
        article.save
      end

      response =
      {
        id: article.id,
        title: article.title,
        author: article.author.username,
        text: article.text,
        topic: article.topic.name,
        likes: article.likes,
        views: article.views,
        comments: article.comments,
        image_url: article.image.attached? ? url_for(article.image) : nil,
        reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
        created_at: article.created_at,
        updated_at: article.updated_at
      }

      render json: response
    end





    def comment_view
      id = params.fetch(:id, "")
      article=Article.find(id)
      unless article
        render json: { error: 'Article not found' }, status: :not_found
        return
      end

      response = article.comments.map do |comment|
        {
          'user'=>comment['user'],
          'comment'=>comment['comment']
        }
      end

      render json: response
    end





    def top_posts
      lim = params.fetch(:num, 10).to_i 
    
      # Perform the sorting based on 'created_at' in ascending or descending order
      articles = Article.order(views: :desc).limit(lim)
  
      # Build a JSON response with image URLs
      response = articles.map do |article|
        {
          id: article.id,
          title: article.title,
          author: article.author.username,
          text: article.text,
          topic: article.topic.name,
          likes: article.likes,
          views: article.views,
          comments: article.comments,
          image_url: article.image.attached? ? url_for(article.image) : nil,
          reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
          created_at: article.created_at,
          updated_at: article.updated_at
        }
      end
    
      render json: response
    end





    def recommended_articles
      
      unless current_user
        articles=Article.all
        response = articles.map do |article|
          {
            id: article.id,
            title: article.title,
            author: article.author.username,
            text: article.text,
            topic: article.topic.name,
            likes: article.likes,
            views: article.views,
            comments: article.comments,
            image_url: article.image.attached? ? url_for(article.image) : nil,
            reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
            created_at: article.created_at,
            updated_at: article.updated_at
          }
        end
      
        render json: response
        return
      end

      username=current_user.username
      interest=Author.find_by(username: username).interest
      topic=Topic.find_by(name: interest)

      unless topic
        articles=Article.all
        response = articles.map do |article|
          {
            id: article.id,
            title: article.title,
            author: article.author.username,
            text: article.text,
            topic: article.topic.name,
            likes: article.likes,
            views: article.views,
            comments: article.comments,
            image_url: article.image.attached? ? url_for(article.image) : nil,
            reading_time_minute: ((article.text.length / 5.0).ceil/200.0).ceil,
            created_at: article.created_at,
            updated_at: article.updated_at
          }
        end
        return
      end

      article_ids=topic.article_ids
      l=article_ids.length()
      articles=[]
      ctr=0
      while ctr<l
          id=article_ids[ctr]
          curr_article=Article.find(id)
          if curr_article
              temp=
              {
                  id: curr_article.id,
                  title: curr_article.title,
                  topic: curr_article.topic.name,
                  text: curr_article.text,
                  likes: curr_article.likes,
                  views: curr_article.views,
                  comments: curr_article.comments,
                  image_url: curr_article.image.attached? ? url_for(curr_article.image) : nil,
                  reading_time_minute: ((curr_article.text.length / 5.0).ceil/200.0).ceil,
                  created_at: curr_article.created_at,
                  updated_at: curr_article.updated_at
              }
              articles << temp
          end
          ctr+=1
      end
      response =
          {
              "articles"=>articles
          }
      render json: response

    end





    def similar_authors
      un=params.fetch(:username, "")
      if un!=""
        author=Author.find_by(username: un)
        unless author
          render json: {error: "No such author exists"}, status: :not_found
          return
        end
        speciality=author.speciality
        authors=Author.where(speciality: speciality)
        response = authors.map do |author|
          {
            id: author.id,
            name: author.name,
            username: author.username,
            articles: author.article_ids,
            profile_views: author.views,
          }
        end
        render json: response
      else
        response={}
        render json: response
      end
    end





    def view_topics
      topics=Topic.all
      response = topics.map do |topic|
      {
        id: topic.id,
        name: topic.name,
        articles: topic.article_ids
      }
      end
      render json: topics
    end




    def save
      id=params.fetch(:id, "")
      if id==""
        render json: {error: "Pass Id to save"}, status: :unprocessable_entity
        return
      end
      
      unless current_user
        render json: {error: "Log in or sign up first"}, status: :unauthorized
        return
      end

      id=id.to_i
      un=current_user.username
      author=Author.find_by(username: un)

      if author.saved_ids.include?(id)
        author.saved_ids.delete(id)
        render json: {message: "Article removed from saved"}, status: :ok
      else
        author.saved_ids << id
        render json: {message: "Article added to saved"}, status: :ok
      end
      author.save

    end


    private

    def article_params
        # Permit only the specific fields from the request parameters
        article_params=params.permit(:title, :text, :topic, :image)
        article_params.reject { |key, value| value.nil? }
    end

    def edit_params
      allowed_params = params.permit(:id, :title, :topic, :text, :image)
      # Filter out any keys with nil values
      allowed_params.reject { |key, value| value.nil? }


      if allowed_params[:topic]
        topic_name = allowed_params[:topic]
        new_topic = Topic.find_or_create_by(name: topic_name)
        article=Article.find(allowed_params[:id])

        old_topic = article.topic
  
        # Remove article ID from the old topic
        old_topic.article_ids.delete(article.id) if old_topic
  
        # Add article ID to the new topic
        new_topic.article_ids << article.id
  
        allowed_params[:topic] = new_topic
        
      end

      allowed_params
    end

    def article_search_params
        # Permit only the 'description' field from the request parameters
        params.permit(:text, :author, :topic, :title)
    end
end

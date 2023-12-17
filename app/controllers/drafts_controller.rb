class DraftsController < ApplicationController
    def my_drafts
        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        drafts = Draft.joins(:author).where(authors: { username: current_user.username })
        # drafts = drafts.includes(image_attachment: :blob)
        response = drafts.map do |draft|
            {
              id: draft.id,
              title: draft.title,
              author: draft.author.username,
              text: draft.text,
              topic: draft.topic.name,
            }
        end
        render json: response
    end

    def draft_details
        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        id = params.fetch(:id, "")
      
        if id!=""
          id=id.to_i
          drafts = Draft.joins(:author).where(authors: { username: current_user.username })
          draft = drafts.find_by(id: id)
  
          unless draft
            render json: { error: 'Draft not found for user' }, status: :not_found
            return
          end
          
          response =
                {
                  id: draft.id,
                  title: draft.title,
                  author: draft.author.username,
                  text: draft.text,
                  topic: draft.topic.name,
                  previous_versions: draft.states,
                  created_at: draft.created_at,
                  updated_at: draft.updated_at
                }
          render json: response
        else
          response={message: "Pass an id to find draft"}
          render json: response, status: :unprocessable_entity
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
        drafts = Draft.joins(:author).where(authors: { username: current_user.username })
        draft=drafts.find_by(id: id)
  
        unless draft
          render json: { error: 'Draft not found' }, status: :not_found
          return
        end
  
        render json: { history: draft.states }, status: :ok
    end

    def create_draft
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end
        permitted_params = draft_params


        author = Author.find_by(username: current_user.username)
        topic=Topic.find_or_create_by(name: permitted_params[:topic])


        draft = Draft.new(
            title: permitted_params[:title],
            text: permitted_params[:text],
            topic: topic,
            author: author
        )

        if draft.save
    
            response =
                {
                id: draft.id,
                title: draft.title,
                author: draft.author.username,
                text: draft.text,
                topic: draft.topic.name,
                created_at: draft.created_at,
                updated_at: draft.updated_at
                }

            render json: response, status: :created
        else
            render json: { error: draft.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
    end

    def store_current_state(draft)
        current_state = {
        'title' => draft.title,
        'text' => draft.text,
        'topic' => draft.topic.name
        }
    
        # Add the current state to the 'states' array
        draft.states << current_state
    end

    def draft_update
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end

        update_params=edit_params

        drafts = Draft.joins(:author).where(authors: { username: current_user.username })
        draft = drafts.find_by(id: update_params[:id])

        unless draft
            render json: { error: 'Article not found' }, status: :not_found
            return
        end

        store_current_state(draft)

        if draft.update(update_params)
            # Build a JSON response with the updated article details

            response =
            {
                id: draft.id,
                title: draft.title,
                text: draft.text,
                topic: draft.topic.name,
                reading_time_minute: ((draft.text.length / 5.0).ceil/200.0).ceil,
                created_at: draft.created_at,
                updated_at: draft.updated_at
            }
            render json: response
        else
            render json: { error: 'Failed to update the draft' }, status: :unprocessable_entity
        end
    end


    def draft_post
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end
        
        id = params.fetch(:id, "")
        if id!=""
            drafts = Draft.joins(:author).where(authors: { username: current_user.username })
            id=id.to_i
            draft = drafts.find_by(id: params[:id])
            unless draft
                render json: { error: 'Draft not found' }, status: :not_found
                return
            end
            article = Article.new(
                title: draft.title,
                text: draft.text,
                topic: draft.topic,
                author: draft.author
            )

            if article.save
                draft.destroy
                # Update the article_ids of the associated author with the new article's ID
                author=Author.find_by(username: current_user.username)
                topic=Topic.find_by(name: article.topic.name)
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
                    created_at: article.created_at,
                    updated_at: article.updated_at
                  }
    
                render json: response, status: :created
            else
                render json: { error: article.errors.full_messages.join(', ') }, status: :unprocessable_entity
            end
        else
            response={message: "Pass an id to post draft"}
            render json: response, status: :unprocessable_entity
        end
    end

    def draft_delete
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end
        
        id=params[:id]
        unless id
          render json: {message: "Pass an id to draft"}, status: :unprocessable_entity
          return
        end

        id=id.to_i

        drafts = Draft.joins(:author).where(authors: { username: current_user.username })
        draft = drafts.find_by(id: params[:id])

        unless draft
            render json: { error: 'Draft not found' }, status: :not_found
            return
        end

        draft.destroy
        render json: {message: "Draft deleted successfully"}, status: :ok
    end


   private

    def draft_params
        # Permit only the specific fields from the request parameters
        params.permit(:title, :text, :topic, :image)
    end

    def edit_params
        allowed_params = params.permit(:id, :title, :topic, :text, :image)
        # Filter out any keys with nil values
        allowed_params.reject { |key, value| value.nil? }

  
        if allowed_params[:topic]
          topic_name = allowed_params[:topic]
          new_topic = Topic.find_or_create_by(name: topic_name)
    
          allowed_params[:topic] = new_topic
          
        end
  
        allowed_params
    end
end

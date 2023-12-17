class ListsController < ApplicationController
    def my_lists
        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        response = lists.map do |list|
            {
              id: list.id,
              name: list.name,
              articles_included: list.article_ids,
              shared_with: list.shared_with,
            }
        end
        render json: response
    end

    def create_list
        unless current_user
            render json: {message: "Sign up or log in"}, status: :unauthorized
            return
        end
        
        name=params.fetch("name")
        
        if name == ""
            render json: {error: "Give a name for the list"}, status: :created
            return
        end

        un=current_user.username
        author=Author.find_by(username: un)
        list=List.new(author: author, name: name)
        if list.save
            render json: {message: "List created successfully, add articles and share"}, status: :created
        else
            render json: {error: list.errors.full_messages.join(', ')}, status: :unprocessable_entity
        end
    end

    def insert_article
        list_id=params.fetch(:list_id, "")
        article_id=params.fetch(:article_id, "")

        if article_id=="" || list_id==""
            render json: {error: "Need list id and article id"}, status: :unprocessable_entity
            return
        end
        list_id=list_id.to_i
        article_id=article_id.to_i
        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        list=lists.find(list_id)
        unless list
            render json: {error: "No such list"}, status: :not_found
            return
        end
        article=Article.find(article_id)
        unless article
            render json: {error: "No such article"}, status: :not_found
            return
        end
        unless list.article_ids.include?(article_id)
            list.article_ids << article_id
            list.save
        end
        response =
            {
              id: list.id,
              name: list.name,
              articles_included: list.article_ids,
              shared_with: list.shared_with,
            }
        render json: response, status: :ok
    end


    def remove_article
        list_id=params.fetch(:list_id, "")
        article_id=params.fetch(:article_id, "")

        if article_id=="" || list_id==""
            render json: {error: "Need list id and article id"}, status: :unprocessable_entity
            return
        end
        list_id=list_id.to_i
        article_id=article_id.to_i
        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        list=lists.find(list_id)
        unless list
            render json: {error: "No such list"}, status: :not_found
            return
        end
        article=Article.find(article_id)
        unless article
            render json: {error: "No such article"}, status: :not_found
            return
        end
        if list.article_ids.include?(article_id)
            list.article_ids.delete(article_id)
            list.save
        end
        response =
            {
              id: list.id,
              name: list.name,
              articles_included: list.article_ids,
              shared_with: list.shared_with,
            }
        render json: response, status: :ok
    end

    def share_list
        list_id=params.fetch(:list_id, "")
        uname=params.fetch(:uname, "")

        if uname=="" || list_id==""
            render json: {error: "Need list id and shared to uname"}, status: :unprocessable_entity
            return
        end
        list_id=list_id.to_i

        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        list=lists.find(list_id)
        unless list
            render json: {error: "No such list"}, status: :not_found
            return
        end
        shared_to=Author.find_by(username: uname)
        unless shared_to
            render json: {error: "No such user"}, status: :not_found
            return
        end

        unless list.shared_with.include?(uname)
            list.shared_with << uname
            shared_to.shared_lists << list_id
            list.save
            shared_to.save
        end

        response =
            {
              id: list.id,
              name: list.name,
              articles_included: list.article_ids,
              shared_with: list.shared_with,
            }
        render json: response, status: :ok
    end

    def unshare_list
        list_id=params.fetch(:list_id, "")
        uname=params.fetch(:uname, "")

        if uname=="" || list_id==""
            render json: {error: "Need list id and shared to uname"}, status: :unprocessable_entity
            return
        end
        list_id=list_id.to_i

        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        list=lists.find(list_id)
        unless list
            render json: {error: "No such list"}, status: :not_found
            return
        end
        shared_to=Author.find_by(username: uname)
        unless shared_to
            render json: {error: "No such user"}, status: :not_found
            return
        end

        if list.shared_with.include?(uname)
            list.shared_with.delete(uname)
            shared_to.shared_lists.delete(list_id)
            list.save
            shared_to.save
        end

        response =
            {
              id: list.id,
              name: list.name,
              articles_included: list.article_ids,
              shared_with: list.shared_with,
            }
        render json: response, status: :ok
    end

    def delete_list
        list_id=params.fetch(:list_id, "")

        if list_id==""
            render json: {error: "Need list id"}, status: :unprocessable_entity
            return
        end
        list_id=list_id.to_i

        unless current_user
            render json: {error: "Sign up or login"}, status: :not_found
            return
        end
        lists = List.joins(:author).where(authors: { username: current_user.username })
        list=lists.find(list_id)
        unless list
            render json: {error: "No such list"}, status: :not_found
            return
        end
        shared_users=list.shared_with
        l=shared_users.length()
        ctr=0
        while ctr<l
            sun=shared_users[ctr]
            author=Author.find_by(username: sun)
            author.shared_lists.delete(list_id)
            author.save
            ctr+=1
        end
        list.destroy
        render json: {message: "List deleted successfully"}, status: :ok
    end
end

# ActiveAdmin.register Tag, namespace: false do
#   c
#   controller do

#     def autocomplete_tags
#       @tags = ActsAsTaggableOn::Tag.
#         where("name LIKE ?", "#{params[:q]}%").
#         order(:name)
#       respond_to do |format|
#         format.json { render json: @tags , :only => [:id, :name] }
#       end
#     end
#   end
# end

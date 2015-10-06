ActiveAdmin.register ActsAsTaggableOn::Tag, namespace: :admin, as: "Tag" do
  index do
    selectable_column
    column :name
    column(:items) do |tag|
      link_to tag.taggings.count, admin_items_path(q: {taggings_tag_id_eq: tag.id})
    end
    actions
  end

  filter :name
  # filter :taggings_taggable_id_in
  # filter :items_place_in, as: :select, collection: Place.all
  filter :taggings_count, label: "Used on (count)"
end

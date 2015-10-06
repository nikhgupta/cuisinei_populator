ActiveAdmin.register Item, namespace: :admin do
  config.sort_order = "place_id_desc"
  index do
    selectable_column
    column :place, sortable: :place_id
    column :name_with_description, sortable: :name do |item|
      content_tag :p do
        content_tag(:strong){item.name} +
          ("<span class='tag'>" + item.tags.join("</span><span class='tag'>") + "</span>").html_safe +
          tag(:br) +
          content_tag(:span){item.description}
      end
    end
    actions
  end

  form do |f|
    f.inputs "Place Details" do
      content_tag :p, style: "margin-left: 20px" do
        concat content_tag(:strong, f.object.place.title)
        concat tag(:br)
        concat content_tag(:span, f.object.place.address)
      end
    end
    f.inputs "Item Details" do
      f.input :name, input_html: { class: "item-name" }
      f.input :cost, input_html: { class: "item-cost" }
      f.input :description, input_html: { rows: 3 }
      f.input :tag_list, as: :select, multiple: true, label: "Tags", include_blank: false,
        collection: ActsAsTaggableOn::Tag.all.map{|t| [t.name, t.name]},
        selected: f.object.tags.pluck(:name), input_html: { class: "tagselect item-tags", style: "width: 80%" }
    end
    f.actions
  end
end

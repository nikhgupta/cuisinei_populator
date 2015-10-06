ActiveAdmin.register Place, namespace: false do
  menu false
  config.clear_action_items!
  config.sort_order = "completed_at_desc"
  actions :all, except: [:show, :destroy]

  action_item(:total){link_to "Earnings: #{number_to_currency current_user.earnings}", places_path if current_user.on_per_item_basis?}

  action_item(:index){ link_to "Past Assignments", places_path }
  action_item(:add){ link_to "Start Working...", new_place_path }
  permit_params items_attributes: [ :id, :name, :cost, :description, :_destroy, tag_list: [] ]

  controller do
    def new
      city = City.which_require_more_places_covered.first
      if city.completed?
        flash[:notice] = "City: #{city.name} was successfully finished. Loaded new city."
        redirect_to action: :new
      else
        @resource = city.random_place_for(current_user)
        @resource.fetch_images
        new!
      end
    rescue ZomatoScraperService::Error => e
      city.update_attribute :completed_at, Time.now
      flash[:alert] = "#{e.message} for city: #{city.address}!"
      redirect_to action: :index
    end

    def edit
      if resource.locker && resource.locker != current_user
        flash[:alert] = "This record is already being edited by some other user. You should not edit this."
      elsif resource.pending? && !resource.locker
        flash[:alert] = "This record has not been allotted to you, yet. Please, only update records that have been alloted to you."
      end
      edit!
    end

    def update
      if params["place"]["items_attributes"].present?
        # remove any item that was submitted without supplying a name.
        # useful since it will be common to click add item and then update place
        params["place"]["items_attributes"].select do |key, val|
          val["name"].blank?
        end.each do |key, val|
          params["place"]["items_attributes"].delete(key)
        end

        # sort keys correctly
        params["place"]["items_attributes"] = Hash[params["place"]["items_attributes"].sort_by{|k,v| k.to_i}]
      end

      submit_status = permitted_params[:commit].downcase
      if resource.locker && resource.locker != current_user
        message = "Cannot update record locked by another user."
      elsif !resource.locker
        message = "Cannot update record that was not alloted to you."
      elsif resource.items.blank? && submit_status.include?("completed")
        message = "Cannot mark task without menu items as complete."
      elsif resource.pending? && submit_status.include?("incomplete")
        message = "Task is already pending!"
      end

      if message
        flash[:error] = message
        redirect_to edit_place_path(resource) and return
      elsif resource.errors.empty? && submit_status.include?("completed")
        resource.complete!
      elsif resource.errors.empty? && submit_status.include?("incomplete")
        resource.pending!
      end
      update!{ new_place_path }
    end
  end

  index do
    column :title
    column :address
    column(:type, sortable: :establishment_name){|place| place.establishment_name.titleize}
    column :rating, :ref_rating
    column :votes, :ref_votes_count
    column(:created, sortable: :created_at){|place| time_ago_in_words(place.created_at) + " ago"}
    column "#items", :items_count
    column(:completed, sortable: :completed_at) do |place|
      place.completed_at ? time_ago_in_words(place.completed_at) + " ago" : nil
    end
    actions
  end

  form do |f|
    panel "Place Details", class: "place-details" do
      columns do
        column do
          h2 f.object.title
          h4 f.object.address
          span(class: "status_tag yes"){ f.object.establishment_name.titleize }
          br; br; span(class: "status_tag no"){ "#{f.object.ref_rating} Rating" }
          span(class: "status_tag no"){ "#{f.object.ref_votes_count} Votes" }
          if f.object.items_count > 0
            br; br; span(class: "status_tag yes"){ "#{f.object.items_count} Menu Items Added So Far" }
          end
          br; br;
          if f.object.completed?
            h4(class: "success"){ "#{f.object.locker == current_user ? "You" : "Someone"} marked this as completed!" }
          elsif f.object.locker.present?
            h4(class: "warning"){ "#{f.object.locker == current_user ? "You are" : "Someone is"} working on this!" }
          end
          br; br; a(href: f.object.ref_url, target: "_blank", class: "zomato-link"){ "Visit on Zomato" }
        end
        column do
          img src: f.object.static_map_url, class: "static-map"
        end
      end
    end

    panel "Item Details" do
      columns do
        column class: "column menu-images" do
          if f.object.menu_images.any?
            f.object.menu_images.each do |image|
              img src: image.url
            end
          else
            a(href: f.object.ref_menu_url, target: "_blank", class: "zomato-link"){ "Visit Menu on Zomato" }
          end
        end

        column do
          f.has_many :items, heading: "", allow_destroy: true do |b|
            selected = ActsAsTaggableOn::Tag.none
            if b.object.tags.any?
              selected = b.object.tags
            elsif f.object.items.any?
              selected = f.object.items.last.tags
            end
            b.input :name, input_html: { class: "item-name" }
            b.input :cost, input_html: { class: "item-cost" }
            b.input :description, input_html: { rows: 3 }
            b.input :tag_list, as: :select, multiple: true, label: "Tags", include_blank: false,
              collection: ActsAsTaggableOn::Tag.all.map{|t| [t.name, t.name]},
              selected: selected.pluck(:name), input_html: { class: "tagselect item-tags", style: "width: 80%" }
          end
        end
      end
    end

    f.actions do
      f.action :submit
      if f.object.completed?
        f.action :submit, label: "Mark as incomplete!"
      else
        f.action :submit, label: "Mark as completed!"
      end
      f.action :cancel, wrapper_html: { class: 'cancel'}
    end
  end
end

ActiveAdmin.register Place, namespace: :admin do
  config.clear_action_items!
  config.sort_order = "locked_by_asc_and_completed_at_desc_and_ref_rating_desc"
  actions :all, except: [:show]

  permit_params :locked_by, items_attributes: [ :id, :name, :cost, :description, :_destroy, tag_list: [] ]

  controller do
    def new
      city = City.which_require_more_places_covered.first
      if city.has_no_pending_place? && city.requires_no_new_places?
        flash[:notice] = "City: #{city.name} was successfully finished. Loaded new city."
        redirect_to action: :new
      else
        @resource = city.random_place_for(current_user)
        @resource.fetch_images
        new!
      end
    rescue ZomatoScraperService::Error => e
      city.update_attribute :completed_at, Time.now
      flash[:alert] = "#{e.message} for city: #{city.address}!"
      redirect_to action: :index
    end
    def edit

    end
    def update
      if params["place"]["items_attributes"].present?
        # remove any item that was submitted without supplying a name.
        # useful since it will be common to click add item and then update place
        params["place"]["items_attributes"].select do |key, val|
          val["name"].blank?
        end.each do |key, val|
          params["place"]["items_attributes"].delete(key)
        end

        # sort keys correctly
        params["place"]["items_attributes"] = Hash[params["place"]["items_attributes"].sort_by{|k,v| k.to_i}]
      end

      submit_status = permitted_params[:commit].downcase
      resource.complete! if resource.errors.empty? && submit_status.include?("completed")
      resource.pending!  if resource.errors.empty? && submit_status.include?("incomplete")
      update!{ edit_admin_place_path(resource) }
    end
  end

  index do
    column :title
    column :address
    column(:type, sortable: :establishment_name){|place| place.establishment_name.try :titleize}
    column :rating, :ref_rating
    column :votes, :ref_votes_count
    column(:created, sortable: :created_at){|place| time_ago_in_words(place.created_at) + " ago"}
    column(:in_progress?, sortable: :locked_by) do |place|
      link_to(place.locker) if place.locker.present?
    end
    column "#items", :items_count
    column(:completed, sortable: :completed_at) do |place|
      place.completed_at ? time_ago_in_words(place.completed_at) + " ago" : nil
    end
    actions
  end

  filter :city
  filter :locked_by, label: "Worker", as: :select, collection: User.all
  filter :title
  filter :address
  filter :lat, label: "Latitude"
  filter :lng, label: "Longitude"
  filter :establishment_name, label: "Type"
  filter :ref_rating, label: "Rating"
  filter :ref_votes_count, label: "Votes"
  filter :items_count, label: "Number of Added Items"
  filter :locked_at
  filter :created_at
  filter :completed_at

  form do |f|
    panel "Place Details", class: "place-details" do
      columns do
        column do
          h2 f.object.title
          h4 f.object.address
          span(class: "status_tag yes"){ f.object.establishment_name.try :titleize }
          br; br; span(class: "status_tag no"){ "#{f.object.ref_rating} Rating" }
          span(class: "status_tag no"){ "#{f.object.ref_votes_count} Votes" }
          if f.object.items_count > 0
            br; br; span(class: "status_tag yes"){ "#{f.object.items_count} Menu Items Added So Far" }
          end
          br; br;
          if f.object.completed?
            h4(class: "success"){ "#{f.object.locker} marked this as completed!" }
          elsif f.object.locker.present?
            h4(class: "warning"){ "#{f.object.locker} is working on this!" }
          end
          br; br; a(href: f.object.ref_url, target: "_blank", class: "zomato-link"){ "Visit on Zomato" }
        end
        column do
          img src: f.object.static_map_url, class: "static-map"
        end
      end
    end

    f.inputs "Place Details" do
      f.input :locker, label: "Worker"
    end

    panel "Item Details" do
      columns do
        column class: "column menu-images" do
          if f.object.menu_images.any?
            f.object.menu_images.each do |image|
              img src: image.url
            end
          else
            a(href: f.object.ref_menu_url, target: "_blank", class: "zomato-link"){ "Visit Menu on Zomato" }
          end
        end

        column do
          f.has_many :items, heading: "", allow_destroy: true do |b|
            selected = ActsAsTaggableOn::Tag.none
            if b.object.tags.any?
              selected = b.object.tags
            elsif f.object.items.any?
              selected = f.object.items.last.tags
            end
            b.input :name, input_html: { class: "item-name" }
            b.input :cost, input_html: { class: "item-cost" }
            b.input :description, input_html: { rows: 3 }
            b.input :tag_list, as: :select, multiple: true, label: "Tags", include_blank: false,
              collection: ActsAsTaggableOn::Tag.all.map{|t| [t.name, t.name]},
              selected: selected.pluck(:name), input_html: { class: "tagselect item-tags", style: "width: 80%" }
          end
        end
      end
    end

    f.actions do
      f.action :submit
      if f.object.completed?
        f.action :submit, label: "Mark as incomplete!"
      elsif f.object.items_count > 0
        f.action :submit, label: "Mark as completed!"
      end
      f.action :cancel, wrapper_html: { class: 'cancel'}
    end
  end
end

ActiveAdmin.register Place, namespace: false do
  menu false
  config.clear_action_items!
  config.sort_order = "completed_at_desc"
  actions :all, except: [:show, :destroy]

  action_item(:index){ link_to "Past Assignments", places_path }
  action_item(:add){ link_to "Start Working...", new_place_path }
  permit_params items_attributes: [ :id, :name, :cost, :min_time, :max_time, :extra, :description, :_destroy ]

  controller do
    def new
      city = City.which_require_more_places_covered.first
      if city.has_no_pending_place? && city.requires_no_new_places?
        flash[:notice] = "City: #{city.name} was successfully finished. Loaded new city."
        redirect_to action: :new
      else
        @resource = RandomPlaceGeneratorService.new(current_user, city: city).run
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
          else
            h4(class: "warning"){ "#{f.object.locker == current_user ? "You are" : "Someone is"} working on this!" }
          end
          br; br; a(href: f.object.ref_url, target: "_blank", class: "zomato-link"){ "Visit on Zomato" }
        end
        column do
          img src: f.object.static_map_url, class: "static-map"
        end
      end
    end

    f.has_many :items, heading: "", allow_destroy: true do |b|
      b.input :name
      b.input :cost
      b.input :min_time
      b.input :max_time
      b.input :description, input_html: { rows: 3 }
      b.input :extra, input_html: { rows: 3 }
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
  config.sort_order = "ref_rating_desc"

  permit_params :locked_by, items_attributes: [:id, :name, :cost, :min_time, :max_time, :extra, :description, :_destroy]

  controller do
    def update
      submit_status = permitted_params[:commit].downcase
      resource.complete! if resource.errors.empty? && submit_status.include?("completed")
      resource.pending!  if resource.errors.empty? && submit_status.include?("incomplete")
      update!{ admin_places_path }
    end
  end

  index do
    column :title
    column :address
    column(:type, sortable: :establishment_name){|place| place.establishment_name.titleize}
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
          span(class: "status_tag yes"){ f.object.establishment_name.titleize }
          br; br; span(class: "status_tag no"){ "#{f.object.ref_rating} Rating" }
          span(class: "status_tag no"){ "#{f.object.ref_votes_count} Votes" }
          if f.object.items_count > 0
            br; br; span(class: "status_tag yes"){ "#{f.object.items_count} Menu Items Added So Far" }
          end
          br; br;
          if f.object.completed?
            h4(class: "success"){ "#{f.object.locker} marked this as completed!" }
          else
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

    f.has_many :items, heading: "", allow_destroy: true do |b|
      b.input :name
      b.input :cost
      b.input :min_time
      b.input :max_time
      b.input :description, input_html: { rows: 3 }
      b.input :extra, input_html: { rows: 3 }
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

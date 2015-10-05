ActiveAdmin.register Place do
  config.sort_order = "locked_by_asc"
  actions :all, except: [:show, :destroy]

  permit_params items_attributes: [:id, :name, :cost, :min_time, :max_time, :extra, :description, :_destroy]

  action_item :add do
    link_to "Start Working...", new_place_path
  end

  controller do
    def new
      if current_user.has_pending_workable?
        @resource = current_user.pending_workables.sample
      else
        # select a random city that has less than given restaurants covered
        city = City.which_require_more_places_covered.first

        # lock the resource so no other user is trying to complete this place
        if city.places_count < ENV['MIN_COVERAGE_PER_CITY'].to_i && city.has_no_pending_place?
          options = city.bounds.merge(page: city.places_count / 30)
          begin
            places  = ZomatoScraperService.new(options).run
          rescue ZomatoScraperService::Error => e
            city.update_attribute :completed_at, Time.now
            flash[:alert] = "#{e.message} for city: #{city.address}!"
            redirect_to action: :index and return
          end
          places.each{|place| city.places.create place }
        end

        if city.has_no_pending_place?
          flash[:notice] = "City: #{city.name} was successfully finished. Loaded new city."
          redirect_to action: :new and return
        end

        @resource = city.pending_places.reload.sample
        @resource.locked_via current_user
      end
      new!
    end

    def edit
      if resource.locker && resource.locker != current_user
        flash[:alert] = "This place is already being edited by some other user."
        redirect_to action: :index
      else
        resource.locked_via current_user
        edit!
      end
    end
  end

  index do
    column :title
    column :address
    column(:type, sortable: :establishment_name){|place| place.establishment_name.titleize}
    column :rating, :ref_rating
    column :votes, :ref_votes_count
    # TODO: should rather display who is working on it
    column(:created, sortable: :created_at){|place| time_ago_in_words(place.created_at) + " ago"}
    column(:in_progress?, sortable: :locked_by) do |place|
      link_to(place.locker, place.locker) if place.locker.present?
    end
    column "#items", :items_count
    column(:completed, sortable: :completed_at) do |place|
      place.completed_at ? time_ago_in_words(place.completed_at) + " ago" : nil
    end
    actions
  end

  filter :city
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
          br; br; a(href: f.object.ref_url, target: "_blank", class: "zomato-link"){ "Visit on Zomato" }
        end
        column do
          img src: f.object.static_map_url, class: "static-map"
        end
      end
    end

    f.inputs "Menu Items" do
      f.has_many :items, heading: "" do |b|
        b.input :name
        b.input :cost
        b.input :min_time
        b.input :max_time
        b.input :description, input_options: { row: 3 }
        b.input :extra
      end
    end

    actions
  end
end

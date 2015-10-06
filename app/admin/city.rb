ActiveAdmin.register City, namespace: :admin do
  config.sort_order = "population_desc"
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  action_item :add, if: ->{ !current_user.admin? } do
    link_to "Start Working...", new_place_path
  end

  member_action :prioritize, method: :put do
    priority = resource.priority.to_i > 0 ? false : true
    resource.update_attribute :priority, priority
    redirect_to admin_cities_path, notice: "City: #{resource.name} was #{priority ? "prioritized" : "deprioritized"}."
  end

  index do
    selectable_column
    column :name
    column :state
    column(:population, sortable: :population){|city| number_with_delimiter(city.population) }
    column(:prioritized?, sortable: :priority){|city| status_tag(city.priority.to_i > 0)}
    column :total_places, :places_count
    column :completed_places, :completed_places_count
    actions default: true do |city|
      link_to "Toggle Priority", prioritize_admin_city_path(city), method: :put, class: "member_link" if policy(:city).prioritize?
    end
  end

  filter :name
  filter :state
  filter :population
  filter :places_count, label: "Total Places"
  filter :completed_places_count, label: "Completed Places"
  filter :priority, as: :boolean
end

ActiveAdmin.register City do
  config.sort_order = "priority_desc,population_desc"
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  index do
    selectable_column
    column :name
    column :state
    column(:population, sortable: :population){|city| number_with_delimiter(city.population) }
    column(:prioritized?, sortable: :priority){|city| status_tag(city.priority.to_i > 0)}
    column :total_places, :places_count
    column :completed_places, :completed_places_count
    actions
  end

  filter :name
  filter :state
  filter :population
  filter :places_count, label: "Total Places"
  filter :completed_places_count, label: "Completed Places"
  filter :priority, as: :boolean
end

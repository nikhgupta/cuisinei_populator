ActiveAdmin.register User, namespace: :admin do
  permit_params :email, :password, :password_confirmation, :admin, :per_item_earnings

  index do
    selectable_column
    id_column
    column :email
    column :admin
    column :workables_count
    column :sign_in_count
    column :current_sign_in_at
    column :created_at
    actions
  end

  filter :email
  filter :workables_count, label: "#workables"
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :per_item_earnings, input_html: { placeholder: "How much to pay per menu item (not per restaurant), if hired so?", value: (f.object.on_per_item_basis? ? f.object.per_item_earnings : nil) }
      f.input :admin, label: "<strong>User is an admin? <span style='color: #f52'>Be very very careful with this!</span></strong>".html_safe
    end
    f.actions
  end
end

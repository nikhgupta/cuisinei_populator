ActiveAdmin.register User, namespace: :admin do
  permit_params :email, :password, :password_confirmation

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
    end
    f.actions
  end
end

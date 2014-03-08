WeixinJob::Application.routes.draw do
  get "company_profiles/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :logins do
    collection do
      post :valid
      get :regist, :sign_out
    end

  end

  resources :companies do
    resources :company_profiles do
      collection do
        post :upload_img
      end
      member do
        get :show_tuwen_page
      end
    end
    resources :position_types
    resources :resumes do
      collection do
        get :add_form_item
      end
    end
    resources :positions do
      collection do
        get :search_position
      end
      member do
        get :release
      end
    end
    resources :menus

    resources :exports do
      collection do
        get :create_xsl_table,:down_zip_file
      end
    end

    resources :app_managements

  end

  resources :weixins

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'logins#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

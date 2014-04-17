WeixinJob::Application.routes.draw do
  get "work_addresses/index"

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
match "/get_token", :to => "app_managements#get_token", :as => "get_token", via: 'get'
match '/submit_redirect' => 'app_managements#submit_redirect', :as => :submit_redirect, :via => :get
match "/weixins/accept_token" => "weixins#accept_token"

  resources :logins do
    collection do
      post :valid
      get :regist, :sign_out
    end

  end

  resources :companies do
    collection do
      get :synchronize_old_users
    end
    resources :work_addresses

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
        get :add_form_item,:newest_resumes,:choice_position,
          :audition_resume,:refuse_resume,:pass_resume,:show_resume
      end
      member do
        get :change_status,:deal_audition,:deal_join,:show_resumes_new
      end
    end
    resources :positions do
      collection do
        get :search_position,:history_index,:create_position
        post :send_resume
      end
      member do
        get :release,:dis_release,:see_position,:edit_position
      end
    end
    resources :menus
    resources :exports do
      collection do
        get :create_xsl_table,:down_zip_file
      end
    end

    resources :app_managements do
      collection do
        post :create_client_info_model, :get_form_date
        get :app_regist
      end
    end

    resources :reminds
    resources :records
    resources :address_settings do
      collection do
        get :search_citties
      end
    end
  end

  resources :client_resumes do
    collection do
      get :create_friend_resume
      post :create_friend_resume_commit
    end
  end

  resources :weixins


  namespace :api do
    resources :clients do
      collection do
        post :login, :message_detail, :refresh, :del_recent_client, :get_token
        post :edit_client, :set_receive, :set_undisturbed
      end
    end
    resources :messages do
      collection do
        post :make_record, :edit_record, :send_message_to_user
      end
    end
  end
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

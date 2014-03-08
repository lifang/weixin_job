class Record < ActiveRecord::Base
  attr_accessible :content, :site_id, :title
end

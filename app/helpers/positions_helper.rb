module PositionsHelper
  def find_name_from(position_types,id)
    position_types.each do |pt|
      if pt.id == id
        return pt.name
      end
    end
    nil
  end

  def get_address_name address
    "#{address.province}#{address.city}#{address.address}"
  end
end

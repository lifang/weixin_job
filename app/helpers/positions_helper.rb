module PositionsHelper
  def find_name_from(position_types,id)
    position_types.each do |pt|
      if pt.id == id
        return pt.name
      end
    end
    nil
  end
end

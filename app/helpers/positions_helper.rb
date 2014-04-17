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

  def if_address?(addr_and_position_relations,position,work_addresses,w_a_id)
    addr_and_position_relations.each do |aapr|
      if aapr.position_id==position.id
        work_addresses.each do |wa|
          if wa.id == w_a_id && wa.id == aapr.work_address_id
            return true;
          end
        end
      end
    end
    false
  end

end

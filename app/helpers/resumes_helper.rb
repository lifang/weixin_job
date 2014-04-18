module ResumesHelper
  def get_name_and_phone content
    content[]
  end
  def is_have_file? hash
    hash.each do |h|
      if h[0].include?("file")
        return h[1].values[0]
      end
    end
    ""
  end
end

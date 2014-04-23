module MicroMessageHelper

   #删除图片
  def destroy_Original_img original_img_true_path
    FileUtils.rm original_img_true_path if File::exist?( original_img_true_path )
    FileUtils.rm get_min1_by_imgpath original_img_true_path if File::exist?(get_min1_by_imgpath original_img_true_path)
    FileUtils.rm get_min2_by_imgpath original_img_true_path if File::exist?(get_min2_by_imgpath original_img_true_path)

  end
  #得到mini_magic变得两种小图
  def get_min1_by_imgpath(imgname1)
    img=imgname1.split(".")
    img[0...-1].join('.')+"_min1."+img[-1]
  end
  def get_min2_by_imgpath(imgname1)
    img=imgname1.split(".")
    img[0...-1].join('.')+"_min2."+img[-1]
  end
end
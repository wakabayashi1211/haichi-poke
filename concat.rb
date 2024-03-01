require 'rmagick'
require 'find'
require 'json'

def laod_json(json_path)
  json = ''
  File.open(json_path) do |file|
    json = JSON.load(file)
  end
  # keyの番号順に並び替える
  json = json.sort_by { |k, v| k.to_i }.to_h
  # valueのnameを取得
  pokemon_names_in_party = json.values.map { |v| v["name"] }
  p pokemon_names_in_party
  pokemon_names_in_party
end

# 長さが6のポケモン名のりストから画像を結合する
def concat_images(pokemon_names_in_party, result_path="to.jpg")
  image_list_columns = Magick::ImageList.new
  for row_index in 0..2 do
    image_list_row = Magick::ImageList.new
    index_1 = row_index * 2
    index_2 = index_1 + 1
    image1 = Magick::Image.read("data/img/#{pokemon_names_in_party[index_1]}.png").first
    image2 = Magick::Image.read("data/img/#{pokemon_names_in_party[index_2]}.png").first
    image1, image2 = resize_image(image1), resize_image(image2)
    image_list_row.push(image1, image2)
    image_list_columns.push(image_list_row.append(false))
  end
  image = image_list_columns.append(true)
  image.write(result_path)
end

def resize_image img
  img = img.resize_to_fit!(90, 90)
  bg = Magick::Image.new(100, 100)
  bg.background_color="white"
  bg.composite!(img, Magick::CenterGravity, Magick::OverCompositeOp)
  bg
end

def main
  dir = '/app/data/settings'
  Find.find(dir) do |path|
    if FileTest.directory?(path)
      next
    else
      if File.extname(path) == ".json"
        file_name = File.basename(path, ".json")
        pokemon_names_in_party=laod_json(path)
        Dir.mkdir('./output') unless Dir.exist?('./output')
        concat_images(pokemon_names_in_party, "./output/#{file_name}.png")
      end
    end
  end
end

main

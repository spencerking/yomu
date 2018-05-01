require 'RTesseract'
require 'net/http'
require 'json'
require 'cgi'

# Configuration
SCREENSHOT_DIR = ENV['HOME']
LANG = "jpn"
PROCESSOR = "mini_magick"

# Get the date for the screenshot name
img = Time.now.to_i

# Take the screenshot
cmd = "screencapture -o -i " + img.to_s
system(cmd)

# Process the image
image = RTesseract.new(img.to_s, :lang => "jpn", :processor => "mini_magick")
 
# Translate
sourceLang = "ja"
targetLang = "en"
sourceText = image.to_s

url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + sourceLang + "&tl=" + targetLang + "&dt=t&q=" + CGI.escape(sourceText)
uri = URI(url)
response = Net::HTTP.get(uri)
parsed_json = JSON.parse(response)

translation = parsed_json[0].to_s.split(",")[0]
translation = translation.gsub(/"|\[/, '')

puts sourceText
puts translation

# TODO AppleScript can get very confused based on the results from Google Translate
# Use AppleScript to output a notification
# cmd = %Q[osascript -e 'display notification "] + translation + %Q[" with title "Title"']
# system(cmd)
require 'RTesseract'
require 'terminal-notifier'
require 'net/http'
require 'json'
require 'cgi'

# Configuration
# SCREENSHOT_DIR = ENV['HOME'] + 
LANG = "jpn"
PROCESSOR = "mini_magick"

# Get the date for the screenshot name
img = Time.now.to_i

# Take the screenshot
cmd = "screencapture -o -i " + img.to_s
system(cmd)

# Process the image
image = RTesseract.new(img.to_s, :lang => LANG, :processor => PROCESSOR)
 
# Translate
case LANG
	when "fra"
		sourceLang = "fr"
	when "jpn"
		sourceLang = "ja"
	else
		puts "Error unknown language"
		exit
end

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

# Create a notification
TerminalNotifier.notify(translation, :title => 'yomu')
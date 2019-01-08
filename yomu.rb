require 'RTesseract'
require 'terminal-notifier'
require 'cld'
require 'net/http'
require 'json'
require 'cgi'

# Configuration
# SCREENSHOT_DIR = ENV['HOME'] +
LANG = "jpn+fra"
PROCESSOR = "mini_magick"

# Get the date for the screenshot name
img = Time.now.to_i

# Take the screenshot
cmd = "screencapture -o -i " + img.to_s
system(cmd)

# Process the image
image = RTesseract.new(img.to_s, :lang => LANG, :processor => PROCESSOR)

# Translate
detectLang = CLD.detect_language(image.to_s)
sourceLang = detectLang[:code]
targetLang = "en"
sourceText = image.to_s

url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + sourceLang + "&tl=" + targetLang + "&dt=t&q=" + CGI.escape(sourceText)
uri = URI(url)
response = Net::HTTP.get(uri)
parsed_json = JSON.parse(response)

translation = parsed_json[0].to_s.split(",")[0]
translation = translation.gsub(/"|\[/, '')

puts "Source: \n" + sourceText
puts "Translation: \n" + translation

if ARGV[0] == "n"
  # Create a notification
  TerminalNotifier.notify(translation, :title => 'yomu')
end

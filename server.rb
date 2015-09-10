# This file provided by Facebook is for non-commercial testing and evaluation purposes only.
# Facebook reserves all rights not expressly granted.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'webrick'
require 'json'

port = ENV['PORT'].nil? ? 3000 : ENV['PORT'].to_i

puts "Server started: http://localhost:#{port}/"

root = File.expand_path './public'
server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => root

server.mount_proc '/players.json' do |req, res|
  players = JSON.parse(File.read('./players.json'))

  if req.request_method == 'POST'
    print req.query
    # Assume it's well formed
    player = {}
    req.query.each do |key, value|
      player[key] = value.force_encoding('UTF-8')
    end
    players.each_with_index do |elt, index|
      if player["batPosition"] < elt["batPosition"]
        players.insert(index, player)
        break
      end
    end
    File.write('./players.json', JSON.pretty_generate(players, :indent => '    '))
  end

  # always return json
  res['Content-Type'] = 'application/json'
  res['Cache-Control'] = 'no-cache'
  res.body = JSON.generate(players)
end

server.mount_proc '/comments.json' do |req, res|
  # always return json
  res['Content-Type'] = 'application/json'
  res['Cache-Control'] = 'no-cache'
  res.body = JSON.generate([])
end

trap 'INT' do server.shutdown end

server.start

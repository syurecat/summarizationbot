require 'discordrb'
require 'uri'

BOT_TOKEN = ENV["SUMMARIZATION_BOT_TOKEN"]
BOT_CLIENT_ID = ENV["SUMMARIZATION_BOT_CLIENT_ID"]
SUMMARIZE_API_KEY = ENV["SUMMARIZE_API_KEY"]
talkapi_url = "https://api.a3rt.recruit.co.jp/text_summarization/v1" 

#botのセットアップ
bot = Discordrb::Commands::CommandBot.new(
    token: BOT_TOKEN,
    client_id: BOT_CLIENT_ID,
    prefix: "s"
)

bot.mention do |event|
    #メッセージの取得とメンション部分の削除
    message = event.message.content
    message = message.delete("<@#{BOT_CLIENT_ID}> ")
    p message

    #API通信
    uri = URI.parse(talkapi_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path)
    req.set_form_data({'apikey' => SUMMARIZE_API_KEY, 'sentences' => message})
    res = http.request(req)
    result = JSON.parse(res.body)

    #レスポンスの取得
#    message = result["status"] == 0 ? result["results"][0]["reply"] : "error#{result["status"]}\r\nmessege#{result["message"]}";

    if result["status"] == 0 then
        message = result["summary"][0]
    elsif result["status"] == 1413 then
        message = "too long...\r\n一文200字、10文まで要約できます。ちゃんと「。」を入れましたか？"
    else
        message = "error: #{result["status"]}\r\nmessege: #{result["message"]}";
    end

    p message
    event.respond message
end

bot.command :help do |event|
    bot.send_message("メンションの後に要約したい内容を入れると、このボットが話してくれます。一文200字、10文まで要約できます。")
end

bot.run
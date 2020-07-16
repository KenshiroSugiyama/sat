class LinebotController < ApplicationController
    require 'line/bot'
    
    protect_from_forgery 


    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
          error 400 do 'Bad Request' end
        end
        events = client.parse_events_from(body)
    
        events.each do |event|
            uid = event['source']['userId']
            case event
            when Line::Bot::Event::Follow then
                message = {
                    "type": "text",
                    "text": "登録完了！\r\nあなたのidは\r\n[#{uid}]\r\nです\r\nidを堅志郎に個チャで送ってね！"
                  }
                #user作成　uidをdbに保存　nameはラインの名前と違うからここで保存しない
                User.create(uid: uid)
            when Line::Bot::Event::Message then
                case event.type
                when Line::Bot::Event::MessageType::Text
                    e = event.message['text']
                    if e.eql?('データ確認')
                        #excel 指定
                        name = User.find_by(uid: uid).name
                        excel = Roo::Spreadsheet.open("app/assets/#{name}.xlsx")
                        sheet = excel.sheet('Sheet1')

                        message = {
                            "type": "text",
                            "text": "名前：#{sheet.row(1)[0]}\b\n"
                          }
                    else
                        message = {
                            "type": "text",
                            "text": "例外処理OK!"
                        }
                    end
                end
            end
            client.reply_message(event['replyToken'], message)
        end
        head :ok
    end


    private

    def client
        @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end
end

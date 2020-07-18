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
                        excel = Roo::Spreadsheet.open("app/assets/Book.xlsx")
                        sheet = excel.sheet("#{name}")

                        message = {
                            "type": "text",
                            "text": "\b\n#{sheet.row(1)[18]}：#{sheet.row(2)[18]}\b\n#{sheet.row(1)[19]}：#{sheet.row(2)[19]}\b\n#{sheet.row(1)[20]}：#{sheet.row(2)[20]}\b\n#{sheet.row(1)[21]}：#{sheet.row(2)[21]}\b\n#{sheet.row(1)[22]}：#{sheet.row(2)[22]}\b\n#{sheet.row(1)[23]}：#{sheet.row(2)[23]}\b\n#{sheet.row(1)[24]}：#{sheet.row(2)[24]}\b\n#{sheet.row(1)[25]}：#{sheet.row(2)[25]}\b\n#{sheet.row(1)[26]}：#{sheet.row(2)[26]}\b\n#{sheet.row(1)[27]}：#{sheet.row(2)[27]}\b\n#{sheet.row(1)[28]}：#{sheet.row(2)[28]}\b\n#{sheet.row(1)[29]}：#{sheet.row(2)[29]}\b\n#{sheet.row(1)[30]}：#{sheet.row(2)[30]}\b\n#{sheet.row(1)[31]}：#{sheet.row(2)[31]}\b\n#{sheet.row(1)[32]}：#{sheet.row(2)[32]}\b\n#{sheet.row(1)[33]}：#{sheet.row(2)[33]}\b\n#{sheet.row(1)[34]}：#{sheet.row(2)[34]}\b\n#{sheet.row(1)[35]}：#{sheet.row(2)[35]}\b\n#{sheet.row(1)[36]}：#{sheet.row(2)[36]}\b\n#{sheet.row(1)[37]}：#{sheet.row(2)[37]}\b\n#{sheet.row(1)[38]}：#{sheet.row(2)[38]}\b\n#{sheet.row(1)[39]}：#{sheet.row(2)[39]}"                       
                             }
                    else
                        message = {sheet.row(2)[0]
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

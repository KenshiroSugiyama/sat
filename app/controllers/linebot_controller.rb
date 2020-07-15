class LinebotController < ApplicationController
    require 'line/bot'
    require "net/http"
    require "json"

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
                  client.reply_message(event['replyToken'], message)
            when Line::Bot::Event::Message then
                case event.type
                when Line::Bot::Event::MessageType::Text
                    e = event.message['text']
                    if e.eql?('データ確認')
                        #excel 指定
                        #name = "Book1"
                        #file_path = Pathname(Rails.root) + "/assets/Book1.xlsx"
                        excel = Roo::Spreadsheet.open("app/assets/Book1.xlsx")
                        sheet = excel.sheet('Sheet1')

                        message = {
                            "type": "text",
                            "text": "名前：#{sheet.row(1)[0]}"
                          }
                    else
                        message = {
                            "type": "text",
                            "text": "例外処理OK!"
                        }
                    end
                    client.reply_message(event['replyToken'], message)
                end
            end
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

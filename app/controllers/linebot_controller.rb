class LinebotController < ApplicationController
    require 'line/bot'
    require "net/http"
    require "json"

    protect_from_forgery #追記
    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
          error 400 do 'Bad Request' end
        end
        events = client.parse_events_from(body)
    
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
                e = event.message['text']
                if e.eql?('データ確認')
                    excel = Roo::Spreadsheet.open('Book1.xlsx')
                    sheet = excel.sheet('Sheet1')


                    uri = URI.parse("https://api.line.me/v2/bot/message/push")
                    headers = {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + ENV['LINE_CHANNEL_TOKEN'],
                    }
                    
                    post = {
                        'to': "Ubb6cd737bcaea0aeb84c0465e3fff9ac",
                        'messages': [
                            {
                                "type": "text",
                                "text": " テスト！\r\n
                                名前: #{sheet.row(1)[0]}\r\n
                                スプリント: #{sheet.row(1)[1]}回
                                "
                            }
                        ]
                    }
                    
                    req = Net::HTTP.new(uri.host, uri.port)
                    req.use_ssl = uri.scheme === "https"
                    req.post(uri.path, post.to_json,headers)
                            
                end
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

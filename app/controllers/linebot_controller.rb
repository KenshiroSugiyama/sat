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
            when Line::Bot::Event::Follow
                uid = event['source']['userId']
                message = {
                    "type": "text",
                    "text": "登録完了！\r\nあなたのuserIdは[#{uid}]です。\r\nuserIdを堅志郎まで送ってね！"
                  }
                  client.reply_message(event['replyToken'], message)
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

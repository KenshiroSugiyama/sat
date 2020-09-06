class LinebotController < ApplicationController
    require 'line/bot'

    protect_from_forgery 

    def name
    end

    def create
        user = User.find_by(uid: params[:uid])

        if user.update(name: params[:name])
            redirect_to name_path
            flash[:success] = '登録完了！LINEに戻ってね！'
        end
    end

    def send_message
        @user = User.where.not(name: nil)
    end

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
                    "text": "登録完了！\r\n以下のリンクから名前を登録してね！\b\nhttps://hokudaisat.herokuapp.com/name?uid=#{uid}"
                  }
                client.reply_message(event['replyToken'], message) 
                user= User.find_by(uid: uid)

                unless user
                #user作成　uidをdbに保存　nameはラインの名前と違うからここで保存しない
                    User.create(uid: uid)
                end
            when Line::Bot::Event::Message then
                case event.type
                when Line::Bot::Event::MessageType::Text
                    e = event.message['text']
                    if e.eql?('データ確認')
                        #excel 指定
                        name = User.find_by(uid: uid).name
                        excel = Roo::Spreadsheet.open("app/assets/上智大完全版振り分け.xlsx")
                        sheet = excel.sheet("#{name}")
                        if sheet
                            message = {
                                "type": "text",
                                "text": "vs上智\b\n#{sheet.row(1)[0]}：#{sheet.row(2)[0]}\b\n#{sheet.row(1)[1]}：#{sheet.row(2)[1]}\b\n#{sheet.row(1)[2]}：#{sheet.row(2)[2]}\b\n#{sheet.row(1)[3]}：#{sheet.row(2)[3]}\b\n#{sheet.row(1)[4]}：#{sheet.row(2)[4]}\b\n#{sheet.row(1)[5]}：#{sheet.row(2)[5]}\b\n#{sheet.row(1)[6]}：#{sheet.row(2)[6]}\b\n#{sheet.row(1)[7]}：#{sheet.row(2)[7]}\b\n#{sheet.row(1)[8]}：#{sheet.row(2)[8]}\b\n#{sheet.row(1)[9]}：#{sheet.row(2)[9]}\b\n#{sheet.row(1)[10]}：#{sheet.row(2)[10]}\b\n#{sheet.row(1)[11]}：#{sheet.row(2)[11]}\b\n#{sheet.row(1)[12]}：#{sheet.row(2)[12]}\b\n#{sheet.row(1)[13]}：#{sheet.row(2)[13]}\b\n#{sheet.row(1)[14]}：#{sheet.row(2)[14]}\b\n#{sheet.row(1)[15]}：#{sheet.row(2)[15]}\b\n#{sheet.row(1)[16]}：#{sheet.row(2)[16]}\b\n#{sheet.row(1)[17]}：#{sheet.row(2)[17]}\b\n#{sheet.row(1)[18]}：#{sheet.row(2)[18]}\b\n#{sheet.row(1)[19]}：#{sheet.row(2)[19]}\b\n#{sheet.row(1)[20]}：#{sheet.row(2)[20]}\b\n#{sheet.row(1)[21]}：#{sheet.row(2)[21]}\b\n#{sheet.row(1)[22]}：#{sheet.row(2)[22]}\b\n#{sheet.row(1)[23]}：#{sheet.row(2)[23]}\b\n#{sheet.row(1)[24]}：#{sheet.row(2)[24]}\b\n#{sheet.row(1)[25]}：#{sheet.row(2)[25]}\b\n#{sheet.row(1)[26]}：#{sheet.row(2)[26]}\b\n#{sheet.row(1)[27]}：#{sheet.row(2)[27]}\b\n#{sheet.row(1)[28]}：#{sheet.row(2)[28]}\b\n#{sheet.row(1)[29]}：#{sheet.row(2)[29]}\b\n#{sheet.row(1)[30]}：#{sheet.row(2)[30]}\b\n#{sheet.row(1)[31]}：#{sheet.row(2)[31]}\b\n#{sheet.row(1)[32]}：#{sheet.row(2)[32]}\b\n#{sheet.row(1)[33]}：#{sheet.row(2)[33]}\b\n#{sheet.row(1)[34]}：#{sheet.row(2)[34]}\b\n#{sheet.row(1)[35]}：#{sheet.row(2)[35]}\b\n#{sheet.row(1)[36]}：#{sheet.row(2)[36]}\b\n#{sheet.row(1)[37]}：#{sheet.row(2)[37]}\b\n#{sheet.row(1)[38]}：#{sheet.row(2)[38]}\b\n#{sheet.row(1)[39]}：#{sheet.row(2)[39]}\b\n#{sheet.row(1)[40]}:\b\n#{sheet.row(2)[40]}\b\n#{sheet.row(1)[41]}:\b\n#{sheet.row(2)[41]}"                       
                                }
                        else
                            message = {
                                "type": "text",
                                "text": "まだデータないから表示できないや！"                       
                                }
                        end
                        client.reply_message(event['replyToken'], message)
                    elsif e.eql?('過去の試合映像')
                        client.reply_message(event['replyToken'], template) 
                    else 
                        rep = ["うるさいブス","は？","ブス","話しかけんな"]
                        message = {
                            "type": "text",
                            "text": rep.sample                   
                             }
                        client.reply_message(event['replyToken'], message)
                    end
                end
            end
            
        end
        head :ok
    end

    def push
        users = User.all
        users.each do |user|
            name = user.name
            excel = Roo::Spreadsheet.open("app/assets/岩教B転記.xlsx")
            begin
                sheet = excel.sheet("#{name}")
                message = {
                    type: 'text',
                    text: "Iリーグ\b\nvs 岩教B\b\n#{sheet.row(1)[0]}：#{sheet.row(2)[0]}\b\n#{sheet.row(1)[1]}：#{sheet.row(2)[1]}\b\n#{sheet.row(1)[2]}：#{sheet.row(2)[2]}\b\n#{sheet.row(1)[3]}：#{sheet.row(2)[3]}\b\n#{sheet.row(1)[4]}：#{sheet.row(2)[4]}\b\n#{sheet.row(1)[5]}：#{sheet.row(2)[5]}\b\n#{sheet.row(1)[6]}：#{sheet.row(2)[6]}\b\n#{sheet.row(1)[7]}：#{sheet.row(2)[7]}\b\n#{sheet.row(1)[8]}：#{sheet.row(2)[8]}\b\n#{sheet.row(1)[9]}：#{sheet.row(2)[9]}\b\n#{sheet.row(1)[10]}：#{sheet.row(2)[10]}\b\n#{sheet.row(1)[11]}：#{sheet.row(2)[11]}\b\n#{sheet.row(1)[12]}：#{sheet.row(2)[12]}\b\n#{sheet.row(1)[13]}：#{sheet.row(2)[13]}\b\n#{sheet.row(1)[14]}：#{sheet.row(2)[14]}\b\n#{sheet.row(1)[15]}：#{sheet.row(2)[15]}\b\n#{sheet.row(1)[16]}：#{sheet.row(2)[16]}\b\n#{sheet.row(1)[17]}：#{sheet.row(2)[17]}\b\n#{sheet.row(1)[18]}：#{sheet.row(2)[18]}\b\n#{sheet.row(1)[19]}：#{sheet.row(2)[19]}\b\n#{sheet.row(1)[20]}：#{sheet.row(2)[20]}\b\n#{sheet.row(1)[21]}：#{sheet.row(2)[21]}\b\n#{sheet.row(1)[22]}：#{sheet.row(2)[22]}\b\n#{sheet.row(1)[23]}：#{sheet.row(2)[23]}\b\n#{sheet.row(1)[24]}：#{sheet.row(2)[24]}\b\n#{sheet.row(1)[25]}：#{sheet.row(2)[25]}\b\n#{sheet.row(1)[26]}：#{sheet.row(2)[26]}\b\n#{sheet.row(1)[27]}：#{sheet.row(2)[27]}\b\n#{sheet.row(1)[28]}：#{sheet.row(2)[28]}\b\n#{sheet.row(1)[29]}：#{sheet.row(2)[29]}\b\n#{sheet.row(1)[30]}：#{sheet.row(2)[30]}\b\n#{sheet.row(1)[31]}：#{sheet.row(2)[31]}\b\n#{sheet.row(1)[32]}：#{sheet.row(2)[32]}\b\n#{sheet.row(1)[33]}：#{sheet.row(2)[33]}\b\n#{sheet.row(1)[34]}：#{sheet.row(2)[34]}\b\n#{sheet.row(1)[35]}：#{sheet.row(2)[35]}\b\n#{sheet.row(1)[36]}：#{sheet.row(2)[36]}\b\n#{sheet.row(1)[37]}：#{sheet.row(2)[37]}\b\n#{sheet.row(1)[38]}：#{sheet.row(2)[38]}\b\n#{sheet.row(1)[39]}：#{sheet.row(2)[39]}\b\n\b\n#{sheet.row(1)[40]}:\b\n#{sheet.row(2)[40]}\b\n#{sheet.row(1)[41]}:\b\n#{sheet.row(2)[41]}"
                } 
                client.push_message(user.uid, message)
            rescue
                p "error"
            end
        end
        redirect_to root_path
        flash[:success] = '送信完了！！'
    end


    private

    def client
        @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
    end

    def template
        {
          "type": "template",
          "altText": "？",
          "template": {
              "type": "carousel",
              "text": "何戦？",
              "columns": [
                {
                "thumbnailImageUrl": "https://www.sbbit.jp/article/image/37863/l_bit202003301501368388.jpg",
                "imageBackgroundColor": "#FFFFFF",
                "title": "東京遠征 vs東工大",
                "text": "description",
                "defaultAction": {
                    "type": "uri",
                    "label": "東京遠征 vs東工大",
                    "uri": "https://youtu.be/s2ZfufdfReU"
                },
                "actions": [
                    {
                        "type": "uri",
                        "label": "選択",
                        "uri": "https://youtu.be/s2ZfufdfReU"
                    }
                ]
                },
                {
                    "thumbnailImageUrl": "https://sports-pctr.c.yimg.jp/r/iwiz-amd/20200716-00899820-sportiva-000-1-view.jpg?cx=0&cy=0&cw=800&ch=500",
                    "imageBackgroundColor": "#FFFFFF",
                    "title": "東京遠征 vs上智大",
                    "text": "description",
                    "defaultAction": {
                        "type": "uri",
                        "label": "東京遠征 vs上智大",
                        "uri": "https://www.youtube.com/watch?v=DcIzzZMvIlE"
                    },
                    "actions": [
                        {
                            "type": "uri",
                            "label": "選択",
                            "uri": "https://www.youtube.com/watch?v=DcIzzZMvIlE"
                        }
                    ]
                },
                    {
                        "thumbnailImageUrl": "https://i.ytimg.com/vi/XDUSY7qZqus/maxresdefault.jpg",
                        "imageBackgroundColor": "#FFFFFF",
                        "title": "東京遠征 vs東農大",
                        "text": "description",
                        "defaultAction": {
                            "type": "uri",
                            "label": "東京遠征 vs東農大",
                            "uri": "https://www.youtube.com/watch?v=daCyAlujqdU"
                        },
                        "actions": [
                            {
                                "type": "uri",
                                "label": "選択",
                                "uri": "https://www.youtube.com/watch?v=daCyAlujqdU"
                            }
                        ]
                    }
          ],
          "imageAspectRatio": "rectangle",
          "imageSize": "cover"
        }
        }
    end
end

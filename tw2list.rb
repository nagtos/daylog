# -*- coding: cp932 -*-
#============================================================================#
=begin

@file   tw2blog.rb
@brief  twitterRSS変換マクロ
@date   2009.07.15
@author T.Nagata

twitterのRSSを、blogに貼りやすいように変換するスクリプトです。
日付を設定して、日付分の言葉を出力します。
日付は日本標準時になります(+9000)。
意図的に書き込み時間を出力させていません。
なお、RSSはFirefoxなどで事前に日本語(Shift-JIS & CRLF)に変換しておいて下さい。


◆twitter api から過去ログを手に入れる方法

日本語訳紹介ページ
http://watcher.moe-nifty.com/memo/2007/04/twitter_api.html

自分の発言の中で、最新200件以上のステータスを取得
http://twitter.com/statuses/user_timeline.xml?count=200



◆使い方

ruby tw2blog.rb rssfile year month day > textfile
例↓
ruby tw2blog.rb user_timeline.xml 2009 7 15 > blog.txt


◆更新履歴

1.0
    初出

=end
#============================================================================#



#============================================================================#
=begin
    xmlタグを見つけて、文字列を吐き出す
=end
#============================================================================#

def tw_output_text(file_name, log_day)
  tw_log   = Array.new                    #ログ1つ分
  tw_day   = Time.local(1, 1, 1, 1, 1, 1) #ログ1つ分の時刻
  tw_count = -1                           #出力するログ総数
  tw_flag = FALSE

  open(file_name) {|file|
    while words = file.gets

      if words =~ /<created_at>\w{3} (\w{3}) (\d+) (\d+):(\d+):(\d+) \+\d{4} (\d{4})<\/created_at>/
        tw_day = Time.local($6, $1, $2, $3, $4, $5)
        tw_day += 60 * 60 * 9 #世界標準時との時差+9000を加える
        if tw_day - log_day < 60*60*24 &&
            tw_day - log_day >= 0
          tw_flag = TRUE
        end

      elsif tw_flag && words =~ /<text>(.*?)<\/text>/
        tw_count += 1
        tw_log[tw_count] = $1

        # 他のアカウントに返信を入れたログは出力しない
        if tw_log[tw_count] =~ /@\w/
          tw_count -= 1
          next
        end

        # URLがあったらリンクに置き換える
        if tw_log[tw_count] =~ /(http.+)/
          tw_log[tw_count] =
            tw_log[tw_count].gsub($1, "<a href=\"#$1\">#$1<\/a>")
        end

        tw_flag = FALSE

      end

    end
  }

  while tw_count >= 0
    puts "  <li>"
    puts "    #{tw_log[tw_count]}"
    puts "  </li>"
    tw_count -= 1
  end

end


#============================================================================#
=begin
    メイン
=end
#============================================================================#
=begin
rssfile = ARGV[0]
day     = Time.local(ARGV[1], ARGV[2], ARGV[3], 0, 0, 0)

puts day.strftime("twitter %Y-%m-%d")
puts "<ul>"
output_text(rssfile, day)
puts "</ul>"

exit
=end

# -*- coding: cp932 -*-
#============================================================================#
=begin

@file   tb2blog.rb
@brief  tumblrAPI出力変換マクロ
@date   2009.08.12
@author T.Nagata

tublrのapi出力を、blogに貼りやすいように変換するスクリプトです。
日付を設定して、日付分の言葉を出力します。
日付は日本標準時になります(+9000)。
意図的に書き込み時間を出力させていません。
APIで出力したxmlファイルは、
Firefoxからテキストエディタにコピー&ペーストして作ったものを想定しています。


◆tumblr api から過去ログを手に入れる方法

自分の投稿の中で、最新50件の投稿を取得。
tumblrで自分の投稿を取得するは、1度に最大50件
http://(my_acount).tumblr.com/api/read?num=50

50件以上前から、50件の情報を取得する
http://(my_acount).tumblr.com/api/read?start=50?num=50
記事は0番目から数えるので、51件前から取得する場合、start=50 になる



◆使い方

ruby tb2blog.rb rssfile year month day > textfile
例↓
ruby tb2blog.rb user_timeline.xml 2009 7 15 > blog.txt


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

def tb_output_text(file_name, log_day)
  tw_log   = Array.new                    #ログ1つ分
  tw_day   = Time.local(1, 1, 1, 1, 1, 1) #ログ1つ分の時刻
  tw_count = -1                           #出力するログ総数
  tw_flag = FALSE
  body = FALSE
  link_text = FALSE
  link_url = FALSE
  link_description = FALSE
  quote_text = FALSE

  open(file_name) {|file|
    while words = file.gets

      if words =~ /<post .*? date-gmt=\"(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}) .*?>/
        tw_day = Time.local($1, $2, $3, $4, $5, $6)
        tw_day += 60 * 60 * 9 #世界標準時との時差+9000を加える
        if tw_day - log_day < 60*60*24 &&
           tw_day - log_day >= 0
          tw_count += 1
          tw_log[tw_count] =Array.new #先に配列を作っておく
          tw_flag = TRUE
        end

        # 投稿1件分が終了
      elsif words =~ /<\/post>/
        tw_flag = FALSE
        # ↓出力ミスを確認したいので、空行自動削除を一時コメントアウト
#        if tw_log[tw_count] == []
#          tw_count -= 1
#        end

        # postタグでもなく、tw_flagが立っていない場合は次の行の試行へ
      elsif !tw_flag
        next

        ### regular
        # regular-title
      elsif words =~ /<regular-title>(.*?)<\/regular-title>/
        tw_log[tw_count] = "<b><font size=\"+1\">" + $1 + "</font></b><br />"

        # regular-bodyが1行の場合
      elsif words =~ /<regular-body>(.+?)<\/regular-body>/
        tw_log[tw_count] << $1

        # regular-bodyタグ開始の場合
      elsif words =~ /<regular-body>$/
        body = TRUE

        # regular-bodyタグ終了の場合
      elsif words =~ /<\/regular-body>$/
        body = FALSE

        ### link
        # link-textが1行の場合
      elsif words =~ /<link-text>(.*?)<\/link-text>/
        tw_log[tw_count] = $1
        # link-textタグ開始
      elsif words =~ /<link-text>$/
        link_text =TRUE
        #link_textフラグが立っている場合
      elsif link_text
        tw_log[tw_count] = words.chomp
        link_text = FALSE

        # link-urlが1行の場合
      elsif words =~ /<link-url>(.+?)<\/link-url>/
        tw_log[tw_count] = "<b><font size=\"+1\"><a href=\"" + $1 + "\">" + tw_log[tw_count] + "</a></font></b><br />"
        # link-urlタグ開始
      elsif words =~ /<link-url>$/
        link_url = TRUE
        #link_urlフラグが立っている場合
      elsif link_url
        tw_log[tw_count] = "<b><font size=\"+1\"><a href=\"" + words.chomp + "\">" + tw_log[tw_count] + "</a></font></b><br />"
        link_url = FALSE

        # link本文が1行
      elsif words =~ /<link-description>(.+?)<\/link-description>/
        tw_log[tw_count] << $1

        # link本文が複数行
      elsif words =~ /<link-description>/
        body = TRUE
      elsif words =~ /<\/link-description>/
        body = FALSE

        ### quote
        # quote-textタグ開始
      elsif words =~ /<quote-text>$/
        body = TRUE
        tw_log[tw_count] << "<p>----------quote<br /><i>"
        # quote-textタグ終了
      elsif words =~ /<\/quote-text>$/
        tw_log[tw_count] << "</i><br />----------quote</p>"
        body = FALSE

        # quote-source開始
      elsif words =~ /<quote-source>$/
        body = TRUE
        # quote-source終了
      elsif words =~ /<\/quote-source>$/
        body = FALSE

        ### video
        # video-captionタグ
      elsif words =~ /<video-caption>$/
        body = TRUE
      elsif words =~ /<\/video-caption>$/
        body = FALSE
        # video-sourceタグ
      elsif words =~ /<video-source>$/
        body = TRUE
      elsif words =~ /<\/video-source>$/
        body = FALSE

        ### body_flagが立っている場合
      elsif body
        tw_log[tw_count] << words.chomp

        ### twitterがquoteのソースの場合は、出力から外す
      elsif words =~ /http:\/\/twitter/
        tw_count -= 1
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

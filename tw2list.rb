# -*- coding: cp932 -*-
#============================================================================#
=begin

@file   tw2blog.rb
@brief  twitterRSS�ϊ��}�N��
@date   2009.07.15
@author T.Nagata

twitter��RSS���Ablog�ɓ\��₷���悤�ɕϊ�����X�N���v�g�ł��B
���t��ݒ肵�āA���t���̌��t���o�͂��܂��B
���t�͓��{�W�����ɂȂ�܂�(+9000)�B
�Ӑ}�I�ɏ������ݎ��Ԃ��o�͂����Ă��܂���B
�Ȃ��ARSS��Firefox�ȂǂŎ��O�ɓ��{��(Shift-JIS & CRLF)�ɕϊ����Ă����ĉ������B


��twitter api ����ߋ����O����ɓ������@

���{���Љ�y�[�W
http://watcher.moe-nifty.com/memo/2007/04/twitter_api.html

�����̔����̒��ŁA�ŐV200���ȏ�̃X�e�[�^�X���擾
http://twitter.com/statuses/user_timeline.xml?count=200



���g����

ruby tw2blog.rb rssfile year month day > textfile
�ၫ
ruby tw2blog.rb user_timeline.xml 2009 7 15 > blog.txt


���X�V����

1.0
    ���o

=end
#============================================================================#



#============================================================================#
=begin
    xml�^�O�������āA�������f���o��
=end
#============================================================================#

def tw_output_text(file_name, log_day)
  tw_log   = Array.new                    #���O1��
  tw_day   = Time.local(1, 1, 1, 1, 1, 1) #���O1���̎���
  tw_count = -1                           #�o�͂��郍�O����
  tw_flag = FALSE

  open(file_name) {|file|
    while words = file.gets

      if words =~ /<created_at>\w{3} (\w{3}) (\d+) (\d+):(\d+):(\d+) \+\d{4} (\d{4})<\/created_at>/
        tw_day = Time.local($6, $1, $2, $3, $4, $5)
        tw_day += 60 * 60 * 9 #���E�W�����Ƃ̎���+9000��������
        if tw_day - log_day < 60*60*24 &&
            tw_day - log_day >= 0
          tw_flag = TRUE
        end

      elsif tw_flag && words =~ /<text>(.*?)<\/text>/
        tw_count += 1
        tw_log[tw_count] = $1

        # ���̃A�J�E���g�ɕԐM����ꂽ���O�͏o�͂��Ȃ�
        if tw_log[tw_count] =~ /@\w/
          tw_count -= 1
          next
        end

        # URL���������烊���N�ɒu��������
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
    ���C��
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

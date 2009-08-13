# -*- coding: cp932 -*-
#============================================================================#
=begin

@file   tb2blog.rb
@brief  tumblrAPI�o�͕ϊ��}�N��
@date   2009.08.12
@author T.Nagata

tublr��api�o�͂��Ablog�ɓ\��₷���悤�ɕϊ�����X�N���v�g�ł��B
���t��ݒ肵�āA���t���̌��t���o�͂��܂��B
���t�͓��{�W�����ɂȂ�܂�(+9000)�B
�Ӑ}�I�ɏ������ݎ��Ԃ��o�͂����Ă��܂���B
API�ŏo�͂���xml�t�@�C���́A
Firefox����e�L�X�g�G�f�B�^�ɃR�s�[&�y�[�X�g���č�������̂�z�肵�Ă��܂��B


��tumblr api ����ߋ����O����ɓ������@

�����̓��e�̒��ŁA�ŐV50���̓��e���擾�B
tumblr�Ŏ����̓��e���擾����́A1�x�ɍő�50��
http://(my_acount).tumblr.com/api/read?num=50

50���ȏ�O����A50���̏����擾����
http://(my_acount).tumblr.com/api/read?start=50?num=50
�L����0�Ԗڂ��琔����̂ŁA51���O����擾����ꍇ�Astart=50 �ɂȂ�



���g����

ruby tb2blog.rb rssfile year month day > textfile
�ၫ
ruby tb2blog.rb user_timeline.xml 2009 7 15 > blog.txt


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

def tb_output_text(file_name, log_day)
  tw_log   = Array.new                    #���O1��
  tw_day   = Time.local(1, 1, 1, 1, 1, 1) #���O1���̎���
  tw_count = -1                           #�o�͂��郍�O����
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
        tw_day += 60 * 60 * 9 #���E�W�����Ƃ̎���+9000��������
        if tw_day - log_day < 60*60*24 &&
           tw_day - log_day >= 0
          tw_count += 1
          tw_log[tw_count] =Array.new #��ɔz�������Ă���
          tw_flag = TRUE
        end

        # ���e1�������I��
      elsif words =~ /<\/post>/
        tw_flag = FALSE
        # ���o�̓~�X���m�F�������̂ŁA��s�����폜���ꎞ�R�����g�A�E�g
#        if tw_log[tw_count] == []
#          tw_count -= 1
#        end

        # post�^�O�ł��Ȃ��Atw_flag�������Ă��Ȃ��ꍇ�͎��̍s�̎��s��
      elsif !tw_flag
        next

        ### regular
        # regular-title
      elsif words =~ /<regular-title>(.*?)<\/regular-title>/
        tw_log[tw_count] = "<b><font size=\"+1\">" + $1 + "</font></b><br />"

        # regular-body��1�s�̏ꍇ
      elsif words =~ /<regular-body>(.+?)<\/regular-body>/
        tw_log[tw_count] << $1

        # regular-body�^�O�J�n�̏ꍇ
      elsif words =~ /<regular-body>$/
        body = TRUE

        # regular-body�^�O�I���̏ꍇ
      elsif words =~ /<\/regular-body>$/
        body = FALSE

        ### link
        # link-text��1�s�̏ꍇ
      elsif words =~ /<link-text>(.*?)<\/link-text>/
        tw_log[tw_count] = $1
        # link-text�^�O�J�n
      elsif words =~ /<link-text>$/
        link_text =TRUE
        #link_text�t���O�������Ă���ꍇ
      elsif link_text
        tw_log[tw_count] = words.chomp
        link_text = FALSE

        # link-url��1�s�̏ꍇ
      elsif words =~ /<link-url>(.+?)<\/link-url>/
        tw_log[tw_count] = "<b><font size=\"+1\"><a href=\"" + $1 + "\">" + tw_log[tw_count] + "</a></font></b><br />"
        # link-url�^�O�J�n
      elsif words =~ /<link-url>$/
        link_url = TRUE
        #link_url�t���O�������Ă���ꍇ
      elsif link_url
        tw_log[tw_count] = "<b><font size=\"+1\"><a href=\"" + words.chomp + "\">" + tw_log[tw_count] + "</a></font></b><br />"
        link_url = FALSE

        # link�{����1�s
      elsif words =~ /<link-description>(.+?)<\/link-description>/
        tw_log[tw_count] << $1

        # link�{���������s
      elsif words =~ /<link-description>/
        body = TRUE
      elsif words =~ /<\/link-description>/
        body = FALSE

        ### quote
        # quote-text�^�O�J�n
      elsif words =~ /<quote-text>$/
        body = TRUE
        tw_log[tw_count] << "<p>----------quote<br /><i>"
        # quote-text�^�O�I��
      elsif words =~ /<\/quote-text>$/
        tw_log[tw_count] << "</i><br />----------quote</p>"
        body = FALSE

        # quote-source�J�n
      elsif words =~ /<quote-source>$/
        body = TRUE
        # quote-source�I��
      elsif words =~ /<\/quote-source>$/
        body = FALSE

        ### video
        # video-caption�^�O
      elsif words =~ /<video-caption>$/
        body = TRUE
      elsif words =~ /<\/video-caption>$/
        body = FALSE
        # video-source�^�O
      elsif words =~ /<video-source>$/
        body = TRUE
      elsif words =~ /<\/video-source>$/
        body = FALSE

        ### body_flag�������Ă���ꍇ
      elsif body
        tw_log[tw_count] << words.chomp

        ### twitter��quote�̃\�[�X�̏ꍇ�́A�o�͂���O��
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

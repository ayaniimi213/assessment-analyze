#/usr/local/bin/bash

# ���ȤΥ���饤��ե����ɥХå���ñ��١��������ٲ���
# $Id: assessment-analyze.rb,v 1.1 2007/09/05 11:55:53 niimi Exp $

require "tempfile"
require "reform_q.rb"
$KCODE = "EUC"

class AssessmentAnalyze

  def AssessmentAnalyze.process(args, default_io)
    analyzer = AssessmentAnalyze.new()
    analyzer.get_html
    if args.empty?
      ids = analyzer.get_ids
      ids.each{|id|
        analyzer.analyze(id)
      }
    else
      args.each{|id|
        analyzer.analyze(id)
      }
    end
  analyzer.reform_index
  end

  # SETTINGS
  def initialize()
    @wget = 'wget'
    @essay_home = 'http://vishnu.fun.ac.jp/assessment/2010-2/result.php'
    @dl_dir = './vishnu.fun.ac.jp/assessment/2010-2/'
    @chasen = 'chasen'
#    @chasen_option = %q(-j -F "%H:%M\n")
    @chasen_option = %q(-j -r /usr/local/share/chasen/dic/ipadic/chasenrc -F "%H:%M\n")
    @wc = '$HOME/ruby/word_count.rb'
    @output_file = 'reform'
    @starttags = ["Q3-1","Q3-2","Q4-2"]
    @output_reform_index = "result.html"
  end
  
  # get html
  def get_html
    system("#{@wget} -r -l2 #{@essay_home}") unless File.exist?(@dl_dir)
  end

  # get_ids
  def get_ids
    ids = Dir.glob("#{@dl_dir}graph.php\?course=*").map!{|dir|
      dir.gsub!(/^.*course=/, "")
    }
    return ids
  end
  
  # analyze
  def analyze(id)
    puts id
    open("#{@output_file}#{id}.html", "w"){|file|
      file.puts output_header
      @starttags.each{|starttag|
        file.puts analyze_wc(id, starttag)
      }
    }
  end
  
  def output_header
    sprintf "<i><font size=+2 color=blue><b>����ɾ�������� ��Ω�Ϥ�����̤�����</b></font></i><br>"
  end
  
  def analyze_wc(id, starttag)
    buf = ""
    if starttag == "Q3-1"
      buf = "<H1>Q3-1	���ιֵ�����ǹԤ��뤳�Ȥǡ���ǯ�ʹߤ�����³������ɤ��ȹͤ����뤳�Ȥ�����������Ƥ���������:</H1>"
    elsif starttag == "Q3-2"
      buf = "<H1>Q3-2	���ιֵ��ǲ������٤���������Ȥ���С��ɤ�����Ǥ����������Ƥ���Ƥ��Ƥ���������:</H1>"
    elsif starttag == "Q4-2"
      buf = "<H1>Q4-2	����ǯ�٤γ�ǯ�ˡ����ιֵ����Ф��봶�ۤ�ޤȤ�������Ʋ�������������֤���������Ф�����Ū�ʻ����������뵡����󶡤������ȹͤ��ޤ���(�ͥ��ƥ��֤�����������뤿��ΰո��ˤĤ��Ƥϡ�Q3-2�˵��Ҥ��Ƥ���������):</H1>"
    end
    buf.concat(analyze_wc_core(id, starttag))
  end
  
  def analyze_wc_core(id, starttag)
    temp = Tempfile.new("temp")

#    system("ruby ./extract_q.rb #{@dl_dir} #{id} #{starttag} | \
#    #{@chasen} #{@chasen_option} | \
#    ruby -r 'jcode' -nle 'scan(/^.*:(.*)/){print $1 if ($1.length > 2)} ' | \
#    #{@wc} | sort -nr -k 2 > #{@output_file}#{id}.#{starttag}")

    open("| ruby ./extract_q.rb #{@dl_dir} #{id} #{starttag} | \
    #{@chasen} #{@chasen_option} | \
    ruby -r 'jcode' -nle 'scan(/^.*:(.*)/){print $1 if ($1.length > 2)} ' | \
    #{@wc} | sort -nr -k 2", "r"){|file|
      while line = file.gets
        temp.puts line
      end
    }
    temp.close

    temp.open
#    `ruby ./reform_q.rb #{@dl_dir} #{id} #{starttag}`
    reformer = Reform_Q.new(@dl_dir, id, starttag)
    reformer.road_wc(temp.read)
    reformer.output_wc

  end

  def reform_index
    open(@output_reform_index, "w"){|out|
      open(@dl_dir + "result.php"){|file|
        while line = file.gets
          line.gsub!(/(\/assessment\/2010-2\/graph\.php\?course=)(\d+)/){@output_file + $2 + ".html"}
          out.puts line
        end
      }
    }
  end
end

if $0 == __FILE__
  AssessmentAnalyze.process(ARGV, STDIN)
end

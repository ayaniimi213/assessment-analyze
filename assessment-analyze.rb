# -*- coding: utf-8 -*-
#/usr/bin/env ruby

# 授業のオンラインフィードバックの単語ベースの頻度解析
# $Id:$

require 'tempfile'
require './reform_q.rb'
require "nkf"
require 'pp'

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
    @essay_home = 'http://vishnu.fun.ac.jp/assessment/2014-1/result.php'
    @dl_dir = './vishnu.fun.ac.jp/assessment/2014-1/'
    @mecab = 'mecab'
    @mecab_option = '--node-format="%H:%m\n" --bos-format="" --eos-format="" --unk-format="" --eon-format=""'
    @wc = './word_count.rb'
    @output_file = 'reform'
    @starttags = ["Q3-1","Q3-2","Q4-2"]
    @output_reform_index = "result.html"
    @replace_pattern = '(\/assessment\/2014-1\/graph\.php\?course=)(\d+)'
    @nkf_opt = "-w"
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
    sprintf '<META http-equiv=Content-Type content="text/html; charset=UTF-8"><i><font size=+2 color=blue><b>授業評価シート 公立はこだて未来大学</b></font></i><br>'
  end
  
  def analyze_wc(id, starttag)
    buf = ""
    if starttag == "Q3-1"
      buf = "<H1>Q3-1	この講義の中で行われることで、来年以降も是非続けると良いと考えられることがあれば答えてください。:</H1>"
    elsif starttag == "Q3-2"
      buf = "<H1>Q3-2	この講義で改善すべき点があるとすれば、どんな点ですか。改善案を提案してください。:</H1>"
    elsif starttag == "Q4-2"
      buf = "<H1>Q4-2	次の年度の学年に、この講義に対する感想をまとめて伝えて下さい。将来受講する学生に対し建設的な事柄を伝える機会を提供したいと考えます。(ネガティブな点を改善するための意見については、Q3-2に記述してください。):</H1>"
    end
    buf.concat(analyze_wc_core(id, starttag))
  end
  
  def analyze_wc_core(id, starttag)
    temp = Tempfile.new("temp")

    open("| ruby ./extract_q.rb #{@dl_dir} #{id} #{starttag} | \
    #{@mecab} #{@mecab_option} | \
    ruby -nle 'print $_.split(/:/)[-1] if $_.split(/:/)[-1].length > 2' | \
    #{@wc} | sort -nr -k 2", "r"){|file|
      while line = file.gets
        temp.puts line
      end
    }
    temp.close

    temp.open
    reformer = Reform_Q.new(@dl_dir, id, starttag)
    reformer.road_wc(temp.readlines)
    reformer.output_wc

  end

  def reform_index
    open(@output_reform_index, "w"){|out|
      out.puts '<META http-equiv=Content-Type content="text/html; charset=UTF-8">'
      open(@dl_dir + "result.php"){|file|
        while line = file.gets
          line = NKF.nkf(@nkf_opt, line)
          line.gsub!(/#{@replace_pattern}/){@output_file + $2 + ".html"}
          out.puts line
        end
      }
    }
  end
end

if $0 == __FILE__
  AssessmentAnalyze.process(ARGV, STDIN)
end

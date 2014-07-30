#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require './pn.rb'
require "nkf"

class Reform_Q

  def Reform_Q.process(args, default_io)
    fdir = args.shift
    id = args.shift
    starttag = args.shift
    # basename='assessment2007-words.txt'
    basename = 'reform' + id
    
    reformer = Reform_Q.new(fdir, id, starttag)
    reformer.road_wc(File.read(basename + "." + starttag))
    puts reformer.output_wc
  end

  def initialize(fdir, id, starttag)
    @fdir = fdir
    @id = id
    @fname = @fdir + 'graph.php?course=' + @id
    
    @starttag = starttag
    @endtag = "Q3-2" if Regexp.compile(@starttag) =~ "Q3-1"
    @endtag = "Q3-3" if Regexp.compile(@starttag) =~ "Q3-2"
    @endtag = "Q4-3" if Regexp.compile(@starttag) =~ "Q4-2"
    
    @keywords = Hash.new
    @nkf_opt = "-w"
  end

  def road_wc(lines)
    lines.each{|line|
      line.chomp!
      items = line.split(/:/)
      @keywords[items[0].strip] = items[1].strip
#      p items
    }
  end

  def output_wc
    pn = PN.new()

    buf = ""
    is_extract = false
    open(@fname){|file|
      while line = file.gets
        line.chomp!
        line = NKF.nkf(@nkf_opt, line)
        line.gsub!(/\<[^\>]*\>/, "")
        line.gsub!(/\[現在の授業のよい点\]/, "")
        line.gsub!(/\[改善へのアイデア\]/, "")
        line.gsub!(/\[次年度の受講生へ\]/, "")
        line.gsub!(/^\d+/, "")
    
        is_extract = false if Regexp.compile("^" + @endtag) =~ line

        score = pn.analyze(line)
        if score < -0.5 then
          face = "<font color =\"blue\">(>_<)</font>"
        elsif score < 0.5 then
          face = "<font color =\"black\">(-_-)</font>"
        else
          face = "<font color =\"red\">(^-^)</font>"
        end
        buf.concat "#{face} " if is_extract and line != ""
        @keywords.each{|key, value|
#          p "#{key}:#{value}" if value.to_i >= 10
          line.gsub!(Regexp.compile(key), "<FONT size=\"+4\">#{key}</FONT>") if value.to_i >= 40
          line.gsub!(Regexp.compile(key), "<FONT size=\"+4\">#{key}</FONT>") if (value.to_i < 40 && value.to_i >= 30)
          line.gsub!(Regexp.compile(key), "<FONT size=\"+3\">#{key}</FONT>") if (value.to_i < 30 && value.to_i >= 20)
          line.gsub!(Regexp.compile(key), "<FONT size=\"+2\">#{key}</FONT>") if (value.to_i < 20 && value.to_i >= 10)
        }
        buf.concat "#{line}<br/>\n" if is_extract
    
        is_extract = true if Regexp.compile("^" + @starttag) =~ line
      end
    }
    return buf
  end
end

if $0 == __FILE__
  Reform_Q.process(ARGV, STDIN)
end

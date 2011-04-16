#!/usr/bin/ruby
$KCODE = "EUC"
fdir = ARGV.shift
fname='graph.php?course=13106'
id = ARGV.shift
fname = fdir + 'graph.php?course=' + id
# fname=ARGV.shift

starttag=ARGV.shift
endtag="Q3-2" if Regexp.compile(starttag) =~ "Q3-1"
endtag="Q3-3" if Regexp.compile(starttag) =~ "Q3-2"
endtag="Q4-3" if Regexp.compile(starttag) =~ "Q4-2"

is_extract = false

open(fname){|file|
  while line = file.gets
#    line.chomp!
    line.gsub!(/\<[^\>]*\>/, "");
    line.gsub!(/\[���ߤμ��ȤΤ褤��\]/, "");
    line.gsub!(/\[�����ؤΥ����ǥ�\]/, "");
    line.gsub!(/\[��ǯ�٤μ�������\]/, "");
    line.gsub!(/^\d+/, "");

    is_extract = false if Regexp.compile("^" +endtag) =~ line;

    print line if is_extract;

    is_extract = true if Regexp.compile("^" +starttag) =~ line;
  end
}


#/usr/local/bin/bash

# 授業のオンラインフィードバックの単語ベースの頻度解析
# $Id: assessment-analyze2007.sh,v 1.1 2007/09/05 11:56:43 niimi Exp $

# SETTINGS
OUTPUT_FILE='reform'
ID="13106"

# analyze
ruby assessment-analyze.rb $ID > "$OUTPUT_FILE$ID.html"

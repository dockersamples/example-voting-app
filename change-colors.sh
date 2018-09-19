#!/bin/bash

if [ "$1" == "devops-world" ]; then
    # main cat color
    sed -i '' 's/2196f3/bb1259/g' result/views/stylesheets/style.css 
    sed -i '' 's/1aaaf8/bb1259/g' vote/static/stylesheets/style.css

    # main dog color
    sed -i '' 's/00cbca/511252/g' result/views/stylesheets/style.css 
    sed -i '' 's/00cbca/511252/g' vote/static/stylesheets/style.css

    # cat button hover color
    sed -i '' 's/1488c6/df3d4a/g' vote/static/stylesheets/style.css

    # dog button hover color
    sed -i '' 's/00a2a1/8f1259/g' vote/static/stylesheets/style.css

elif [ "$1" == "normal" ]; then
    # main cat color
    sed -i '' 's/bb1259/2196f3/g' result/views/stylesheets/style.css 
    sed -i '' 's/bb1259/1aaaf8/g' vote/static/stylesheets/style.css

    # main dog color
    sed -i '' 's/511252/00cbca/g' result/views/stylesheets/style.css
    sed -i '' 's/511252/00cbca/g' vote/static/stylesheets/style.css

    # cat button hover color
    sed -i '' 's/df3d4a/1488c6/g' vote/static/stylesheets/style.css

    # dog button hover color
    sed -i '' 's/8f1259/00a2a1/g' vote/static/stylesheets/style.css
else
    echo "Specify either normal or devops-world"
fi
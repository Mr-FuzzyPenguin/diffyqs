#!/bin/zsh
echo Conversion to HTML through PreTeXt.  It is still beta quality and work in
echo progress.  The diffyqs-html.xsl assumes a fixed location for the PreTeXt
echo xsl file.  You need to edit this first.
echo Do ^C to get out.
echo 
echo You should first run with --runpdft --optimize-svg which
echo runs the pdft figures and then also optimizes svgs.  Without
echo --runpdft some figures will be missing.  You can also use --full
echo which does all three arguments.
echo Optimizations are in optimize-svgs.sh in figures/
echo
echo The option --add-track will add my google tracking, this is probably
echo only for me.
echo
echo To rerun all figures first do \"rm "*-mbx.*" "*-tex4ht.*"\", or run
echo this script with --kill-generated.
echo

PDFT=no
#OPTPNG=no
OPTSVG=no
ADDTRACK=no

# parse parameters
while [ "$1" != "" ]; do
    case $1 in
        -h | --help)
            exit
            ;;
        --runpdft)
	    echo "OPTION (runpdft) Will run pdf_t figures"
	    PDFT=yes
            ;;
#        --optimize-png)
#	    echo "OPTION (optimize-png) Will run optimize-pngs.sh"
#	    OPTPNG=yes
#            ;;
        --optimize-svg)
	    echo "OPTION (optimize-svg) Will run optimize-svgs.sh"
	    OPTSVG=yes
	    ;;
        --add-track)
	    echo "OPTION add tracking"
	    ADDTRACK=yes
	    ;;
        --full)
	    echo "OPTION (full) Will run pdf_t optimize svgs"
	    PDFT=yes
	    #OPTPNG=yes
	    OPTSVG=yes
            ;;
        --kill-generated)
	    echo "OPTION (kill-generated) Killing generated figures and exiting."
	    cd figures
	    rm *-mbx.svg
		 rm *-mbx.png
	    rm *-tex4ht.svg
		 rm *-tex4ht.pngcd
		 
	    cd ..
	    exit
	    ;;
        *)
            echo "ERROR: unknown parameter \"$1\""
            exit 1
            ;;
    esac
    shift
done


# wait for enter or ^C
read

if [ "$PDFT" = "yes" ] ; then
	echo
	echo RUNNING FIGURES...
	echo

	cd figures
	./figurerun.sh 192
	cd ..
fi

echo
echo RUNNING convert-to-mbx.pl ...
echo


perl convert-to-mbx.pl

#xmllint --format -o diffyqs-out2.xml diffyqs-out.xml

#if [ "$OPTPNG" = "yes" ] ; then
#	echo
#	echo OPTIMIZING PNG...
#	echo
#
#	cd figures
#	./optimize-pngs.sh
#	cd ..
#fi

if [ "$OPTSVG" = "yes" ] ; then
	echo
	echo OPTIMIZING SVG...
	echo

	cd figures
	./optimize-svgs.sh
	cd ..
fi

echo
echo MOVING OLD html, CREATING NEW html, COPYING figures/ in there
echo

if [ -e html ] ; then
	mv html html.$RANDOM$RANDOM$RANDOM
fi
mkdir html
cd html
cp -a ../figures .
cp ../extra.css .
cp ../logo.png .

echo
echo RUNNING xsltproc
echo

xsltproc -stringparam publisher diffyqs-publisher.xml ../diffyqs-html.xsl ../diffyqs-out.xml

echo
echo FIXING UP HTML ...
echo

for n in *.html; do
	../fixup-html-file.pl --track=$ADDTRACK < $n > tmpout
	mv tmpout $n
done

echo
echo DONE ...
echo
echo 'Perhaps now do (if you are me): rsync -av -e ssh html zinc.5z.com:/var/www/jirka/diffyqs/'
echo 'Make sure you have run the script with --full before ...'
echo

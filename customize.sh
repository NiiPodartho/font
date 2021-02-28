# Custom Font Installer 
# by nongthaihoang @ xda

[ ! $MAGISKTMP ] && MAGISKTMP=$(magisk --path)/.magisk
[ -d $MAGISKTMP ] && ORIGDIR=$MAGISKTMP/mirror
FONTDIR=$MODPATH/fonts
SYSFONT=$MODPATH/system/fonts
PRDFONT=$MODPATH/system/product/fonts
SYSETC=$MODPATH/system/etc
SYSXML=$SYSETC/fonts.xml
MODPROP=$MODPATH/module.prop
mkdir -p $SYSFONT $SYSETC $PRDFONT

patch() {
	if [ -f $ORIGDIR/system/etc/fonts.xml ]; then
		if ! grep -q 'family >' /system/etc/fonts.xml; then
			find /data/adb/modules/ -type f -name fonts*xml -exec rm {} \;
			false | cp -i /system/etc/fonts.xml $SYSXML && ver !
		else
			false | cp -i $ORIGDIR/system/etc/fonts.xml $SYSXML 
		fi
	else
		abort "! $ORIGDIR/system/etc/fonts.xml: file not found"
	fi
	DEFFONT=$(sed -n '/"sans-serif">/,/family>/p' $SYSXML | grep '\-Regular.' | sed 's/.*">//;s/-.*//' | tail -1)
	[ $DEFFONT ] || abort "! Unknown default font"
	if ! grep -q 'family >' $SYSXML; then
		sed -i '/"sans-serif">/,/family>/H;1,/family>/{/family>/G}' $SYSXML
		sed -i ':a;N;$!ba;s/name="sans-serif"//2' $SYSXML
	fi
}

headline() {
	cp $FONTDIR/hf/*ttf $SYSFONT
	sed -i "/\"sans-serif\">/,/family>/{s/$DEFFONT-M/M/;s/$DEFFONT-B/B/}" $SYSXML
}

body() {
	cp $FONTDIR/bf/*ttf $SYSFONT 
	sed -i "/\"sans-serif\">/,/family>/{s/$DEFFONT-T/T/;s/$DEFFONT-L/L/;s/$DEFFONT-R/R/;s/$DEFFONT-I/I/}" $SYSXML
}

condensed() {
	cp $FONTDIR/cf/*ttf $SYSFONT
	sed -i 's/RobotoC/C/' $SYSXML
}

mono() {
	cp $FONTDIR/mo/*ttf $SYSFONT
	sed -i 's/DroidSans//' $SYSXML
}

emoji() {
	cp $FONTDIR/e/*ttf $SYSFONT
	sed -i 's/NotoColor//' $SYSXML
}

full() { headline; body; condensed; mono; emoji; }

### Finding ROM
pixel() {
	if [ -f $ORIGDIR/product/fonts/GoogleSans-Regular.ttf ] || [ -f $ORIGDIR/system/product/fonts/GoogleSans-Regular.ttf ]; then
		local dest=$PRDFONT
	elif [ -f $ORIGDIR/system/fonts/GoogleSans-Regular.ttf ]; then
		local dest=$SYSFONT
	fi
	if [ $dest ]; then
		if [ $PART -eq 1 ]; then
			set BoldItalic Bold MediumItalic Medium
			for i do cp $SYSFONT/$i.ttf $dest/GoogleSans-$i.ttf; done
		fi
		ver pxl
	else
		false
	fi
}

oxygen() {
	if grep -q OnePlus $SYSXML; then
		if [ -f $ORIGDIR/system/etc/fonts_base.xml ]; then
			local oosxml=$SYSETC/fonts_base.xml
			cp $SYSXML $oosxml
			sed -i "/\"sans-serif\">/,/family>/s/$DEFFONT/Roboto/" $oosxml
		fi
	elif [ -f $ORIGDIR/system/fonts/SlateForOnePlus-Regular.ttf ]; then
		set Black Bold Medium Regular Light Thin
		for i do cp $SYSFONT/$i.ttf $SYSFONT/SlateForOnePlus-$i.ttf; done
		cp $SYSFONT/Regular.ttf $SYSFONT/SlateForOnePlus-Book.ttf
		ver oos
	else
		false
	fi
}

miui() {
	if grep -q miui $SYSXML; then
		if [ $PART -eq 1 ]; then
			sed -i '/"mipro"/,/family>/{/700/s/MiLanProVF/Bold/;/stylevalue="400"/d}' $SYSXML
			sed -i '/"mipro-regular"/,/family>/{/700/s/MiLanProVF/Medium/;/stylevalue="400"/d}' $SYSXML
			sed -i '/"mipro-medium"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-demibold"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-semibold"/,/family>/{/400/s/MiLanProVF/Medium/;/700/s/MiLanProVF/Bold/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-bold"/,/family>/{/400/s/MiLanProVF/Bold/;/700/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
			sed -i '/"mipro-heavy"/,/family>/{/400/s/MiLanProVF/Black/;/stylevalue/d}' $SYSXML
		fi	
		sed -i '/"mipro"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
		sed -i '/"mipro-thin"/,/family>/{/400/s/MiLanProVF/Thin/;/700/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-extralight"/,/family>/{/400/s/MiLanProVF/Thin/;/700/s/MiLanProVF/Light/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-light"/,/family>/{/400/s/MiLanProVF/Light/;/700/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-normal"/,/family>/{/400/s/MiLanProVF/Light/;/700/s/MiLanProVF/Regular/;/stylevalue/d}' $SYSXML
		sed -i '/"mipro-regular"/,/family>/{/400/s/MiLanProVF/Regular/;/stylevalue="340"/d}' $SYSXML
		ver miui
	else
		false
	fi
}

lg() {
	local lg=false
	if grep -q lg-sans-serif $SYSXML; then
		sed -i '/"lg-sans-serif">/,/family>/{/"lg-sans-serif">/!d};/"sans-serif">/,/family>/{/"sans-serif">/!H};/"lg-sans-serif">/G' $SYSXML
		lg=true
	fi
	if [ -f $ORIGDIR/system/etc/fonts_lge.xml ]; then
		false | cp -i $ORIGDIR/system/etc/fonts_lge.xml $SYSETC
		local lgxml=$SYSETC/fonts_lge.xml
		sed -i '/"default_roboto">/,/family>/{s/Roboto-T/T/;s/Roboto-L/L/;s/Roboto-R/R/;s/Roboto-I/I/}' $lgxml
		if [ $PART -eq 1 ]; then
			sed -i '/"default_roboto">/,/family>/{s/Roboto-M/M/;s/Roboto-B/B/}' $lgxml
		fi
		lg=true
	fi
	$lg && ver lg || false
}

samsung() {
	if grep -q Samsung $SYSXML; then
		sed -i 's/SECRobotoLight-//;s/SECCondensed-/Condensed-/' $SYSXML
		[ $PART -eq 1 ] && sed -i 's/SECRobotoLight-Bold/Medium/' $SYSXML
		ver sam
	else
		false
	fi
}

realme() {
	if grep -q COLOROS $SYSXML; then
		if [ -f $ORIGDIR/system/etc/fonts_base.xml ]; then
			local ruixml=$SYSETC/fonts_base.xml
			cp $SYSXML $ruixml
			sed -i "/\"sans-serif\">/,/family>/s/$DEFFONT/Roboto/" $ruixml
		fi
		ver rui
	else
		false
	fi
}

### Module Functions
rom() { pixel || oxygen || miui || samsung || lg || realme; }

ver() { sed -i 3"s/$/-$1&/" $MODPROP; }

gsp() {
	local gsp=/data/adb/modules_update/googlesansplus
	[ -d $gsp ] || gsp=/sdcard
	if grep -q -e 'hf-' -e 'hf$' $gsp/module.prop; then
		mv $gsp/system/etc $MODPATH/system
		ver gsp
	else
		false
	fi
}

extra() {
	set Black ExtraBold Medium SemiBold Thin ExtraLight Bold Bold Medium Medium Regular Regular Light Light
	for i do
		ln -s /system/fonts/$1.ttf $PRDFONT/Manrope-$2.ttf
		ln -s /system/fonts/$1.ttf $PRDFONT/Inter-$2.otf
	shift 2; [ $2 ] || break
	done
}

clean_up() {
	rm -rf $FONTDIR $MODPATH/LICENSE $MODPATH/tools
	rmdir -p $PRDFONT $SYSETC
}

OPTION=false
PART=1
HF=1
BF=1

. $MODPATH/tools/selector.sh

### Installation
ui_print "  "
ui_print "- Installing"
patch
[ $PART -eq 1 ] && full || ( body; condensed; mono; emoji; ver bf )
rom
extra
ui_print "- Cleaning up"
clean_up

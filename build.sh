function xecho(){
	echo -e "\033[32m$1 \033[0m"
}

# Clear hosts file
xecho "[*] Clear hosts file."
cat /dev/null > ~/.ssh/known_hosts

# remove 0ld deb package file
xecho "[*] Remove 0ld package."
ROOT=$(cd `dirname $0`; pwd)
rm -fr $ROOT/packages

# make and install
xecho "[*] Compile and install..."
make -s clean package #> /dev/null 2>&1
make install

# dump deb file. 
# xecho "[*] Dump dylib from deb to FAKEROOT"
# dpkg -X $ROOT/packages/*.deb $FAKEROOT > /dev/null 2>&1

xecho "[*] Done."
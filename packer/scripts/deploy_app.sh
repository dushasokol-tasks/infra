#!/bin/bash
git clone https://github.com/Artemmkin/reddit.git
cd reddit && bundle install
echo '#!/bin/bash' >> puma.sh
echo 'puma -d --dir /home/appuser/reddit' >> puma.sh
chmod +x puma.sh
cp puma.sh /etc/init.d/puma.sh


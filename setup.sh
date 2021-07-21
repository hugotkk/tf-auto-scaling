sudo su -
export DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
apt-get update
apt-get install -y --no-install-recommends tzdata
dpkg-reconfigure --frontend noninteractive tzdata
apt install -y apache2
systemctl enable apache2
systemctl status apache2
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
mkdir /mnt
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport mount-target-DNS:/   /mnt
chmod go+rw .

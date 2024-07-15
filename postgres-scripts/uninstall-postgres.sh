sudo apt-get --purge remove postgresql\*
sudo apt-get autoremove -y
sudo apt-get autoclean -y


sudo rm -rf /etc/postgresql/
sudo rm -rf /etc/postgresql-common/



psql --version

# sudo apt-get update

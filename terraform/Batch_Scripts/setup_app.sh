
#sudo su
#sudo apt update -y
# sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
# sudo apt install awscli -y
# sudo aws s3 cp  s3://yours3bucket/hello.sh /home/ubuntu
# sudo chmod +x hello.sh
# ./hello.sh

sudo apt update -y
sudo mkdir /home/ubuntu/pythonwebapp
sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
sudo apt install awscli -y
sudo chmod -R 777 /home
sudo chmod -R 777 /etc/systemd/system/
sudo aws s3 cp s3://yours3bucket/pythonwebapp /home/ubuntu/pythonwebapp --recursive  ## your s3 bucket
#sudo cd /home/ubuntu/pythonwebapp
sudo apt-get install python3-venv -y
sudo python3 -m venv /home/ubuntu/pythonwebapp/venv
sudo chmod -R 777 /home/ubuntu/pythonwebapp/venv
source /home/ubuntu/pythonwebapp/venv/bin/activate
pip install -r /home/ubuntu/pythonwebapp/requirements.txt

sudo echo "[Unit]
Description=Gunicorn instance for a simple hello world app
After=network.target
[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/pythonwebapp
ExecStart=/home/ubuntu/pythonwebapp/venv/bin/gunicorn -b localhost:8000 app:app
Restart=always
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/pythonwebapp.service

sudo systemctl daemon-reload
sudo systemctl start pythonwebapp
sudo systemctl enable pythonwebapp

sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo aws s3 cp  s3://yours3bucket/default /etc/nginx/sites-available/
sudo systemctl restart nginx
$SHELL
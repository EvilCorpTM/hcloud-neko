# hcloud-neko
This script deploys https://github.com/nurdism/neko to an hetzner cloud vm, deletes it after a specific time(configured in deploy.sh)


install following crontab
`* * * * * bash /home/user/hcloud-neko/cron.sh >/dev/null 2>&1`

and run deploy.sh

make sure to have hcloud installed and configured

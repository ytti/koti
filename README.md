# Koti #
Koti is simple hack to fetch my dotfiles from github and create symlinks for them.

# Typical directory stucture #
```
[ytti@lintukoto ~/.koti]% find .|grep -v .git
.
./composite
./composite/mutt
./composite/mutt/main
./composite/zsh
./composite/zsh/main
./composite/zsh/poop
./repository
./repository/main
./repository/main/app
./repository/main/app/zsh
./repository/main/app/zsh/config.yaml
./repository/main/app/zsh/host
./repository/main/app/zsh/host/lintukoto
./repository/main/app/zsh/host/lintukoto/lintukoto
./repository/main/app/zsh/host/lintukoto/lintukoto2
./repository/main/app/zsh/host/muu
./repository/main/app/zsh/host/muu/ei
./repository/main/app/zsh/main
./repository/main/app/zsh/main/main1
./repository/main/app/zsh/main/main2
./repository/main/app/zsh/os
./repository/main/app/zsh/os/linux
./repository/main/app/zsh/os/linux/ei_tätä
./repository/main/app/zsh/os/osx
./repository/main/app/zsh/os/osx/jee
./repository/main/app/zsh/os/osx/moi
./repository/main/koti.yaml
./repository/main/LICENSE
./repository/muttpaske
./repository/muttpaske/app
./repository/muttpaske/app/mutt
./repository/muttpaske/app/mutt/config.yaml
./repository/muttpaske/app/mutt/main
./repository/muttpaske/app/mutt/main/moi.rc
[ytti@lintukoto ~/.koti]%
```

repository 'main' is something you must have, other repositories are optional. 'main' repo should contain 'koti.yaml' file and 'app' directory with subdirectory per managed application.

* Application's main config is under app/name/main/ files, as many files as you wish.
* ```app/name/os/OSNAME/files``` are included only if operating system (uname) is osname
* ```app/nae/host/OSNAME/files``` are included only if hostname (uname) is hostname
* same structure can be inside ```app/name/something```, this is used if app needs >1 configuration file

# koti.yaml #
```
[ytti@lintukoto ~/.koti/repository/main]% cat koti.yaml
---
repository:
  "main": "git@github.com:ytti/dot.git"
  "muttpaske": "/Users/ytti/tmp/repo2"
[ytti@lintukoto ~/.koti/repository/main]%
```

So far it only iterates all repos you have

# app config #
```
[ytti@lintukoto ~/.koti/repository/main/app/zsh]% cat config.yaml
---
files:
  main: ~/.zshrc_main
  poop: ~/.zshrc_poop
[ytti@lintukoto ~/.koti/repository/main/app/zsh]%
```

* ```main``` is compiled from the app root, i.e. ```app/zsh```
* ```poop``` is compiled from the app root+poop, i.e. ```app/zsh/poop```


# example #
```
[ytti@lintukoto ~]% ./koti
koti not installed, try 'koti --install git@github.com:user/repo'
[ytti@lintukoto ~]% ls -lad .koti
ls: .koti: No such file or directory
[1 ytti@lintukoto ~]% ./koti --install git@github.com:ytti/dot
Updating repo main... ok
Updating repo muttpaske... ok
Building zsh config main from main... done
Building zsh config poop from main... done
Building mutt config main from muttpaske... done
Linking /Users/ytti/.koti/composite/zsh/main to /Users/ytti/.zshrc_main
Linking /Users/ytti/.koti/composite/zsh/poop to /Users/ytti/.zshrc_poop
Linking /Users/ytti/.koti/composite/mutt/main to /Users/ytti/.muttrc
[ytti@lintukoto ~]% ./koti
Updating repo main... ok
Updating repo muttpaske... ok
Building zsh config main from main... done
Building zsh config poop from main... done
Building mutt config main from muttpaske... done
Linking /Users/ytti/.koti/composite/zsh/main to /Users/ytti/.zshrc_main
Linking /Users/ytti/.koti/composite/zsh/poop to /Users/ytti/.zshrc_poop
Linking /Users/ytti/.koti/composite/mutt/main to /Users/ytti/.muttrc
[ytti@lintukoto ~]%
```

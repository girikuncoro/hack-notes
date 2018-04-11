## Configuring system for sudo

Navigate to `sudoers` subdirectory and create file
```
# ls /etc/sudoers.d
```

Need to set proper permission on file
```
# chmod 440 /etc/sudoers.d/student
```

Export `sbin` to PATH to include search tool in root user as well
```
$ PATH=$PATH:/usr/sbin:/sbin >> ~/.bashrc 
```


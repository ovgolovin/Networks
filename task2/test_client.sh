#!/usr/bin/env bash



echo 'GET / HTTP/1.1
Host: www.dobrokot.ru
User-Agent: Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727)
From: tool@httpquery.com
Connection: close 
' | netcat localhost 6000
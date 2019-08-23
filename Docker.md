
#### Docker版SS客户端

Dockerfile在[Dockerfile](Dockerfile)。

运行指令
```
docker build -t youneed-ss .
docker run -it --rm -p 1080:1080 -p 8118:8118 youneed-ss
```
1080是socks5代理，8118是http代理。

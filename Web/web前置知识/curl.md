# curl 指令

curl 是一个用于在命令行终端下进行网络请求的工具，支持多种协议，如 HTTP、HTTPS、FTP 等。它可以发送和接收数据，常用于测试 API、下载文件、发送请求等场景。

---

## 基本语法结构

curl 命令的基本语法格式如下：

```bash
curl [options] [URL...]
```

参数说明

- options：各种可选参数，用于控制 curl 的行为
- URL：要访问的一个或多个网址

---

## 常用选项参数详解

1. 基本请求控制

| 选项 | 说明 | 示例 |
|------|------|------|
| -X | 指定 HTTP 方法 | curl -X POST https://example.com |
| -d | 发送 POST 数据 | curl -d "name=John" https://example.com |
| -G | 将 -d 数据作为 GET 参数发送 | curl -G -d "q=keyword" https://search.com |
| -H | 添加请求头 | curl -H "Content-Type: application/json" https://api.com |

2. 控制输出

| 选项 | 说明 | 示例 |
|------|------|------|
| -o | 将输出保存到文件 | curl -o output.html https://example.com |
| -O | 使用远程文件名保存 | curl -O https://example.com/file.zip |
| -s | 静默模式（不显示进度） | curl -s https://api.com/data.json |
| -v | 显示详细通信过程 | curl -v https://example.com |

3. 认证与安全

| 选项 | 说明 | 示例 |
|------|------|------|
| -u | 用户名密码认证 | curl -u user:pass https://secure.com |
| -k | 忽略 SSL 证书验证 | curl -k https://self-signed.com |
| --cacert | 指定 CA 证书 | curl --cacert cert.pem https://secure.com |

4. 其他实用选项

| 选项 | 说明 | 示例 |
|------|------|------|
| -L | 跟随重定向 | curl -L https://short.url |
| -I | 只获取头部信息 | curl -I https://example.com |
| --limit-rate | 限制传输速度 | curl --limit-rate 100K https://largefile.com |

# http协议

## 请求方式

HTTP 请求方法, HTTP/1.1协议中共定义了八种方法（也叫动作）来以不同方式操作指定的资源。

HTTP/1.1 协议确实定义了八种核心方法（RFC 2616）：

| 方法    | 描述         | 安全性 | 幂等性 |
| ------- | ------------ | ------ | ------ |
| GET     | 获取资源     | 安全   | 幂等   |
| POST    | 提交数据     | 不安全 | 不幂等 |
| PUT     | 更新资源     | 不安全 | 幂等   |
| DELETE  | 删除资源     | 不安全 | 幂等   |
| HEAD    | 获取响应头   | 安全   | 幂等   |
| OPTIONS | 查询支持方法 | 安全   | 幂等   |
| TRACE   | 回显请求     | 安全   | 幂等   |
| CONNECT | 建立隧道     | 不安全 | 不幂等 |

### 试探http方法

curl
wget：Linux/Windows/Mac都可用，适合下载文件
telnet：手动构造原始HTTP请求
nc (netcat)：发送原始TCP数据包
图形化工具：Burp Suite、Postman、浏览器开发者工具
编程语言：Python的requests库、JavaScript的fetch等

### curl 试探

### wget

在 HTTP 测试方面，wget 确实不如 curl 合适。主要局限：

1. 协议支持少：wget 主要支持 HTTP/HTTPS/FTP，curl 支持 20+ 种协议。
2. 请求控制弱：
3. 头部操作有限：
   curl 可随意增删修改请求头
   wget 只能设置基础头部（如 User-Agent）
4. 输出控制不便：
   结论：对于 CTF 或 Web 安全测试，curl 是首选工具；wget 更适合下载任务。

### telnet

理解HTTP协议本质：看到原始请求/响应格式
极端环境测试：只有最基础工具时使用
调试特殊问题：查看原始通信过程

### burpsuite

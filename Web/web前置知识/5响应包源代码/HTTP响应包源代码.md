**HTTP响应包源代码查看**，简单来说就是**查看服务器返回给客户端的原始数据**。

当你访问一个网页时，服务器返回的响应包含两部分：

- **响应头**：状态码、服务器信息、Cookie 等元数据。
- **响应体**：通常是 HTML 代码（即网页的源代码），也可能包含 CSS、JavaScript 或纯文本。

在 CTF 中，flag 有时就藏在响应体的 HTML 注释里，或者响应头的某个字段里（如 `Set-Cookie`、`X-Flag` 等）。所谓“源代码查看”，就是让你直接查看这些原始数据，而不是浏览器渲染后的页面。

**如何查看？**

- 浏览器：右键 → 查看页面源代码。
- 命令行：`curl -i URL` 或 `curl -v URL` 显示完整响应。
- 工具：Burp Suite 的 Repeater 或 Proxy 历史中查看原始报文。

## 开始，先试试curl -v

```fish
red@Arch web前置知识/基础认证
❯ curl -v http://challenge-015b44e6916ca15d.sandbox.ctfhub.com:10800/ | grep
 "ctfhub"
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0* Host challenge-015b44e6916ca15d.sandbox.ctfhub.com:10800 was resolved.
* IPv6: (none)
* IPv4: 47.98.117.93
*   Trying 47.98.117.93:10800...
* Established connection to challenge-015b44e6916ca15d.sandbox.ctfhub.com (47.98.117.93 port 10800) from 192.168.1.6 port 54156
* using HTTP/1.x
> GET / HTTP/1.1
> Host: challenge-015b44e6916ca15d.sandbox.ctfhub.com:10800
> User-Agent: curl/8.18.0
> Accept: */*
>
* Request completely sent off
< HTTP/1.1 200 OK
< Server: openresty/1.21.4.2
< Date: Wed, 18 Feb 2026 07:40:38 GMT
< Content-Type: text/html; charset=utf-8
< Content-Length: 9541
< Connection: keep-alive
< Last-Modified: Wed, 18 Feb 2026 07:36:41 GMT
< ETag: "69956c09-2545"
< Accept-Ranges: bytes
< Access-Control-Allow-Origin: *
< Access-Control-Allow-Headers: X-Requested-With
< Access-Control-Allow-Methods: *
<
{ [1066 bytes data]
<!-- ctfhub{420229f29c714547dc8cd69b} -->
100   9541 100   9541   0      0  36870      0                              100   9541 100   9541   0      0  36863      0                              100   9541 100   9541   0      0  36858      0                              0
* Connection #0 to host challenge-015b44e6916ca15d.sandbox.ctfhub.com:10800 left intact
```

?嘶？怎么答案直接出来了？

## 为什么我使用grep ‘ctfhub'之后没有直接显示“\<!-- ctfhub{420229f29c714547dc8cd69b} -->“？

你使用 `curl -v ... | grep "ctfhub"` 时，虽然最终看到了 flag，但 `grep` 的过滤效果被 `-v` 参数输出的额外信息干扰了。原因如下：

- **`-v`（verbose）** 让 curl 把**详细的通信过程**（如 DNS 解析、请求头、响应头、传输统计等）输出到**标准错误（stderr）**，而不是标准输出（stdout）。
- **管道 `|` 只连接标准输出**，因此 `grep` 仅接收到**响应体（HTML 内容）**，并从中正确过滤出了包含 `ctfhub` 的行（即注释中的 flag）。
- 但终端同时显示了来自 **stderr 的 verbose 信息**（例如连接过程、请求/响应头、进度条等）和 **stdout 经过 grep 处理后的结果**，导致输出看起来杂乱。

**验证方法**：  
将 stderr 重定向到 `/dev/null`，只保留 stdout 的 grep 结果：

```bash
curl -v http://... 2>/dev/null | grep "ctfhub"
```

此时终端只会显示 `<!-- ctfhub{420229f29c714547dc8cd69b} -->` 这一行。

**结论**：你的命令实际上成功了，flag 已被 grep 找出，只是被 verbose 信息掩盖了。去掉 `-v` 或重定向 stderr 即可获得干净输出。

## 实际测试

```fish
red@Arch web前置知识/基础认证
❯ curl -v http://challenge-b6653d8730ef2e53.sandbox.ctfhub.com:10800/ 2>/dev/null | grep 'ctfhub'
<!-- ctfhub{c16cc457a15a0e43942fbf06} -->

```

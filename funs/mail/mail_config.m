function config = mail_config()
    % 设置为 false 可关闭邮件通知 true/false
    config.enableSend = false;  % 是否启用发邮件（主脚本会读取这个值作为开关）

    config.sender   = '111111@qq.com'; % 直接将收发件人设置为一致即可，关键的是收件人
    config.password = 'lxrwapiscnklbjhf';  % 授权码而非登录密码
    config.receiver = '111111@qq.com'; % 接收人
end

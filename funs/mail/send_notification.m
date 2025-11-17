function send_notification(subject, body)
    % 从配置中读取
    config = mail_config();

    if ~config.enableSend
        fprintf('[邮件发送已禁用]：%s\n', subject);
        return;
    end

    setpref('Internet','E_mail', config.sender);
    setpref('Internet','SMTP_Server','smtp.qq.com');
    setpref('Internet','SMTP_Username', config.sender);
    setpref('Internet','SMTP_Password', config.password);

    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    sendmail(config.receiver, subject, body); % 明确区分标题和正文
end

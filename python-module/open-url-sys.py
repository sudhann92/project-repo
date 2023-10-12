import os
import webbrowser
outlook = "C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE"
one_note = "C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\ONENOTE.EXE"
vs_code = "C:\\Users\\G83141\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe"
url = ['https://.local/#/login', 'https://l/#/login',
        'https://', 'https:///#/login', 
        'https://nordea-smartit.onbmc.com/smartit/app/#/ticket-console']

os.startfile(outlook)
os.startfile(one_note)
os.startfile(vs_code)

webbrowser.register('chrome',None,webbrowser.BackgroundBrowser("C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"))
    
for url_name in url:
    webbrowser.get('chrome').open_new_tab(url_name)
exit()

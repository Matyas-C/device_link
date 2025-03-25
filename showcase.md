## Ukázka nových funkcí

### Automatické připojení
(proces připojení je většinou rychlejší, ale někdy se to rozhodne sbírat hodně ICE kandidáty (možné adresy, porty atd.),
které zařízení budou moct při spojení využít a pak to trochu trvá). Vždy se jedná o připojení k poslednímu připojenému zařízení (to je uložené v databázi).
Proces probíhá jen jednou po zapnutí aplikace jen jednou (aby se to nepokoušelo zařízení spárovat hned po tom, co se manuálně odpojí.

https://github.com/user-attachments/assets/b24595e4-5306-437d-be36-fcdb97998415

###  Automatické posílání schránky
Funguje jen ve směru počítač >>> telefon. Nejspíš protože Android dá přistup k tomu eventu jen aplikaci, co je zrovna na obrazovce

https://github.com/user-attachments/assets/a3e1ca2e-4724-44bd-904a-5e5be478645b

### Sdílení obrazovky
Tady zrovna kvalita byla celkem dobrá, ale někdy to dost kolísá. Netuším do jaké míry se to dá zlepšit a do jaké míry to je mojí wifi.

https://github.com/user-attachments/assets/f70fa7f3-b20f-4e23-8610-d54ba9014f1a

### Foreground service
Díky němu android nezavře aplikaci ta funguje i když je na "pozadí" (respektivě právě díky foreground servicu Android doopravdy nedá aplikaci na pozadí i když jí uživatel zrovna aktivně nepouživá a má otevřenou úplně jinou aplikaci). na iPhonu by to mělo fungovat podobně

![image](https://github.com/user-attachments/assets/a434585b-b88d-4771-aff4-b857bb496e0e)

### Baterka 
Ukazuje stav baterie připojeného zařízení, aktualizuje se každých 5s automaticky vč. ikony baterie.

![image](https://github.com/user-attachments/assets/e3f96178-bdf9-4969-beac-e7499ea5e7d9)

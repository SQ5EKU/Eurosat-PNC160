' Ostatnia data modyfikacji: 08.09.2013
' Program do sterowania PLL LMX2316 w nadajniku Eurosat PNC160 , z uC 89C52.
' Ustawienia PLL skopiowane z oryginalnego ukladu.
' Czestotliwosc pracy: 144.800 MHz , PLL caly czas wlaczona , parkowanie PLL na 146.9875 MHz
'
' http://sq5eku.blogspot.com
'

$regfile = "REG51.DAT"
$crystal = 18432000                                           ' zegar 18.432 MHz

Dim Tmp As Bit                                                ' zmienna odcinania nadawania po jednej rundzie
Dim C As Byte
Dim A As Byte

Config Sda = P1.3                                             ' pin 4  , magistrala I2C , SDA (24LC04)
Config Scl = P1.4                                             ' pin 5  , magistrala I2C , SCL (24LC04)

Data Alias P3.4                                               ' pin 14 , LMX2316 pin 12 (DATA)
Clk Alias P3.5                                                ' pin 15 , LMX2316 pin 11 (CLOCK)
Le Alias P3.3                                                 ' pin 13 , LMX2316 pin 13 (LE)

Ptt Alias P2.0                                                ' pin 21  Wejscie IN1  , DB25 pin 1 (jako PTT)
In2 Alias P2.1                                                ' pin 22  Wejscie IN2  , DB25 pin 2
In3 Alias P2.2                                                ' pin 23  Wejscie IN3  , DB25 pin 3
In4 Alias P2.3                                                ' pin 24  Wejscie IN4  , DB25 pin 4
In5 Alias P2.4                                                ' pin 25  Wejscie IN5  , DB25 pin 5
In6 Alias P2.5                                                ' pin 26  Wejscie IN6  , DB25 pin 6
In7 Alias P2.6                                                ' pin 27  Wejscie IN7  , DB25 pin 7
In8 Alias P2.7                                                ' pin 28  Wejscie IN8  , DB25 pin 8
In9 Alias P3.1                                                ' pin 11  Wejscie IN9  , DB25 pin 15
In10 Alias P3.0                                               ' pin 10  Wejscie IN10 , DB25 pin 14

'                                                             ' Przy stanach niskich na liniach Pwr1 , Pwr2 , Pwr3 uzyskujemy pelna moc
Pwr1 Alias P1.0                                               ' pin 1 regulacja mocy
Pwr2 Alias P1.1                                               ' pin 2 regulacja mocy
Pwr3 Alias P1.2                                               ' pin 3 regulacja mocy

Azw Alias P1.6                                                ' pin 7  , antyzwiecha
Vbat Alias P0.5                                               ' pin 34 , VBAT H=niskie napiecie zasilania , L=napiecie OK
Pa Alias P0.3                                                 ' pin 36 , zasilanie PA H=ON L=OFF
Drv Alias P1.5                                                ' pin 6  , wzmacniacz w.cz. H=OFF , L=ON
Led_1 Alias P0.2                                              ' pin 37 , LED-1 H=OFF L=ON , zielona LED - "retransmisja"
Led_2 Alias P0.1                                              ' pin 38 , LED-2 podwojna H=OFF L=ON , zielona , "siec"
Led_3 Alias P0.0                                              ' pin 39 , LED-2 podwojna H=OFF L=ON , czerwona , "nadawanie"
Ld Alias P0.7                                                 ' pin 32 , LD  H=synchronizacja , L=brak synchronizacji
Aux1 Alias P3.6                                               ' pin 16 , AUX , DB25 pin 16  H=OFF L=ON

P2 = &B11111111
Set In9
Set In10
Reset Pwr1
Reset Pwr2
Reset Pwr3
Set Tmp
Reset Pa
Set Azw
Set Drv
Set Vbat
Set Led_1
Set Led_2
Set Led_3
Set Ld
Set Aux1

Reset Clk
Reset Le
Reset Data


Declare Sub Zegarek1
Declare Sub Zegarek2
Declare Sub Le_pulse
Declare Sub Lmx_r
Declare Sub Lmx_n1
Declare Sub Lmx_n2
Declare Sub Lmx_f


'------------------------------------------------------------   glowna petla

Do
Reset Azw
  If Tmp = 0 Then
   If Ptt = 0 Then
    Gosub Lmx_r
    Gosub Lmx_n1
    Gosub Lmx_f
    Waitms 10
    Reset Led_3
    Set Tmp
    Reset Drv
    Set Pa
   End If
  End If

 If Ptt = 1 Then
  If Tmp = 1 Then
   Gosub Lmx_r
   Gosub Lmx_n2
   Gosub Lmx_f
   Waitms 10
   Set Led_3
   Reset Tmp
   Reset Azw
   Set Drv
   Reset Pa
  End If
 End If

Set Azw
Loop
End

'-------------------------------------------------------------  koniec glownej petli programu

Lmx_r:
 Restore Dat0
 For A = 1 To 21
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Lmx_n1:
 Restore Dat1
 For A = 1 To 21
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Lmx_n2:
 Restore Dat2
 For A = 1 To 21
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Lmx_f:
 Restore Dat3
 For A = 1 To 21
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Zegarek1:
 Set Data
 nop
 Set Clk
 nop
 Reset Clk
 nop
 Reset Data
Return

Zegarek2:
 Set Clk
 nop
 Reset Clk
 nop
Return

Le_pulse:
 nop
 Set Le
 nop
 Reset Le
 nop
 Reset Data
Return


Dat0:
'   21 bitowy rejestr R
'
'   REF: 12.8MHz , krok PLL: 12.5kHz , R=1024
'   1 bit LD prec. , 14 bitowy dzielnik R = 1024 , 2 bity control C1=0 C2=0
'
'   |LD| |-test mode-|   |------------------------R--------------------------|   |ctrl|
Data 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0       ' Wczytujemy od konca (LD /test / R / ctrl)
'
'
Dat1:
'   21 bitowy rejestr N    (czestotliwosc nadawcza)
'
'   TX: 144.800 MHz , krok PLL: 12.5kHz , N/A=11584
'   11584 : 32 = 362 (N) , 11584 mod 32 = 0 (A)
'
'   1 bit GO , 13 bitowy dzielnik B = 400 , 5 bitowy dzielnik A = 8 , 2 bity control C1=1 C2=0
'
'   |GO| |-----------------------B-----------------------|   |-------A-------|   |ctrl|
Data 1 , 0 , 0 , 0 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1       ' Wczytujemy od konca (GO / B / A / ctrl)
'
'
Dat2:
'   21 bitowy rejestr N    (czestotliwosc parkowania PLL)
'
'   TX: 146.9875 MHz , krok PLL: 12.5kHz , N/A=11759
'   11759 : 32 = 367 (N) , 11759 mod 32 = 15 (A)
'
'   1 bit GO , 13 bitowy dzielnik B = 400 , 5 bitowy dzielnik A = 8 , 2 bity control C1=1 C2=0
'
'   |GO| |-----------------------B-----------------------|   |-------A-------|   |ctrl|
Data 1 , 0 , 0 , 0 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 1 , 1 , 1 , 0 , 1 , 1 , 1 , 1 , 0 , 1       ' Wczytujemy od konca (GO / B / A / ctrl)
'
'
Dat3:
'   21 bitowy rejestr F
'
'   Rejestr innych funkcji PLL , 2 bity control C1=0 C2=1
'    |--------------------F----------------------------------------------|       |ctrl|
Data 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 1 , 0 , 0 , 1 , 0       ' Wczytujemy dane od konca (F / ctrl)
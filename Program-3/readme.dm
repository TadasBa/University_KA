Žingsninio režimo pertraukimo (int 1) apdorojimo procedūra, atpažįstanti komandą ADC reg+r/m. 
Ši procedūra turi patikrinti, ar pertraukimas įvyko prieš vykdant komandos ADC pirmąjį variantą,
jei taip, į ekraną išvesti perspėjimą, ir visą informaciją apie komandą: adresą, kodą, mnemoniką, operandus.

Pvz.: Į ekraną išvedama informacija galėtų atrodyti taip: Zingsninio rezimo pertraukimas! 0000:0128  12C6  adc al, dh ; al= 00, dh= 11

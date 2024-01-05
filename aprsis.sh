#!/bin/bash
#=============================================
# Генератор пароля для APRS-IS сервера на bash
# Pet-project de RN1M
# Version 0.1 05 january 2024
#=============================================
# В скрипте реализована проверка на недопустимые символы в названии позвыного,
# а также его длинна (не более 9 символов).
# Пароль генерируется по позывному без SSID
#
# Вопросы, преложения, критику или гнев пишите на почту:
# Packet radio: RN1M@RN1M.SPB.RUS.EU
# Winlink email: RN1M <at> winlink.org
# Sergey, RN1M 73!
#
# Далее появнения в свободной форме:)
# массив валидных символов в позывном
symbolArray=("-" "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")

function enterCall {
	read -p "Enter APRS-IS server login (callsign): " call
#измеряем длинну позвыного
	   len=`expr length "$call"`
#если длинна позывного менее 1 символа и более 9 символов
      		if (( $len < 1 || $len > 9 ));
			then
                         echo "Error: Login must be 1-9 characters long"
			 return 3
                  elif (( $len >= 1 && $len <= 9 ));
 			then
#выгружаем каждый символ из введенного позывного для проверки, чтобы не было недопустимых символов
			  for  ((i=1; i<=$len; i++))
			    do
                 	     sym=$(echo ${call^^} | cut -b $i)
#далеес равниваем во втором цикле первый символ из позывного с символами из массива
#прерываем цикл, если символ совпадает и сравниваем следующий символ из позывного с символами из массива
#выходим из цикла\функции с ошибкой, если есть недопустимый символ
			        for a in ${symbolArray[@]}
			 	  do
				   if [ $sym == $a ];
			             then
					break
				      elif [ "$sym" != "Z" ] && [ "$a" == "Z" ];
				      then
					echo "Error: invalid character: $sym"
					i=$len
					return 3
				        break
				       fi
			          done
  	                    done
			fi
		}

#небольшая функция,  чтобы повторно  была возможность ввести позывной при наличии недопустимого символа
function errorCh {
			return_val=$?
			while  [ $return_val -eq "3" ]; do
				enterCall
				return_val=$?
			done
		}
#функция получения позвыного без SSID для генерации парола APRS-IS
function withoutSSID {
		for  ((i=1; i<=$len; i++))
		    do
		      sym=$(echo ${call^^} | cut -b $i)
			 for a in ${symbolArray[@]}
			    do
		              if [ $sym == "-" ];
			             then
					ssid=$(( $i - 1 ))
					i=$len
					break
		              fi
			    done

  	              done
		}

#НАЧАЛО
#
#
echo "Generate APRS-IS Passcode ver. 0.1 de RN1M"
			 enterCall
			 errorCh
			 withoutSSID
#убираем SSID
				callWithoutSSID=$(echo ${call^^} | cut -c 1-$ssid)
#собственно генератор пароля для сервера APRS-IS
#алгоритм взят отсюда: https://github.com/DO3SWW/Web-Aprs-Passcode/blob/master/index.html
#проверить сгенерированный пароль в скрипте можно по ссылке:
#https://apps.magicbug.co.uk/passcode/index.php
#
	h=1
	tmp_code=29666
	 while (( $h < $len )); do
		sym=$(echo $callWithoutSSID | cut -b $h)
		ords=$(printf "%d" "'$sym")
		s=$(( $ords * 256 ))
		tmp_code="$(( tmp_code ^ s ))"
		b=$(( h + 1 ))
		sym=$(echo $callWithoutSSID | cut -b $b)
		ords=$(printf "%d" "'$sym")
		tmp_code="$(( tmp_code ^ ords ))"
		h=$(( h + 2 ))
	done
		code=$(( $tmp_code & 32767 ))
		echo "Your APRS-IS passcode $code for call $callWithoutSSID"



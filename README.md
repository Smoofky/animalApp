# Wstęp

Aplikacja mobilna IWalkWithDog została wykonana na zaliczenie pracy inżynierskiej. Ponieważ grupa była 3 osobowa, zatem backend oraz frontend (strona www) nie są mojego autorstwa. Poniżej zamieszczam tylko i wyłącznie część z aplikacją mobilną.

# Do czego i po co jest ta aplikacja ?

Aplikacja mobilna została stworzona z myślą o właścicielach zwierząt (psów). Posiada ona kilkanaście funkcjonalności, z czego kilka z nich jest mocno rozbudowana. Aplikacja korzysta z map Google oraz z wyznaczania trasy (również Places API i Directions API).

Mówiąc w skrócie, użytkownik może dodać zwierzę do aplikacji, a następnie kontrolować długość i ilość codziennych spacerów. Dodatkowo, za spacery dodawane są monety, które wykorzystywane są przy zakupach na stronie internetowej na rabaty.

# Wymagania funkcjonalne i screeny interfejsów

   ## 1. Rejestracja użytkownika
Rejestracja w aplikacji wymaga od użytkownika podania takich danych jak: email, login i hasło. Należy dodatkowo wyrazić zgodę na przetwarzanie danych osobowych oraz zaakceptować regulamin aplikacji. 

<img src="https://github.com/Smoofky/animalApp/assets/141446663/7a147ec8-14b3-471a-8065-e808999d6fdc" width="200" height="420"/>


   ## 2. Logowanie się w aplikacji
Należy wypełnić formularz logowania, wpisując login i hasło. Następnie po wciśnięciu przycisku ‘Zaloguj się’ odbywa się walidacja podanych danych. Po poprawnym wypełnieniu, użytkownik zostaje przekierowany na stronę główną aplikacji.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/d5e181cd-44bd-4bbb-a35d-881a04807362" width="200" height="420"/>
  
   ## 3. Resetowanie hasła
Umożliwienie resetowania hasła po naciśnięciu linka ‘Zresetuj hasło’ na stronie logowania. Procedura zaczyna się podaniem e maila, na który system wysyła kod umożliwiający zresetowanie hasła. Po wprowadzeniu tego kodu i potwierdzeniu jego poprawności, użytkownik zostaje przeniesiony do widoku zmiany hasła.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/e6f9dab2-e24c-4835-b152-f0c607dd28c1" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/14dad0b0-8acd-44e7-81a4-84595aff1b1c" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/25d749b3-d0de-46e8-ada8-4ddb8d7ab220" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/3a0782d1-4134-48d7-81cf-91c59a7b51c7" width="420" height="200"/>


   ## 4. Wylogowanie z aplikacji
Po zalogowaniu się w aplikacji, możliwość wylogowania się ze swojego konta.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/b3d963a1-7c6c-4e0c-94af-d8ddee9317df" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/04573b35-4d9d-4dbf-8781-3782030620f1" width="200" height="420"/>

  ##  5. Stworzenie profilu zwierzaka
Aby funkcje spaceru były dostępne, należy dodać swojego zwierzaka. Wymagane jest wpisanie imienia, typu, rasy, daty urodzenia, płci, wagi, opisu oraz wysokości. Opcjonalnie dodanie zdjęcia. 

<img src="https://github.com/Smoofky/animalApp/assets/141446663/3a7f00b8-3f01-4bb5-9c09-d71ed0e90bf8" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/99c3e6ec-869e-4fd2-9f9f-f718f15c0a79" width="200" height="420"/>


 ##   6. Usunięcie profilu zwierzaka
Możliwość usunięcia zwierzęcia z aplikacji.
 ##   7. Edycja danych użytkownika
Po dokonaniu rejestracji w aplikacji pojawia się możliwość zmiany danych konta, mianowicie hasła, maila, loginu, nr. telefonu, zdjęcia, danych osobowych. 

<img src="https://github.com/Smoofky/animalApp/assets/141446663/50595b09-7aa5-4350-92f6-6e7beb2444c1" width="200" height="420"/>


 ##   8. Edycja danych zwierzaka
Po dokonaniu rejestracji w aplikacji zwierzaka przez użytkownika istnieje możliwość zmiany danych takich jak imię, typ, rasa, data urodzenia, płeć, waga oraz wysokość, zdjęcie, krótki opis (do 500 znaków).

<img src="https://github.com/Smoofky/animalApp/assets/141446663/25367936-d6d6-4472-9aea-da2ba82e6845" width="200" height="420"/>


 ##   9. Spacer
Spacer w aplikacji wyświetla dla użytkownika mapę Google z bieżącą lokalizacją, pinezkami określonego zwierzęcia oraz w zależności od typu trasy - trasę między punktami bądź narysowaną linię łamaną za użytkownikiem. Na wysuwanym panelu u dołu ekranu przedstawione są statystyki takie jak czas spaceru, pokonana odległość oraz liczba zdobytych monet. Znajduje się tam również przycisk “Zakończ spacer”.



  ##  10. Dodanie pinezki
W trakcie spaceru użytkownik może dodać pinezkę na mapie poprzez dłuższe naciśnięcie określonego miejsca. Następnie wypełnia dane takie jak nazwę miejsca oraz jego opis.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/5ae34be5-f9e6-4bf5-9064-b8e334ca6f05" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/166f9293-40ec-4034-a229-f09d0d37abe8" width="200" height="420"/>

  ##  11. Ukrywanie/pokazywanie pinezek
W trakcie spaceru będzie można ukrywać/pokazywać pinezki dodane przez użytkownika.
   ## 12. Wydłużenie spaceru
Jeżeli został wybrany spacer z ograniczeniem czasowym, to po osiągnięciu wybranego czasu wyświetlony zostaje komunikat z informacją o czasie spaceru oraz pytaniem o jego przedłużenie bądź zakończenie.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/023ae9f6-de95-4c5c-bc89-fd5eb8be595a" width="200" height="420"/>

   ## 13. Automatyczne dopasowywanie spaceru
Spacer można wygenerować na podstawie takich danych jak typ miejsca oraz typ trasy. Przy obieraniu typu miejsca można będzie wybrać konkretne miejsce należące do kategorii parki, zwierzęta, sklepy lub restauracje. W aplikacji przewidziano dwa typy trasy. Trasa od lokalizacji początkowej i z powrotem (od A do A) wymaga wybrania co najmniej jednego miejsca. Trasa od lokalizacji początkowej do wybranej końcowej (od A do B), nie wymaga wyboru miejsca pomiędzy tymi punktami (lecz wymagane jest podanie punktu destynacji). Maksymalnie, użytkownik wybiera do dwóch punktów dodatkowych na trasie.


<img src="https://github.com/Smoofky/animalApp/assets/141446663/65dce27c-1381-4dd2-a86f-5d012db0efab" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/4ac8eade-9a8f-4d8c-960c-608b1cc95eb2" width="200" height="420"/>
<img src="https://github.com/Smoofky/animalApp/assets/141446663/e168a0a8-a37a-4e08-8ee8-256f954978a9" width="200" height="420"/>


   ## 14. Rozpoczynanie samodzielnego spaceru
Aplikacja pozwala użytkownikowi szybko rozpocząć spacer, bez dodatkowych ustawień lub ograniczeń. Taki spacer będzie śledził trasę, którą przechodzi użytkownik i zaznaczał ją kolorem.
  ##  15. Zakończenie spaceru
Po naciśnięciu przycisku “Zakończ spacer”, zostaje wyświetlona strona ze statystykami spaceru oraz zrzutem mapy z pokonaną trasą. Wynik można będzie zapisać i wtedy użytkownik jest przenoszony na stronę z historią spacerów. W innym przypadku spacer nie zapisuje się i użytkownik zostaje przeniesiony na stronę główną.


<img src="https://github.com/Smoofky/animalApp/assets/141446663/ac9a47e5-e335-44e5-be99-7ece60d59edc" width="200" height="420"/>


  ##  16. Usunięcie wyniku spaceru z historii
Po wejściu na stronę z wynikami spacerów można będzie usunąć spacer gestem longpress.

<img src="https://github.com/Smoofky/animalApp/assets/141446663/b2e28e8d-5850-4b34-9c67-0ce6aab7b8ce" width="200" height="420"/>


  ##  17. Zbieranie monet
Użytkownik będzie otrzymywał monety za pokonaną odległość na spacerach. Monety te będzie mógł wykorzystać na rabaty do sklepu internetowego.


# Diagram sekwencji - rozpoczęcie spaceru

Aby lepiej zrozumieć ideę spaceru, zamieszczam również diagram sekwencji dla tej aktywności.

![Rozpoczęcie Spaceru - Diagram Sekwencji 1 of 2](https://github.com/Smoofky/animalApp/assets/141446663/de330b47-5325-4554-ae0f-0be1d43fe4fc)



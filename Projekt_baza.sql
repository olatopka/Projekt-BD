-- BAZY DANYCH PROJEKT 

-- Tworzenie tabeli Klienci
CREATE OR REPLACE TABLE Klienci (
    IDklienta INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) UNIQUE,
    haslo VARCHAR(50),
    Imie VARCHAR(50),
    Nazwisko VARCHAR(50),
    Telefon VARCHAR(20),
    Email VARCHAR(100),
    NIP VARCHAR(10),
    LiczbaZlozonychZamowien INT DEFAULT 0
);

-- Tworzenie tabeli Typ_produktu
CREATE OR REPLACE TABLE Typ_produktu (
    IDnazwaproduktu INT AUTO_INCREMENT PRIMARY KEY,
    nazwaproduktu VARCHAR(50)
);

-- Tworzenie tabeli Produkty
CREATE OR REPLACE TABLE Produkty (
    IDproduktu INT AUTO_INCREMENT PRIMARY KEY,
    IDnazwaproduktu INT,
    marka VARCHAR(50),
    model VARCHAR(50),
    cena_netto DECIMAL(10, 2),
    Vat DECIMAL(10, 2) DEFAULT 0.23,
    cena_brutto DECIMAL(10, 2) AS (cena_netto + (cena_netto * Vat)),
    okres_gwarancji INT,
    FOREIGN KEY (IDnazwaproduktu) REFERENCES Typ_produktu(IDnazwaproduktu)
);

-- Tworzenie tabeli Koszyk z dodaną kolumną DataZamowienia
CREATE OR REPLACE TABLE Koszyk (
    IDKoszyk INT AUTO_INCREMENT PRIMARY KEY,
    IDKlienta INT,
    IDproduktu INT,
    ilosc INT,
    cena_calkowita DECIMAL(10, 2),
    DataZamowienia DATE, -- Dodana kolumna do przechowywania daty zamówienia
    FOREIGN KEY (IDKlienta) REFERENCES Klienci(IDklienta),
    FOREIGN KEY (IDproduktu) REFERENCES Produkty(IDproduktu)
);

CREATE OR REPLACE TABLE Zamowienia (
    IDzamowienia INT AUTO_INCREMENT PRIMARY KEY,
    IDklienta INT,
    DataZlozeniaZamowienia DATE,
    KosztZamowienia DECIMAL(10, 2),
    FOREIGN KEY (IDklienta) REFERENCES Klienci(IDklienta)
);

-- Tworzenie tabeli Adres
CREATE OR REPLACE TABLE Adres (
  #  IDAdres INT AUTO_INCREMENT PRIMARY KEY,
    IDKlienci INT,
    Miejscowosc VARCHAR(50),
    Ulica VARCHAR(50),
    Nrdomu VARCHAR(4),
    KodPocztowy VARCHAR(6),
    FOREIGN KEY (IDKlienci) REFERENCES Klienci(IDklienta)
);

-- Tworzenie tabeli Faktury
CREATE OR REPLACE TABLE Faktury (
    IDFaktury INT AUTO_INCREMENT PRIMARY KEY,
    IDZamowienia INT,
    IDKlienta INT,
    Oplacona VARCHAR(20),
    FOREIGN KEY (IDZamowienia) REFERENCES Zamowienia(IDzamowienia),
    FOREIGN KEY (IDKlienta) REFERENCES Klienci(IDklienta)
);

-- Tworzenie tabeli Reklamacje
CREATE OR REPLACE TABLE Reklamacje (
    IDReklamacji INT AUTO_INCREMENT PRIMARY KEY,
    IDZamowienia INT,
    Reklamacja VARCHAR(50),
    FOREIGN KEY (IDZamowienia) REFERENCES Zamowienia(IDzamowienia)
);

-- Tworzenie tabeli Zysk
CREATE OR REPLACE TABLE Zysk (
    IDZysk INT AUTO_INCREMENT PRIMARY KEY,
    IDZamowienia INT,
    Suma_zamowienia DECIMAL(10, 2),
    Zwrot_reklamacja DECIMAL(10, 2),
    Ostateczny_zysk DECIMAL(10, 2),
    FOREIGN KEY (IDZamowienia) REFERENCES Zamowienia(IDzamowienia)
);



-- Dodawanie losowo 200 klientów 

CREATE OR REPLACE PROCEDURE DodajKlientow()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE genLogin VARCHAR(50);
    DECLARE genImie VARCHAR(50);
    DECLARE genNazwisko VARCHAR(50);
    DECLARE genTelefon VARCHAR(20);
    DECLARE genEmail VARCHAR(100);
    DECLARE genNIP VARCHAR(20);

    -- Tworzenie tabel tymczasowych na potrzeby list imion i nazwisk
    CREATE TEMPORARY TABLE IF NOT EXISTS ImionaLista (
        Imie VARCHAR(50)
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS NazwiskaLista (
        Nazwisko VARCHAR(50)
    );

    -- Dodanie imion do tabeli tymczasowej
    INSERT INTO ImionaLista (Imie) VALUES ('Anna'), ('Jan'), ('Maria'), ('Piotr'), ('Katarzyna'), ('Tomasz'), ('Magdalena'), ('Paweł'), ('Justyna'), 
    ('Łukasz'), ('Barbara'), ('Michał'), ('Agnieszka'), ('Szymon'), ('Dorota'), ('Andrzej'), ('Karolina'), 
    ('Artur'), ('Kinga'), ('Przemysław'), ('Izabela'), ('Tadeusz'), ('Monika'), ('Rafał'), ('Beata'), ('Radosław'), 
    ('Weronika'), ('Jakub'), ('Marta'), ('Mateusz'), ('Kamila'), ('Adam'), ('Natalia'), ('Marcin'), ('Agata'), 
    ('Dawid'), ('Laura'), ('Robert'), ('Oliwia'), ('Tomasz'), ('Alicja'), ('Daniel'), ('Patrycja'), ('Piotr'), 
    ('Klaudia'), ('Karol'), ('Elżbieta'), ('Witold'), ('Olga'), ('Bartosz'), ('Kornelia'), ('Tadeusz'), ('Nina'), 
    ('Filip'), ('Ewa'), ('Łukasz'), ('Anna'), ('Mateusz'), ('Kamila'), ('Paweł'), ('Natalia'), ('Krzysztof');

    -- Dodanie nazwisk do tabeli tymczasowej
    INSERT INTO NazwiskaLista (Nazwisko) VALUES ('Nowak'), ('Kowalski'), ('Wiśniewski'), ('Wójcik'), ('Kowalczyk'), ('Kamiński'), ('Lewandowski'), ('Dąbrowski'), 
    ('Świderski'), ('Witkowski'), ('Kaczmarek'), ('Sobczak'), ('Majewski'), ('Nowicki'), ('Włodarczyk'), ('Przybylski'), 
    ('Michalski'), ('Krupa'), ('Kwiecień'), ('Wrona'), ('Marciniak'), ('Jaworski'), ('Adamczyk'), ('Stępień'), ('Szczepański'), 
    ('Kaczor'), ('Pawlak'), ('Czarnecki'), ('Wroński'), ('Kubiak'), ('Mazurek'), ('Grabowski'), ('Pławecki'), ('Brzeziński'), 
    ('Tomczak'), ('Kołodziej'), ('Głowacki'), ('Staniszewski'), ('Baranowski'), ('Zieliński'), ('Lis'), ('Chmielewski'), 
    ('Sikora'), ('Gajewski'), ('Jasiński'), ('Kowalewski'), ('Szulc'), ('Kaźmierczak'), ('Olszewski'), ('Mazurek'), ('Jabłoński');

    WHILE i <= 200 DO
        -- Wybieranie losowego imienia i nazwiska z listy
        SET genImie = (SELECT Imie FROM ImionaLista ORDER BY RAND() LIMIT 1);
        SET genNazwisko = (SELECT Nazwisko FROM NazwiskaLista ORDER BY RAND() LIMIT 1);

        SET genLogin = CONCAT('user', LPAD(i, 3, '0'));
        SET genTelefon = LPAD(FLOOR(RAND() * 900000000) + 100000000, 9, '0');
        SET genEmail = CONCAT(genLogin, '@example.com');
        SET genNIP = LPAD(FLOOR(RAND() * 900000000) + 100000000, 9, '0');

        INSERT INTO Klienci (login, Imie, Nazwisko, Telefon, Email, NIP)
        VALUES (genLogin, genImie, genNazwisko, genTelefon, genEmail, genNIP);
        
        SET i = i + 1;
    END WHILE;

    -- Usuwanie tabel tymczasowych po użyciu
    DROP TEMPORARY TABLE IF EXISTS ImionaLista;
    DROP TEMPORARY TABLE IF EXISTS NazwiskaLista;
END;


-- Wywołanie procedury
CALL DodajKlientow();

select*from klienci k 

-- Funkcja generująca hasła dla dodanych już klientów 
CREATE OR REPLACE FUNCTION GenerujIPrzypiszHasla()
RETURNS INT
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE klientID INT;
    DECLARE genHaslo VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT IDklienta FROM Klienci WHERE haslo IS NULL OR haslo = '';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO klientID;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Generowanie hasła
        SET genHaslo = '';
        REPEAT
            SET genHaslo = CONCAT(genHaslo, CHAR(FLOOR(RAND() * 94) + 33));
            UNTIL CHAR_LENGTH(genHaslo) = 10
        END REPEAT;

        UPDATE Klienci SET haslo = genHaslo WHERE IDklienta = klientID;
    END LOOP;

    CLOSE cur;
    RETURN 1;
END;

-- Wywołanie funckji
SELECT GenerujIPrzypiszHasla();


SELECT * FROM  klienci


-- Dodanie 200 losowych adresów

INSERT INTO Adres (IDKlienci, Miejscowosc, Ulica, Nrdomu, KodPocztowy)
VALUES
	(1, 'Warszawa', 'Aleja Kwiatowa', '12', '00-123'),
	(2, 'Kraków', 'ul. Rynek', '45', '30-456'),
	(3, 'Gdańsk', 'ul. Portowa', '78', '80-789'),
	(4, 'Poznań', 'ul. Ratajczaka', '34', '60-789'),
	(5, 'Wrocław', 'ul. Słowiańska', '56', '50-678'),
	(6, 'Szczecin', 'ul. Piękna', '7', '70-111'),
	(7, 'Łódź', 'ul. Piotrkowska', '21', '90-456'),
	(8, 'Katowice', 'ul. Górnicza', '9', '40-789'),
	(9, 'Białystok', 'ul. Lipowa', '15', '15-234'),
	(10, 'Płock', 'ul. Nadwiślańska', '3', '09-876'),
	(11, 'Kraków', 'ul. Krakowska', '67', '30-123'),
	(12, 'Gdynia', 'ul. Portofino', '3', '81-456'),
	(13, 'Bydgoszcz', 'ul. Leśna', '45', '85-789'),
	(14, 'Warszawa', 'ul. Chopina', '23', '01-234'),
	(15, 'Wrocław', 'ul. Nowa', '89', '50-111'),
	(16, 'Gliwice', 'ul. Główna', '11', '44-333'),
	(17, 'Lublin', 'ul. Akacjowa', '33', '20-555'),
	(18, 'Zakopane', 'ul. Tatrzańska', '5', '34-456'),
	(19, 'Kraków', 'ul. Krowoderska', '8', '30-789'),
	(20, 'Sopot', 'ul. Monte Cassino', '22', '81-876'),
	(21, 'Warszawa', 'ul. Mokotowska', '56', '02-111'),
	(22, 'Poznań', 'ul. Wielkopolska', '14', '60-345'),
	(23, 'Gdańsk', 'ul. Długa', '19', '80-678'),	
	(24, 'Kraków', 'ul. Floriańska', '31', '30-123'),
	(25, 'Bytom', 'ul. Sobieskiego', '7', '41-789'),
	(26, 'Wrocław', 'ul. Prusa', '55', '50-234'),
	(27, 'Rzeszów', 'ul. Podkarpacka', '10', '35-456'),
	(28, 'Gdynia', 'ul. Kartuska', '88', '81-789'),
	(29, 'Słupsk', 'ul. Wojska Polskiego', '42', '76-555'),
	(30, 'Warszawa', 'ul. Belwederska', '13', '00-444'),
	(31, 'Poznań', 'ul. Mickiewicza', '27', '61-123'),
	(32, 'Łódź', 'ul. Legionów', '9', '90-234'),
	(33, 'Gdańsk', 'ul. Kartuska', '18', '80-567'),
	(34, 'Katowice', 'ul. Mariacka', '5', '40-789'),
	(35, 'Kraków', 'ul. Dietla', '40', '30-876'),
	(36, 'Wrocław', 'ul. Kiełbaśnicza', '12', '50-111'),
	(37, 'Białystok', 'ul. Jagiellońska', '24', '15-345'),
	(38, 'Sopot', 'ul. Grunwaldzka', '7', '81-567'),
	(39, 'Gdynia', 'ul. Kosynierów', '30', '81-678'),
	(40, 'Warszawa', 'ul. Obozowa', '3', '01-444'),
	(41, 'Kraków', 'ul. Zwierzyniecka', '16', '30-123'),
	(42, 'Rzeszów', 'ul. Podwisłocze', '22', '35-234'),
	(43, 'Gdańsk', 'ul. Szafarnia', '8', '80-456'),
	(44, 'Poznań', 'ul. Dąbrowskiego', '5', '61-789'),
	(45, 'Warszawa', 'ul. Miodowa', '33', '00-234'),
	(46, 'Łódź', 'ul. Pabianicka', '11', '90-345'),
	(47, 'Sopot', 'ul. 3 Maja', '20', '81-567'),
	(48, 'Gdynia', 'ul. Legionów', '29', '81-678'),
	(49, 'Bydgoszcz', 'ul. Gdańska', '14', '85-111'),
	(50, 'Warszawa', 'ul. Wilcza', '6', '00-123'),
	(51, 'Kraków', 'ul. Lubicz', '9', '30-123'),
	(52, 'Gdańsk', 'ul. Długi Targ', '15', '80-456'),
	(53, 'Poznań', 'ul. Mickiewicza', '18', '61-789'),
	(54, 'Warszawa', 'ul. Zielona', '27', '02-111'),
	(55, 'Wrocław', 'ul. Kościuszki', '44', '50-234'),
	(56, 'Katowice', 'ul. Mariacka', '10', '40-567'),
	(57, 'Łódź', 'ul. Tuwima', '6', '90-678'),
	(58, 'Sopot', 'ul. Bohaterów Monte Cassino', '31', '81-444'),
	(59, 'Gdynia', 'ul. Armii Krajowej', '13', '81-555'),
	(60, 'Kraków', 'ul. Karmelicka', '8', '30-678'),
	(61, 'Bydgoszcz', 'ul. Dworcowa', '21', '85-111'),
	(62, 'Warszawa', 'ul. Krucza', '19', '00-345'),
	(63, 'Rzeszów', 'ul. Piłsudskiego', '7', '35-456'),
	(64, 'Gdańsk', 'ul. Wąska', '23', '80-789'),
	(65, 'Poznań', 'ul. Rynkowska', '4', '61-234'),
	(66, 'Łódź', 'ul. Piotrkowska', '13', '90-567'),
	(67, 'Sopot', 'ul. Haffnera', '26', '81-678'),
	(68, 'Kraków', 'ul. Zwierzyniecka', '7', '30-789'),
	(69, 'Wrocław', 'ul. Grodzka', '18', '50-111'),
	(70, 'Gdynia', 'ul. Legionów', '5', '81-444'),
	(71, 'Warszawa', 'ul. Długa', '33', '00-567'),
	(72, 'Katowice', 'ul. Wojewódzka', '16', '40-678'),
	(73, 'Bytom', 'ul. Słowackiego', '10', '41-234'),
	(74, 'Gdańsk', 'ul. Marynarki Polskiej', '29', '80-567'),
	(75, 'Poznań', 'ul. Dąbrowskiego', '17', '61-678'),
	(76, 'Warszawa', 'ul. Marszałkowska', '11', '02-111'),
	(77, 'Łódź', 'ul. Nawrot', '22', '90-789'),
	(78, 'Sopot', 'ul. Bohaterów Warszawy', '5', '81-444'),
	(79, 'Gdynia', 'ul. Morska', '14', '81-555'),
	(80, 'Kraków', 'ul. Krasickiego', '20', '30-678'),
	(81, 'Wrocław', 'ul. Czysta', '3', '50-111'),
	(82, 'Rzeszów', 'ul. Podwisłocze', '15', '35-234'),
	(83, 'Gdańsk', 'ul. Wiosenna', '27', '80-567'),
	(84, 'Poznań', 'ul. Słowiańska', '9', '61-789'),
	(85, 'Łódź', 'ul. Politechniki', '12', '90-456'),
	(86, 'Sopot', 'ul. Bohaterów Monte Cassino', '6', '81-444'),
	(87, 'Kraków', 'ul. Zamoyskiego', '32', '30-678'),
	(88, 'Wrocław', 'ul. Piękna', '44', '50-111'),
	(89, 'Gdynia', 'ul. Orląt Lwowskich', '8', '81-444'),
	(90, 'Warszawa', 'ul. Wiejska', '13', '00-567'),
	(91, 'Katowice', 'ul. Warszawska', '25', '40-678'),
	(92, 'Bytom', 'ul. Piekarska', '18', '41-234'),
	(93, 'Gdańsk', 'ul. Starówka', '10', '80-567'),
	(94, 'Poznań', 'ul. Słowackiego', '15', '61-678'),
	(95, 'Łódź', 'ul. Piotrkowska', '28', '90-789'),
	(96, 'Sopot', 'ul. Władysława IV', '7', '81-444'),
	(97, 'Kraków', 'ul. Krakowska', '22', '30-678'),
	(98, 'Wrocław', 'ul. Przykładowa', '34', '50-111'),
	(99, 'Gdynia', 'ul. Skwer Kościuszki', '11', '81-444'),
	(100, 'Warszawa', 'ul. Powązkowska', '18', '00-567'),
	(101, 'Katowice', 'ul. Mickiewicza', '7', '40-678'),
	(102, 'Bytom', 'ul. Gliwicka', '19', '41-234'),
	(103, 'Gdańsk', 'ul. Długie Pobrzeże', '25', '80-567'),
	(104, 'Poznań', 'ul. Mostowa', '12', '61-678'),
	(105, 'Warszawa', 'ul. Łazienkowska', '16', '00-567'),
	(106, 'Łódź', 'ul. Sienkiewicza', '8', '90-789'),
	(107, 'Sopot', 'ul. Bohaterów Warszawy', '31', '81-444'),
	(108, 'Kraków', 'ul. Krowoderska', '11', '30-678'),
	(109, 'Wrocław', 'ul. Kręta', '27', '50-111'),
	(110, 'Gdynia', 'ul. 10 Lutego', '14', '81-444'),
	(111, 'Warszawa', 'ul. Złota', '9', '00-567'),
	(112, 'Katowice', 'ul. Armii Krajowej', '22', '40-678'),
	(113, 'Bytom', 'ul. Dworcowa', '16', '41-234'),
	(114, 'Gdańsk', 'ul. Targ Sienny', '5', '80-567'),
	(115, 'Poznań', 'ul. Dąbrowskiego', '31', '61-678'),
	(116, 'Łódź', 'ul. Piotrkowska', '19', '90-789'),
	(117, 'Sopot', 'ul. Monte Cassino', '11', '81-444'),
	(118, 'Kraków', 'ul. Zwierzyniecka', '6', '30-678'),
	(119, 'Wrocław', 'ul. Karmelicka', '23', '50-111'),
	(120, 'Gdynia', 'ul. Morska', '9', '81-444'),
	(121, 'Warszawa', 'ul. Długa', '22', '00-567'),
	(122, 'Katowice', 'ul. Warszawska', '8', '40-678'),
	(123, 'Bytom', 'ul. Piekarska', '17', '41-234'),
	(124, 'Gdańsk', 'ul. Oliwska', '14', '80-567'),
	(125, 'Poznań', 'ul. Słowackiego', '21', '61-678'),
	(126, 'Łódź', 'ul. Piotrkowska', '14', '90-789'),
	(127, 'Sopot', 'ul. Władysława IV', '9', '81-444'),
	(128, 'Kraków', 'ul. Krakowska', '20', '30-678'),
	(129, 'Wrocław', 'ul. Przykładowa', '38', '50-111'),
	(130, 'Gdynia', 'ul. Skwer Kościuszki', '15', '81-444'),
	(131, 'Warszawa', 'ul. Powązkowska', '21', '00-567'),
	(132, 'Katowice', 'ul. Mickiewicza', '9', '40-678'),
	(133, 'Bytom', 'ul. Gliwicka', '17', '41-234'),
	(134, 'Gdańsk', 'ul. Długie Pobrzeże', '30', '80-567'),
	(135, 'Poznań', 'ul. Mostowa', '14', '61-678'),
	(136, 'Warszawa', 'ul. Łazienkowska', '19', '00-567'),
	(137, 'Łódź', 'ul. Sienkiewicza', '10', '90-789'),
	(138, 'Sopot', 'ul. Bohaterów Warszawy', '29', '81-444'),
	(139, 'Kraków', 'ul. Krowoderska', '15', '30-678'),
	(140, 'Wrocław', 'ul. Kręta', '23', '50-111'),
	(141, 'Gdynia', 'ul. 10 Lutego', '11', '81-444'),
	(142, 'Warszawa', 'ul. Złota', '7', '00-567'),
	(143, 'Katowice', 'ul. Armii Krajowej', '25', '40-678'),
	(144, 'Bytom', 'ul. Dworcowa', '18', '41-234'),
	(145, 'Gdańsk', 'ul. Targ Sienny', '7', '80-567'),
	(146, 'Poznań', 'ul. Dąbrowskiego', '33', '61-678'),
	(147, 'Łódź', 'ul. Piotrkowska', '20', '90-789'),
	(148, 'Sopot', 'ul. Monte Cassino', '13', '81-444'),
	(149, 'Kraków', 'ul. Zwierzyniecka', '5', '30-678'),
	(150, 'Wrocław', 'ul. Karmelicka', '25', '50-111'),
	(151, 'Gdynia', 'ul. Morska', '11', '81-444'),
	(152, 'Warszawa', 'ul. Długa', '24','56-123'),
	(153, 'Poznań', 'ul. Podgórna', '9', '60-789'),
	(154, 'Wrocław', 'ul. Rzeźnicza', '36', '50-678'),
	(155, 'Łódź', 'ul. Rewolucji 1905 roku', '14', '90-111'),
	(156, 'Warszawa', 'ul. Solec', '5', '02-456'),
	(157, 'Katowice', 'ul. Warszawska', '33', '40-789'),
	(158, 'Białystok', 'ul. Malmeda', '21', '15-234'),
	(159, 'Płock', 'ul. Sienkiewicza', '8', '09-876'),
	(160, 'Kraków', 'ul. Starowiślna', '14', '30-123'),
	(161, 'Gdynia', 'ul. Słowackiego', '29', '81-456'),
	(162, 'Bydgoszcz', 'ul. Długa', '6', '85-789'),
	(163, 'Warszawa', 'ul. Senatorska', '12', '01-234'),
	(164, 'Wrocław', 'ul. Piłsudskiego', '7', '50-111'),
	(165, 'Gliwice', 'ul. Krótka', '19', '44-333'),
	(166, 'Lublin', 'ul. Lipowa', '8', '20-555'),
	(167, 'Zakopane', 'ul. Nowotarska', '44', '34-456'),
	(168, 'Kraków', 'ul. Karmelicka', '13', '30-789'),
	(169, 'Sopot', 'ul. 10 Lutego', '25', '81-876'),
	(170, 'Warszawa', 'ul. Senatorska', '9', '02-111'),
	(171, 'Poznań', 'ul. Dąbrowskiego', '16', '60-345'),
	(172, 'Gdańsk', 'ul. Garncarska', '7', '80-678'),	
	(173, 'Kraków', 'ul. Szewska', '30', '30-123'),
	(174, 'Bytom', 'ul. Ks. Piotra Skargi', '4', '41-789'),
	(175, 'Wrocław', 'ul. Kościuszki', '11', '50-234'),
	(176, 'Rzeszów', 'ul. Długa', '5', '35-456'),
	(177, 'Gdynia', 'ul. Chylońska', '20', '81-789'),
	(178, 'Słupsk', 'ul. Armii Krajowej', '15', '76-555'),
	(179, 'Warszawa', 'ul. Foksal', '29', '00-444'),
	(180, 'Poznań', 'ul. Malwowa', '8', '61-123'),
	(181, 'Łódź', 'ul. Nawrot', '23', '90-234'),
	(182, 'Gdańsk', 'ul. Doki', '14', '80-567'),
	(183, 'Katowice', 'ul. Gliwicka', '18', '40-789'),
	(184, 'Kraków', 'ul. Kopernika', '10', '30-876'),
	(185, 'Wrocław', 'ul. Wróblewskiego', '27', '50-111'),
	(186, 'Białystok', 'ul. Piastowska', '19', '15-345'),
	(187, 'Sopot', 'ul. 3 Maja', '10', '81-567'),
	(188, 'Gdynia', 'ul. Świętojańska', '5', '81-678'),
	(189, 'Bydgoszcz', 'ul. Chrobrego', '9', '85-111'),
	(190, 'Warszawa', 'ul. Złota', '14', '00-123'),
	(191, 'Kraków', 'ul. Zyblikiewicza', '17', '30-456'),
	(192, 'Gdańsk', 'ul. Wajdeloty', '21', '80-789'),
	(193, 'Poznań', 'ul. Długa', '33', '60-789'),
	(194, 'Wrocław', 'ul. Sienkiewicza', '6', '50-678'),
	(195, 'Łódź', 'ul. Mickiewicza', '14', '90-111'),
	(196, 'Warszawa', 'ul. Prosta', '27', '02-456'),
	(197, 'Katowice', 'ul. Lecha', '7', '40-789'),
	(198, 'Białystok', 'ul. Słowiańska', '22', '15-234'),
	(199, 'Płock', 'ul. 3 Maja', '5', '09-876'),
	(200, 'Kraków', 'ul. Wawel', '33', '30-123');

select*from adres;

select*from klienci;

-- Wprowadzenie danych do tabeli Typ_produktu
INSERT INTO Typ_produktu (nazwaproduktu) VALUES
('smartfon'),
('telewizor'),
('kuchenka'),
('komputer'),
('mikrofalówka'),
('soundbar'),
('konsola do gier'),
('ekspres do kawy'),
('monitor'),
('głośniki bezprzewodowe'),
('słuchawki'),
('myszka'),
('klawiatura'),
('tablet'),
('pralka'),
('lodówka'),
('router WiFi');


-- Wprowadzenie danych do tabeli Produkty
INSERT INTO Produkty (IDnazwaproduktu, marka, model, cena_netto, okres_gwarancji) VALUES
(1, 'Samsung', 'Galaxy_23', 12345.00, 12),
(1, 'Nokia', '6303_Classic', 7423.00, 24),
(2, 'LG', 'Optimus_P10', 123.00, 12),
(2, 'Sony', 'November_123', 890.00, 12),
(4, 'Samsung', 'Gerav_12', 435.00, 12),
(2, 'LG', 'Optiminis_12', 1234.00, 13),
(3, 'Beko', 'Bash', 423, 24),
(3, 'Sony', 'Xperia_Z', 5699.00, 18),
(5, 'Samsung', 'QLED_75', 8999.00, 24),
(6, 'Bosch', 'Serie_8', 2299.00, 36),
(7, 'Dell', 'Inspiron_15', 3299.00, 24),
(8, 'Bose', 'SoundTouch_300', 1999.00, 12),
(10, 'Logitech', 'G502_Hero', 249.00, 12),
(12, 'Apple', 'iPad_Air', 3199.00, 12),
(14, 'Siemens', 'iQ500', 3499.00, 24),
(15, 'Lenovo', 'Legion_Y540', 5499.00, 24),
(16, 'Philips', 'Serie_5000', 349.00, 24),
(17, 'Sony', 'WH-1000XM4', 1249.00, 24),
(9, 'Corsair', 'K95_RGB_Platinum', 899.00, 12),
(7, 'Microsoft', 'Xbox_Series_X', 2499.00, 24),
(16, 'Krups', 'EA8150', 1199.00, 24),
(4, 'LG', 'NanoCell_85', 3299.00, 24);



SELECT * FROM Produkty 

select* from typ_produktu;


-- Aktualizowanie ceny_zamowienia w koszyku 
CREATE TRIGGER ObliczCeneCalkowitaPrzedDodaniemDoKoszyka
BEFORE INSERT ON Koszyk
FOR EACH ROW
BEGIN
    SELECT cena_brutto INTO @cenaBrutto FROM Produkty WHERE IDproduktu = NEW.IDproduktu;
    SET NEW.cena_calkowita = @cenaBrutto * NEW.ilosc;
END;


CREATE TRIGGER AktualizujZamowieniePoDodaniuDoKoszyka
AFTER INSERT ON Koszyk
FOR EACH ROW
BEGIN
    DECLARE KosztPojedynczegoProduktu DECIMAL(10, 2);
    DECLARE OstatnieIDZamowienia INT;
    DECLARE CzyIstniejeOstatnieZamowienie BOOLEAN;

    -- Obliczanie ceny pojedynczego produktu
    SELECT cena_brutto INTO KosztPojedynczegoProduktu
    FROM Produkty
    WHERE IDproduktu = NEW.IDproduktu;

    -- Sprawdzanie, czy istnieje zamówienie dla tego klienta z datą równą DataZamowienia z Koszyka
    SELECT IDzamowienia INTO OstatnieIDZamowienia
    FROM Zamowienia
    WHERE IDklienta = NEW.IDKlienta
    AND DataZlozeniaZamowienia = NEW.DataZamowienia
    LIMIT 1;

    SET CzyIstniejeOstatnieZamowienie = (OstatnieIDZamowienia IS NOT NULL);

    -- Aktualizacja istniejącego zamówienia lub tworzenie nowego
    IF CzyIstniejeOstatnieZamowienie THEN
        -- Aktualizacja istniejącego zamówienia
        UPDATE Zamowienia
        SET KosztZamowienia = KosztZamowienia + (KosztPojedynczegoProduktu * NEW.ilosc)
        WHERE IDzamowienia = OstatnieIDZamowienia;
    ELSE
        -- Tworzenie nowego zamówienia
        INSERT INTO Zamowienia (IDklienta, KosztZamowienia, DataZlozeniaZamowienia)
        VALUES (NEW.IDKlienta, KosztPojedynczegoProduktu * NEW.ilosc, NEW.DataZamowienia);
    END IF;
END;



-- Aktualizacja Tabeli faktury po złozeniu zamóweinia
CREATE TRIGGER UtworzFakturePoZlozeniuZamowienia
AFTER INSERT ON Zamowienia
FOR EACH ROW
BEGIN
    -- Tworzenie nowej faktury dla każdego nowego zamówienia
    INSERT INTO Faktury (IDZamowienia, IDKlienta, Oplacona)
    VALUES (NEW.IDzamowienia, NEW.IDklienta, 'Tak');
END;




-- Uzupełnianie tabeli zysk 
CREATE TRIGGER UtworzZyskPoZamowieniu
AFTER INSERT ON Zamowienia
FOR EACH ROW
BEGIN
    INSERT INTO Zysk (IDZamowienia, Suma_zamowienia, Zwrot_reklamacja, Ostateczny_zysk)
    VALUES (NEW.IDzamowienia, NEW.KosztZamowienia, 0, NEW.KosztZamowienia);
END;


CREATE TRIGGER AktualizujZyskPoReklamacji
AFTER INSERT ON Reklamacje
FOR EACH ROW
BEGIN
    DECLARE zwrot DECIMAL(10, 2);

    -- Załóżmy, że zwrot to 10% wartości zamówienia w przypadku reklamacji
    SET zwrot = (SELECT KosztZamowienia * 0.1 FROM Zamowienia WHERE IDzamowienia = NEW.IDZamowienia);

    UPDATE Zysk
    SET Zwrot_reklamacja = zwrot,
        Ostateczny_zysk = Suma_zamowienia - zwrot
    WHERE IDZamowienia = NEW.IDZamowienia;
END;


-- Aktualizacja liczby zamówień w tabeli Klienci
CREATE OR REPLACE PROCEDURE AktualizujLiczbeZamowien()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE klientID INT;
    DECLARE liczbaZamowien INT;
    
    DECLARE cur CURSOR FOR SELECT IDklienta FROM Klienci;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO klientID;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*) INTO liczbaZamowien FROM Zamowienia WHERE IDklienta = klientID;
        UPDATE Klienci SET LiczbaZlozonychZamowien = liczbaZamowien WHERE IDklienta = klientID;
    END LOOP;

    CLOSE cur;
END;

CALL AktualizujLiczbeZamowien();

-- Wprowadzenie danych do tabeli Koszyk
INSERT INTO Koszyk (IDKlienta, IDproduktu, ilosc, DataZamowienia) VALUES
(1, 2, 2,'2024-01-22'),
(1, 3, 1,'2024-01-22'),
(2, 2, 3,'2024-01-21'),
(2, 4, 2,'2024-01-21'),
(3, 5, 1,'2024-01-22'),
(1, 6, 4,'2024-01-20'),
(4, 1, 3,'2024-01-26'),
(4, 2, 2,'2024-01-27'),
(4, 4, 1,'2024-01-26'),
(1, 6, 2,'2024-01-20');


SELECT * FROM Klienci;
CALL AktualizujLiczbeZamowien();
SELECT * FROM Klienci


-- Uzupełnianie tabeli Reklamacje
-- Wstawienie rekordów do tabeli Reklamacje z wartościami 1 lub 0 na podstawie liczby zamówień
-- Aktualizacja rekordów w tabeli Reklamacje
INSERT INTO Reklamacje (IDZamowienia, Reklamacja)
SELECT IDZamowienia, CASE WHEN RAND() < 0.5 THEN 1 ELSE 0 END
FROM Zamowienia;



-- Funkcja obliczająca całkowita liczbe złożonych zamówień do tej pory 
CREATE FUNCTION LiczbaWszystkichZamowien() 
RETURNS INT
BEGIN
    DECLARE total_orders INT;
    SELECT COUNT(*) INTO total_orders FROM Zamowienia;
    RETURN total_orders;
END;


SELECT LiczbaWszystkichZamowien() AS Calkowita_liczba_zlozonych_zamowien;


-- Funkcja obliczająca całkowity Zysk sklepu internetowego 
CREATE FUNCTION WyliczCalkowityZysk() 
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total_profit DECIMAL(10, 2);
    SELECT SUM(Ostateczny_zysk) INTO total_profit FROM Zysk;
    RETURN total_profit;
END;


SELECT WyliczCalkowityZysk() AS Calkowity_zysk_sklepu_internetowego;



-- Procedura generująca raport sprzedaży
CREATE PROCEDURE GenerujRaportSprzedazy(IN dataPoczatkowa DATE, IN dataKoncowa DATE)
BEGIN
    SELECT 
        p.IDproduktu,
        tp.nazwaproduktu,
        p.marka,
        p.model,
        COUNT(k.IDproduktu) AS LiczbaSprzedanych,
        SUM(k.cena_calkowita) AS CalyZysk
    FROM 
        Produkty p
    JOIN 
        Koszyk k ON p.IDproduktu = k.IDproduktu
    JOIN 
        Zamowienia z ON k.IDKoszyk = z.IDzamowienia
    JOIN 
        Typ_produktu tp ON p.IDnazwaproduktu = tp.IDnazwaproduktu
    WHERE 
        z.DataZlozeniaZamowienia BETWEEN dataPoczatkowa AND dataKoncowa
    GROUP BY 
        p.IDproduktu
    ORDER BY 
        LiczbaSprzedanych DESC, CalyZysk DESC;
END;


CALL GenerujRaportSprzedazy('2024-01-01', '2024-01-31');



--  Znajdowanie klienta po nazwisku:
CREATE PROCEDURE WyszukajKlientaPoNazwisku(IN nazwisko_param VARCHAR(50))
BEGIN
    SELECT * FROM Klienci WHERE Nazwisko = nazwisko_param;
END;


-- WIDOKI 


-- Utworzenie widoku vStatus
CREATE OR REPLACE VIEW vStatus AS
SELECT IDzamowienia, Imie, Nazwisko, KosztZamowienia
FROM Zamowienia JOIN Klienci ON Klienci.IDklienta = zamowienia.IDklienta
ORDER BY IDzamowienia ASC;



-- Utworzenie widoku z trzema klientami o najwyższej liczbie zamówień
CREATE OR REPLACE VIEW vNajlepsiKlienci AS
SELECT IDklienta, login, Imie, Nazwisko, Telefon, Email, NIP, LiczbaZlozonychZamowien
FROM Klienci
ORDER BY LiczbaZlozonychZamowien DESC
LIMIT 3;


-- Utworzenie widoku zawierającego informacje kliencie:
CREATE OR REPLACE VIEW vDaneKlientow AS
SELECT k.IDklienta, k.imie, k.nazwisko, a.miejscowosc, a.ulica, a.Nrdomu, a.kodpocztowy
FROM klienci k
JOIN adres a ON k.idklienta = a.idklienci;

select*from adres;
select*from klienci

-- Partycjonowanie 

CREATE OR REPLACE TABLE Zysk_partycjonowanie (
    IDZysk INT AUTO_INCREMENT,
    IDZamowienia INT,
    Suma_zamowienia DECIMAL(10, 2),
    Zwrot_reklamacja DECIMAL(10, 2),
    Ostateczny_zysk DECIMAL(10, 2),
    PRIMARY KEY (IDZysk, IDZamowienia)
) PARTITION BY RANGE (IDZamowienia) (
    PARTITION p0 VALUES LESS THAN (2),
    PARTITION p1 VALUES LESS THAN (5),
    PARTITION p2 VALUES LESS THAN (10),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);


INSERT INTO Zysk_partycjonowanie (IDZysk, IDZamowienia, Suma_zamowienia, Zwrot_reklamacja, Ostateczny_zysk)
SELECT IDZysk, IDZamowienia, Suma_zamowienia, Zwrot_reklamacja, Ostateczny_zysk FROM Zysk;


SELECT TABLE_NAME, PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME = 'Zysk_partycjonowanie';


CREATE UNIQUE INDEX informacje_konta ON Klienci (login, haslo, Imie, Nazwisko, Email);


select * from Zysk_partycjonowanie;

select*from typ_produktu;

select *from produkty;

select *from klienci;

select*from adres;

select *from koszyk;

select*from zamowienia;

select *from faktury;

select*from reklamacje;

select *from zysk;

select *from vstatus;

SELECT * FROM vnajlepsiklienci;

SELECT * FROM vDaneKlientow ;

SELECT * FROM Klienci WHERE Nazwisko  = 'Nowak';

-- sprawdzenie czy dodanei do koszyka zmienia odpoweidnio dane w nazsej bazie:
INSERT INTO Koszyk (IDKlienta, IDproduktu, ilosc, DataZamowienia) VALUES
(10, 12, 2,'2024-01-21');

CALL GenerujRaportSprzedazy('2024-01-01', '2024-01-31');
CALL AktualizujLiczbeZamowien();

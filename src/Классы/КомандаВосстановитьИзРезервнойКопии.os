
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;

// Интерфейсная процедура, выполняет регистрацию команды и настройку парсера командной строки
//   
// Параметры:
//   ИмяКоманды 	- Строка										- Имя регистрируемой команды
//   Парсер 		- ПарсерАргументовКоманднойСтроки (cmdline)		- Парсер командной строки
//
Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Восстановить базу MS SQL из резервной копии");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-params",
		"Файлы JSON содержащие значения параметров,
		|могут быть указаны несколько файлов разделенные "";""
		|(параметры командной строки имеют более высокий приоритет)");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-sql-srvr",
		"Адрес сервера MS SQL");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-sql-user",
		"Пользователь сервера");
		
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-sql-pwd",
		"Пароль пользователя сервера");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-sql-db",
		"Имя базы для восстановления");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-bak-path",
		"Путь к резервной копии");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-create-db",
		"Создать базу в случае отсутствия");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-owner",
		"Имя владельца базы после восстановления");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-compress-db",
		"Включить компрессию страниц таблиц и индексов после восстановления");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-shrink-db",
		"Сжать базу после восстановления");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-path",
		"Путь к каталогу файлов данных базы после восстановления");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-logpath",
		"Путь к каталогу файлов журнала после восстановления");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-recovery",
		"Установить модель восстановления (RECOVERY MODEL), возможные значения ""FULL"", ""SIMPLE"",""BULK_LOGGED""");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-db-changelfn",
		"Изменить логические имена файлов (LFN) базы, в соответствии с именем базы");

	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, 
		"-delsrc",
		"Удалить файл резервной копии после восстановления");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры // ЗарегистрироватьКоманду()

// Функция получает и проверяет параметры команды
//   
// Параметры:
//   ПараметрыКоманды 	- Соответствие			- Соответствие параметров команды и их значений
//
// Возвращаемое значение:
//	Структура, Неопределено - структура параметров, если возникла ошибка проверки параметров, тогда Неопределено
//
Функция ПолучитьПараметрыКоманды(Знач ПараметрыКоманды)

	ЕстьОшибкиПараметров = Ложь;

	Параметры = Новый Структура();

	ЗапускПриложений.ПрочитатьПараметрыКомандыИзФайла(ПараметрыКоманды["-params"], ПараметрыКоманды);
	
	Параметры.Вставить("Сервер"					, ПараметрыКоманды["-sql-srvr"]);
	Параметры.Вставить("База"					, ПараметрыКоманды["-sql-db"]);
	Параметры.Вставить("Пользователь"			, ПараметрыКоманды["-sql-user"]);
	Параметры.Вставить("ПарольПользователя"		, ПараметрыКоманды["-sql-pwd"]);
	Параметры.Вставить("ПутьКРезервнойКопии"	, ПараметрыКоманды["-bak-path"]);
	Параметры.Вставить("СоздаватьБазу"			, ПараметрыКоманды["-create-db"]);
	Параметры.Вставить("ВладелецБазы"			, ПараметрыКоманды["-db-owner"]);
	Параметры.Вставить("ВключитьКомпрессию"		, ПараметрыКоманды["-compress-db"]);
	Параметры.Вставить("СжатьБазу"				, ПараметрыКоманды["-shrink-db"]);
	Параметры.Вставить("ПутьКФайлуДанных"		, ПараметрыКоманды["-db-path"]);
	Параметры.Вставить("ПутьКФайлуЖурнала"		, ПараметрыКоманды["-db-logpath"]);
	Параметры.Вставить("МодельВосстановления"	, ПараметрыКоманды["-db-recovery"]);
	Параметры.Вставить("ИзменитьЛИФ"			, ПараметрыКоманды["-db-changelfn"]);
	Параметры.Вставить("УдалитьИсточник"		, ПараметрыКоманды["-delsrc"]);

	Если ПустаяСтрока(Параметры.Сервер) Тогда
		Лог.Ошибка("Не указан сервер MS SQL");
		ЕстьОшибкиПараметров = Истина;
	КонецЕсли;

	Если ПустаяСтрока(Параметры.База) Тогда
		Лог.Ошибка("Не указана база для восстановления");
		ЕстьОшибкиПараметров = Истина;
	КонецЕсли;

	Если ПустаяСтрока(Параметры.ПутьКРезервнойКопии) Тогда
		Лог.Ошибка("Не задан путь к резервной копии");
		ЕстьОшибкиПараметров = Истина;
	КонецЕсли;

	Если ПустаяСтрока(Параметры.ПутьКФайлуДанных) Тогда
		Лог.Ошибка("Не задан путь к каталогу файлов данных");
		ЕстьОшибкиПараметров = Истина;
	КонецЕсли;

	Если ПустаяСтрока(Параметры.ПутьКФайлуЖурнала) Тогда
		Лог.Ошибка("Не задан путь к каталогу файлов журнала");
		ЕстьОшибкиПараметров = Истина;
	КонецЕсли;

	Если ЕстьОшибкиПараметров Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат Параметры;

КонецФункции // ПолучитьПараметрыКоманды()

// Интерфейсная процедура, выполняет текущую команду
//   
// Параметры:
//   ПараметрыКоманды 	- Соответствие						- Соответствие параметров команды и их значений
//
// Возвращаемое значение:
//	Число - код возврата команды
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
	
	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Параметры = ПолучитьПараметрыКоманды(ПараметрыКоманды);
	
	Если Параметры = Неопределено Тогда
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если НЕ ВыполнитьВосстановление(Новый Структура("Сервер, Пользователь, Пароль",
													Параметры.Сервер,
													Параметры.Пользователь,
													Параметры.ПарольПользователя)
								, Параметры.База
								, Параметры.ПутьКРезервнойКопии
								, Параметры.ПутьКФайлуДанных
								, Параметры.ПутьКФайлуЖурнала
								, Параметры.СоздаватьБазу) Тогда
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецЕсли;

	Если Параметры.УдалитьИсточник Тогда
		УдалитьИсточник(Параметры.ПутьКРезервнойКопии);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.ВладелецБазы) Тогда
		ИзменитьВладельца(Параметры.База, Параметры.ВладелецБазы);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.МодельВосстановления) Тогда
		ИзменитьМодельВосстановления(Параметры.База, Параметры.МодельВосстановления);
	КонецЕсли;
	
	Если Параметры.ИзменитьЛИФ Тогда
		ИзменитьЛогическиеИменаФайлов(Параметры.База);
	КонецЕсли;
	
	Если Параметры.ВключитьКомпрессию Тогда
		ВключитьКомпрессию(Параметры.База);
	КонецЕсли;
	
	Если Параметры.СжатьБазу Тогда
		СжатьБазу(Параметры.База);
	КонецЕсли;
	
	Возврат ВозможныйРезультат.Успех;

КонецФункции // ВыполнитьКоманду()

// Удаляет файл-источник резервной копии
//   
// Параметры:
//   ПараметрыПодключения		- Структура		- Имя сервера СУБД, пользователь и пароль
//   База 						- Строка				- имя базы
//   ПутьКРезервнойКопии		- Строка		- путь к файлу резервной копии
//   ПутьКФайлуДанных			- Строка		- путь к файлу данных базы
//   ПутьКФайлуЖурнала			- Строка		- путь к файлу журнала транзакций базы
//   СоздаватьБазу				- Булево		- Истина - создать базу в случае отсутствия
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция ВыполнитьВосстановление(ПараметрыПодключения
							, База
							, ПутьКРезервнойКопии
							, ПутьКФайлуДанных
							, ПутьКФайлуЖурнала
							, СоздаватьБазу)

	Инструменты = Новый ИнструментыСУБД;

	ОписаниеРезультата = "";
	
	Попытка
		Инструменты.Инициализировать(ПараметрыПодключения.Сервер
								, ПараметрыПодключения.Пользователь
								, ПараметрыПодключения.ПарольПользователя);
	Исключение
		Лог.Ошибка("Ошибка при инициализации инструментов СУБД: " + ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

	Лог.Информация("Начало восстановления базы ""%1"" из резервной копии ""%2"": %3"
					, База
					, ПутьКРезервнойКопии
					, ОписаниеРезультата);

	Попытка
	
		Результат = Инструменты.ВосстановитьИзРезервнойКопии(База
														   , ПутьКРезервнойКопии
														   , ПутьКФайлуДанных
														   , ПутьКФайлуЖурнала
														   , СоздаватьБазу
														   , ОписаниеРезультата);

		Если Результат Тогда
			Лог.Информация("Выполнено восстановление базы ""%1"" из резервной копии ""%2"": %3"
						, База
						, ПутьКРезервнойКопии
						, ОписаниеРезультата);
		Иначе
			Лог.Ошибка("Ошибка восстановления базы ""%1"" из резервной копии ""%2"": %3"
						, База
						, ПутьКРезервнойКопии
						, ОписаниеРезультата);
			Возврат Ложь;
		КонецЕсли;

	Исключение
		Лог.Ошибка("Ошибка восстановления базы ""%1"" из резервной копии ""%2"": %3"
				 , Параметры.База
				 , Параметры.ПутьКРезервнойКопии
				 , ОписаниеОшибки() + ?(ЗначениеЗаполнено(ОписаниеРезультата), Символы.ПС + ОписаниеРезультата, ""));
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ВыполнитьВосстановление()

// Удаляет файл-источник резервной копии
//   
// Параметры:
//   ПутьКРезервнойКопии		- Строка		- путь к файлу резервной копии
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция УдалитьИсточник(ПутьКРезервнойКопии)

	Попытка
		УдалитьФайлы(ПутьКРезервнойКопии);
		Лог.Информация("Исходный файл %1 удален", ПутьКРезервнойКопии);
	Исключение
		Лог.Ошибка("Ошибка удаления файла %1: %2", ПутьКРезервнойКопии, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // УдалитьИсточник()

// Устанавливает нового владельца базы
//   
// Параметры:
//   База 				- Строка				- имя базы
//   ВладелецБазы 		- Строка				- новый владелец базы
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция ИзменитьВладельца(База, ВладелецБазы)

	Попытка
		Результат = Инструменты.УстановитьВладельцаБазы(База, ВладелецБазы);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка смены владельца базы ""%1"" на ""%2"""
					, База
					, ВладелецБазы);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Для базы ""%1"" установлен новый владелец ""%2"""
					, База
					, ВладелецБазы);
	Исключение
		Лог.Ошибка("Ошибка смены владельца базы ""%1"" на ""%2"": %3"
				, База
				, ВладелецБазы
				, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ИзменитьВладельца()

// Устанавливает нового владельца базы
//   
// Параметры:
//   База 					- Строка				- имя базы
//   МодельВосстановления	- Строка				- новая модель восстановления (FULL, SIMPLE, BULK_LOGGED)
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция ИзменитьМодельВосстановления(База, МодельВосстановления)

	Попытка
		Результат = Инструменты.УстановитьМодельВосстановления(База, МодельВосстановления);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка смены модели восстановления базы ""%1"" на ""%2"""
					, База
					, МодельВосстановления);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Для базы ""%1"" установлена модель восстановления ""%2"""
					, База
					, МодельВосстановления);
	Исключение
		Лог.Ошибка("Ошибка смены модели восстановления базы ""%1"" на ""%2"": %3"
				, База
				, МодельВосстановления
				, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ИзменитьМодельВосстановления()

// Устанавливает логические имена файлов базы в соответствии с именем базы
//   
// Параметры:
//   База 				- Строка				- имя базы
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция ИзменитьЛогическиеИменаФайлов(База)

	Попытка
		ЛИФ = Инструменты.ПолучитьЛогическоеИмяФайлаВБазе(База, "ROWS");
		НовоеЛИФ = База;
		Результат = Инструменты.ИзменитьЛогическоеИмяФайлаБазы(База, ЛИФ, НовоеЛИФ);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка изменения логического имени файла данных ""%1"" в базе ""%2"""
					, ЛИФ
					, База);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Для базы ""%1"" изменено логическое имя файла данных ""%2"" на ""%3"""
					, База
					, ЛИФ
					, НовоеЛИФ);
	Исключение
		Лог.Ошибка("Ошибка изменения логического имени файла данных ""%1"" в базе ""%2"": %3"
				, ЛИФ
				, База
				, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;
	
	Попытка
		ЛИФ = Инструменты.ПолучитьЛогическоеИмяФайлаВБазе(База, "LOG");
		НовоеЛИФ = База + "_log";
		Результат = Инструменты.ИзменитьЛогическоеИмяФайлаБазы(База, ЛИФ, НовоеЛИФ);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка изменения логического имени файла журнала ""%1"" в базе ""%2"""
					, ЛИФ
					, База);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Для базы ""%1"" изменено логическое имя файла журнала ""%2"" на ""%3"""
					, База
					, ЛИФ
					, НовоеЛИФ);
	Исключение
		Лог.Ошибка("Ошибка изменения логического имени файла журнала ""%1"" в базе ""%2"": %3"
				, ЛИФ
				, База
				, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ИзменитьЛогическиеИменаФайлов()

// Включает компрессию данных базы на уровне страниц
//   
// Параметры:
//   База 				- Строка				- имя базы
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция ВключитьКомпрессию(База)

	Лог.Информация("Начало компрессии страниц базы ""%1""", База);
		
	Попытка
		Результат = Инструменты.ВключитьКомпрессиюСтраниц(База);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка включения компрессии страниц в базе ""%1""", База);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Включена компрессия страниц в базе ""%1""", База);
	Исключение
		Лог.Ошибка("Ошибка включения компрессии страниц в базе ""%1"": ""%2""", База, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // ВключитьКомпрессию()

// Выполняет сжатие базы (shrink)
//   
// Параметры:
//   База 				- Строка				- имя базы
//
// Возвращаемое значение:
//	Булево - Истина - команда выполнена успешно; Ложь - в противном случае
//
Функция СжатьБазу(База)

	Лог.Информация("Начало сжатия (shrink) базы ""%1""", База);
		
	Попытка
		Результат = Инструменты.СжатьБазу(База);

		Если НЕ Результат Тогда
			Лог.Ошибка("Ошибка сжатия базы ""%1""", База);
			Возврат Ложь;
		КонецЕсли;

		Лог.Информация("Выполнено сжатие базы ""%1""", База);
	Исключение
		Лог.Ошибка("Ошибка сжатия базы ""%1"": ""%2""", База, ОписаниеОшибки());
		Возврат Ложь;
	КонецПопытки;

	Возврат Истина;

КонецФункции // СжатьБазу()

Лог = Логирование.ПолучитьЛог("ktb.app.cpdb");
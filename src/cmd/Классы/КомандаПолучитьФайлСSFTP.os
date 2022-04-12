// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать "../../core"

Перем Лог;       // - Объект      - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("pp params", "", "Файлы JSON содержащие значения параметров,
	                               | могут быть указаны несколько файлов разделенные "";""")
	       .ТСтрока()
	       .ВОкружении("CPDB_PARAMS");

	Команда.Опция("s server", "", "адрес сервера SFTP")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SFTP_SERVER");

	Команда.Опция("sp port", "22", "порт сервера SFTP")
	       .ТСтрока()
	       .ВОкружении("CPDB_SFTP_PORT");

	Команда.Опция("u user", "", "имя пользователя сервера SFTP")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SFTP_USER");

	Команда.Опция("n pwd", "", "пароль пользователя сервера SFTP")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SFTP_PWD");

	Команда.Опция("p path", "", "Путь к локальному каталогу для сохранения загруженных файлов")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SFTP_GET_PATH");
	
	Команда.Опция("f file", "", "путь к файлу на NextCloud для загрузки")
	       .ТСтрока()
	       .ВОкружении("CPDB_SFTP_GET_FILE");
	
	Команда.Опция("l list", "", "путь к файлу на NextCloud со списком файлов,
	                            |которые будут загружены (параметр -file игнорируется)")
	       .ТСтрока()
	       .ВОкружении("CPDB_SFTP_GET_LIST");
	
	Команда.Опция("ds delsrc", "", "удалить исходные файлы после получения")
	       .Флаговый()
	       .ВОкружении("CPDB_SFTP_GET_DEL_SRC");
	
   КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ЧтениеОпций = Новый ЧтениеОпцийКоманды(Команда);

	ВыводОтладочнойИнформации = ЧтениеОпций.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	ЭтоСписокФайлов = Истина;
	
	АдресСервера       = ЧтениеОпций.ЗначениеОпции("server");
	ПортСервера        = ЧтениеОпций.ЗначениеОпции("port");
	ИмяПользователя    = ЧтениеОпций.ЗначениеОпции("user");
	ПарольПользователя = ЧтениеОпций.ЗначениеОпции("pwd");
	ЦелевойПуть        = ЧтениеОпций.ЗначениеОпции("path");

	ПутьНаДиске        = ЧтениеОпций.ЗначениеОпции("list");
	Если НЕ ЗначениеЗаполнено(ПутьНаДиске) Тогда
		ПутьНаДиске = ЧтениеОпций.ЗначениеОпции("file");
		ЭтоСписокФайлов	= Ложь;
	КонецЕсли;

	УдалитьИсточник  = ЧтениеОпций.ЗначениеОпции("delsrc");

	Если ПустаяСтрока(ПутьНаДиске) Тогда
		ВызватьИсключение  "Не задан путь к файлу для получения из NextCloud";
	КонецЕсли;

	Соединение = Новый КлиентSSH(АдресСервера, ПортСервера, ИмяПользователя, ПарольПользователя);

	ПутьКСкачанномуФайлу = РаботаСФайлами.ПолучитьФайлСSFTP(Соединение, ПутьНаДиске, ЦелевойПуть, УдалитьИсточник);

	ФайлИнфо = Новый Файл(ПутьКСкачанномуФайлу);

	КаталогНаДиске = СтрЗаменить(ПутьНаДиске, ФайлИнфо.Имя, "");

	Если ЭтоСписокФайлов Тогда
		МассивПолучаемыхФайлов = РаботаСФайлами.ПрочитатьСписокФайлов(ПутьКСкачанномуФайлу);
		Для Каждого ПолучаемыйФайл Из МассивПолучаемыхФайлов Цикл
			РаботаСФайлами.ПолучитьФайлСSFTP(Соединение,
			                                 ОбъединитьПути(КаталогНаДиске, ПолучаемыйФайл),
			                                 ОбъединитьПути(ЦелевойПуть, ПолучаемыйФайл),
			                                 УдалитьИсточник);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
